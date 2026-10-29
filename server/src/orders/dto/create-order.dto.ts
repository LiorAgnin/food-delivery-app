import { Type } from 'class-transformer'
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsInt,
  IsUUID,
  Max,
  Min,
  ValidateNested,
} from 'class-validator'

export class CreateOrderItemDto {
  @IsUUID('4')
  menuItemId!: string

  @IsInt()
  @Min(1)
  @Max(50)
  quantity!: number
}

export class CreateOrderDto {
  @IsUUID('4')
  restaurantId!: string

  @ArrayMinSize(1)
  @ArrayMaxSize(50)
  @ValidateNested({ each: true })
  @Type(() => CreateOrderItemDto)
  items!: CreateOrderItemDto[]
}
