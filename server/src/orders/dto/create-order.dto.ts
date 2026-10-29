import { Transform, Type } from 'class-transformer'
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
  @Transform(lowercaseUuid)
  @IsUUID('4')
  menuItemId!: string

  @IsInt()
  @Min(1)
  @Max(50)
  quantity!: number
}

export class CreateOrderDto {
  @Transform(lowercaseUuid)
  @IsUUID('4')
  restaurantId!: string

  @ArrayMinSize(1)
  @ArrayMaxSize(50)
  @ValidateNested({ each: true })
  @Type(() => CreateOrderItemDto)
  items!: CreateOrderItemDto[]
}

function lowercaseUuid ({ value }: { value: unknown }): unknown {
  return typeof value === 'string' ? value.toLowerCase() : value
}
