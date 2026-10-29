import { Controller, Get, Param } from '@nestjs/common'
import { ParseUuidPipe } from '../common/parse-uuid.pipe'
import { RestaurantsService } from './restaurants.service'

@Controller('restaurants')
export class RestaurantsController {
  constructor (private readonly restaurants: RestaurantsService) {}

  @Get()
  list () {
    return this.restaurants.list()
  }

  @Get(':id/menu')
  menu (@Param('id', ParseUuidPipe) id: string) {
    return this.restaurants.menu(id)
  }
}
