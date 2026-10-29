import { Module } from '@nestjs/common'
import { AuthModule } from '../auth/auth.module'
import { DatabaseModule } from '../db/database.module'
import { DishFinderController } from './dish-finder.controller'
import { DISH_FINDER_FETCH, DishFinderService } from './dish-finder.service'
import { DishSearchRepository } from './dish-search.repository'

@Module({
  imports: [DatabaseModule, AuthModule],
  controllers: [DishFinderController],
  providers: [
    DishFinderService,
    DishSearchRepository,
    {
      provide: DISH_FINDER_FETCH,
      useValue: (
        input: Parameters<typeof fetch>[0],
        init?: Parameters<typeof fetch>[1],
      ) => globalThis.fetch(input, init),
    },
  ],
})
export class DishFinderModule {}
