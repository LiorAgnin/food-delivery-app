import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  Post,
  UseGuards,
} from '@nestjs/common'
import { JwtAuthGuard } from '../auth/jwt-auth.guard'
import {
  DishFinderService,
  type DishFinderResponse,
} from './dish-finder.service'
import { SearchDishFinderDto } from './dto/search-dish-finder.dto'

@Controller('dish-finder')
@UseGuards(JwtAuthGuard)
export class DishFinderController {
  constructor (private readonly dishFinder: DishFinderService) {}

  @Post('search')
  @HttpCode(HttpStatus.OK)
  search (@Body() body: SearchDishFinderDto): Promise<DishFinderResponse> {
    return this.dishFinder.search(body.messages)
  }
}
