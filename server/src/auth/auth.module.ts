import { Module } from '@nestjs/common'
import { JwtModule } from '@nestjs/jwt'
import { randomInt } from 'node:crypto'
import { getEnv } from '../config/env'
import { DatabaseModule } from '../db/database.module'
import { Clock } from './clock'
import { JwtAuthGuard } from './jwt-auth.guard'
import { OtpController } from './otp.controller'
import { OtpCodeGenerator, OtpPolicy } from './otp-policy'
import { OTP_DEV_MODE, OtpService } from './otp.service'
import { ACCESS_TOKEN_TTL_SECONDS, TokenService } from './token.service'

@Module({
  imports: [
    DatabaseModule,
    JwtModule.registerAsync({
      useFactory: () => {
        const env = getEnv()
        return {
          secret: env.JWT_SECRET,
          signOptions: {
            algorithm: 'HS256' as const,
            expiresIn: ACCESS_TOKEN_TTL_SECONDS,
          },
          verifyOptions: {
            algorithms: ['HS256' as const],
          },
        }
      },
    }),
  ],
  controllers: [OtpController],
  providers: [
    TokenService,
    JwtAuthGuard,
    Clock,
    {
      provide: OtpCodeGenerator,
      useFactory: (): OtpCodeGenerator =>
        new OtpCodeGenerator(getEnv().OTP_DEV_MODE, (min, max) =>
          randomInt(min, max),
        ),
    },
    {
      provide: OtpPolicy,
      inject: [Clock, OtpCodeGenerator],
      useFactory: (clock: Clock, codes: OtpCodeGenerator): OtpPolicy =>
        new OtpPolicy(clock, codes, getEnv().JWT_SECRET),
    },
    {
      provide: OTP_DEV_MODE,
      useFactory: (): boolean => getEnv().OTP_DEV_MODE,
    },
    OtpService,
  ],
  exports: [TokenService, JwtAuthGuard, JwtModule],
})
export class AuthModule {}
