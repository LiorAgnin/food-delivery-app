import { Matches } from 'class-validator'

const E164 = /^\+[1-9]\d{1,14}$/

export class RequestOtpDto {
  @Matches(E164)
  phone!: string
}
