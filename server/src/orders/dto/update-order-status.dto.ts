import { IsIn } from 'class-validator'
import {
  ACTORS,
  ORDER_STATUSES,
  type Actor,
  type OrderStatus,
} from '../order-lifecycle'

export class UpdateOrderStatusDto {
  @IsIn([...ORDER_STATUSES])
  status!: OrderStatus

  @IsIn([...ACTORS])
  actor!: Actor
}
