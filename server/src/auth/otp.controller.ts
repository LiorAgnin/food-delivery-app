import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  UseGuards,
} from '@nestjs/common'
import type { AuthenticatedCustomer } from './authenticated-request'
import { CurrentCustomer } from './current-customer.decorator'
import { RequestOtpDto } from './dto/request-otp.dto'
import { VerifyOtpDto } from './dto/verify-otp.dto'
import { JwtAuthGuard } from './jwt-auth.guard'
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

  @Get('me')
  @UseGuards(JwtAuthGuard)
  me (@CurrentCustomer() customer: AuthenticatedCustomer): { id: string } {
    return { id: customer.id }
  }
}
