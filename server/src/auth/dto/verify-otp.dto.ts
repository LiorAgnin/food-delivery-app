import { Matches } from 'class-validator'

const E164 = /^\+[1-9]\d{1,14}$/
const SIX_DIGITS = /^\d{6}$/

export class VerifyOtpDto {
  @Matches(E164)
  phone!: string

  @Matches(SIX_DIGITS)
  code!: string
}
