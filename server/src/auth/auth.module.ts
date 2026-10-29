import { Module } from '@nestjs/common'
import { JwtModule } from '@nestjs/jwt'
import { getEnv } from '../config/env'
import { JwtAuthGuard } from './jwt-auth.guard'
import { ACCESS_TOKEN_TTL_SECONDS, TokenService } from './token.service'

@Module({
  imports: [
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
  providers: [TokenService, JwtAuthGuard],
  exports: [TokenService, JwtAuthGuard, JwtModule],
})
export class AuthModule {}
