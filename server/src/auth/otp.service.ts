import { Inject, Injectable } from '@nestjs/common'
import { and, desc, eq, gte, isNull, sql } from 'drizzle-orm'
import { DomainError } from '../common/domain-error'
import { DRIZZLE, type Database } from '../db/database.module'
import {
  customers,
  otpChallenges,
  type OtpChallengeRow,
} from '../db/schema'
import { Clock } from './clock'
import {
  OtpPolicy,
  type OtpChallengeSnapshot,
  type OtpDecision,
  type OtpRequestBody,
} from './otp-policy'
import { TokenService } from './token.service'

export const OTP_DEV_MODE = Symbol('OTP_DEV_MODE')

type VerifiedCustomer = { id: string; phone: string }

export type VerifiedOtp = {
  accessToken: string
  customer: VerifiedCustomer
}

type RejectKind = Exclude<OtpDecision['kind'], 'accept'>

type VerifyOutcome =
  | { kind: 'accept'; customer: VerifiedCustomer }
  | { kind: RejectKind }

@Injectable()
export class OtpService {
  constructor (
    @Inject(DRIZZLE) private readonly db: Database,
    private readonly policy: OtpPolicy,
    private readonly clock: Clock,
    private readonly tokens: TokenService,
    @Inject(OTP_DEV_MODE) private readonly devMode: boolean,
  ) {}

  async request (phone: string): Promise<OtpRequestBody> {
    const issued = await this.db.transaction(async (tx) => {
      await tx.execute(sql`select pg_advisory_xact_lock(hashtext(${phone}))`)
      const recent = await tx
        .select({ id: otpChallenges.id })
        .from(otpChallenges)
        .where(
          and(
            eq(otpChallenges.phone, phone),
            gte(otpChallenges.createdAt, this.policy.windowStart()),
          ),
        )
      const next = this.policy.issue(recent.length)
      await tx.insert(otpChallenges).values({
        phone,
        codeHash: next.codeHash,
        expiresAt: next.expiresAt,
        createdAt: this.clock.now(),
      })
      return next
    })
    return OtpPolicy.requestBody(this.devMode, issued.code)
  }

  async verify (phone: string, code: string): Promise<VerifiedOtp> {
    const outcome = await this.db.transaction(async (tx): Promise<VerifyOutcome> => {
      const [active] = await tx
        .select()
        .from(otpChallenges)
        .where(
          and(eq(otpChallenges.phone, phone), isNull(otpChallenges.consumedAt)),
        )
        .orderBy(desc(otpChallenges.createdAt))
        .limit(1)
        .for('update')

      const snapshot = active
        ? snapshotOf(active)
        : await latestSnapshot(tx, phone)
      const decision = this.policy.decide(snapshot, code)

      if (decision.kind === 'mismatch') {
        if (active) {
          await tx
            .update(otpChallenges)
            .set({ attempts: decision.attempts })
            .where(eq(otpChallenges.id, active.id))
        }
        return { kind: 'mismatch' as const }
      }

      if (decision.kind !== 'accept' || !active) {
        return { kind: decision.kind === 'accept' ? 'invalid' : decision.kind }
      }

      await tx
        .update(otpChallenges)
        .set({ consumedAt: this.clock.now() })
        .where(
          and(eq(otpChallenges.phone, phone), isNull(otpChallenges.consumedAt)),
        )

      const [customer] = await tx
        .insert(customers)
        .values({ phone })
        .onConflictDoUpdate({
          target: customers.phone,
          set: { phone },
        })
        .returning({ id: customers.id, phone: customers.phone })
      if (!customer) {
        throw new DomainError('INTERNAL', 'Customer upsert returned no row')
      }
      return { kind: 'accept' as const, customer }
    })

    if (outcome.kind !== 'accept') throw verifyError(outcome.kind)
    return {
      accessToken: this.tokens.sign(outcome.customer.id),
      customer: outcome.customer,
    }
  }
}

function snapshotOf (row: OtpChallengeRow): OtpChallengeSnapshot {
  return {
    codeHash: row.codeHash,
    expiresAt: row.expiresAt,
    attempts: row.attempts,
    consumedAt: row.consumedAt,
  }
}

async function latestSnapshot (
  db: Database,
  phone: string,
): Promise<OtpChallengeSnapshot | null> {
  const [latest] = await db
    .select()
    .from(otpChallenges)
    .where(eq(otpChallenges.phone, phone))
    .orderBy(desc(otpChallenges.createdAt))
    .limit(1)
  return latest ? snapshotOf(latest) : null
}

function verifyError (kind: RejectKind): DomainError {
  if (kind === 'expired') return new DomainError('OTP_EXPIRED', 'Code expired')
  if (kind === 'too_many_attempts') {
    return new DomainError('OTP_TOO_MANY_ATTEMPTS', 'Too many attempts')
  }
  return new DomainError('OTP_INVALID', 'Invalid code')
}
