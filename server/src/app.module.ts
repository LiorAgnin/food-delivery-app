import { Module } from '@nestjs/common'
import { AuthModule } from './auth/auth.module'
import { DatabaseModule } from './db/database.module'
import { DishFinderModule } from './dish-finder/dish-finder.module'
import { HealthModule } from './health/health.module'
import { OrdersModule } from './orders/orders.module'
import { RestaurantsModule } from './restaurants/restaurants.module'

@Module({
  imports: [
    DatabaseModule,
    AuthModule,
    HealthModule,
    RestaurantsModule,
    OrdersModule,
    DishFinderModule,
  ],
})
export class AppModule {}
