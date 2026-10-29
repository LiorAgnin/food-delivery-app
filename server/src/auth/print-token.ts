import { JwtService } from '@nestjs/jwt'
import { drizzle } from 'drizzle-orm/node-postgres'
import path from 'node:path'
import { Pool } from 'pg'
import { getEnv } from '../config/env'
import { customers } from '../db/schema'
import { TokenService } from './token.service'

const E164 = /^\+[1-9]\d{1,14}$/

export function readPhoneArg (argv: readonly string[]): string {
  const phone = argv[2]
  if (phone === undefined || !E164.test(phone)) {
    throw new Error('usage: npm run token -- <E.164 phone>')
  }
  return phone
}

export async function issueTokenForPhone (phone: string): Promise<string> {
  const env = getEnv()
  const pool = new Pool({ connectionString: env.DATABASE_URL })
  const db = drizzle(pool)
  try {
    const [row] = await db
      .insert(customers)
      .values({ phone })
      .onConflictDoUpdate({
        target: customers.phone,
        set: { phone },
      })
      .returning({ id: customers.id })
    if (!row) {
      throw new Error(`customer upsert returned no row for ${phone}`)
    }
    const tokens = new TokenService(
      new JwtService({
        secret: env.JWT_SECRET,
        signOptions: { algorithm: 'HS256' },
      }),
    )
    return tokens.sign(row.id)
  } finally {
    await pool.end()
  }
}

function isDirectRun (): boolean {
  const entry = process.argv[1]
  if (!entry) return false
  return path.resolve(entry) === path.resolve(__filename)
}

if (isDirectRun()) {
  let phone: string
  try {
    phone = readPhoneArg(process.argv)
  } catch (error: unknown) {
    console.error(error instanceof Error ? error.message : error)
    process.exit(1)
  }
  issueTokenForPhone(phone)
    .then((token) => {
      process.stdout.write(`${token}\n`)
    })
    .catch((error: unknown) => {
      console.error(error instanceof Error ? error.message : error)
      process.exit(1)
    })
}
