import { Module } from '@nestjs/common'
import { AuthModule } from './auth/auth.module'
import { DatabaseModule } from './db/database.module'
import { HealthModule } from './health/health.module'
import { RestaurantsModule } from './restaurants/restaurants.module'

@Module({
  imports: [DatabaseModule, AuthModule, HealthModule, RestaurantsModule],
})
export class AppModule {}
