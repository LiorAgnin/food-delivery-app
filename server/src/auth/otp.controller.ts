import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common'
import { RequestOtpDto } from './dto/request-otp.dto'
import { VerifyOtpDto } from './dto/verify-otp.dto'
import { OtpService } from './otp.service'

@Controller('auth')
export class OtpController {
  constructor (private readonly otp: OtpService) {}

  @Post('otp/request')
  @HttpCode(HttpStatus.ACCEPTED)
  request (@Body() body: RequestOtpDto) {
    return this.otp.request(body.phone)
  }

  @Post('otp/verify')
  @HttpCode(HttpStatus.OK)
  verify (@Body() body: VerifyOtpDto) {
    return this.otp.verify(body.phone, body.code)
  }
}
