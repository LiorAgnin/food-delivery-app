import { Type } from 'class-transformer'
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsIn,
  IsString,
  MaxLength,
  Validate,
  ValidateNested,
  ValidatorConstraint,
  type ValidatorConstraintInterface,
} from 'class-validator'

export class ChatMessageDto {
  @IsIn(['user', 'assistant'])
  role!: 'user' | 'assistant'

  @IsString()
  @MaxLength(500)
  content!: string
}

@ValidatorConstraint({ name: 'lastMessageIsUser', async: false })
export class LastMessageIsUserConstraint implements ValidatorConstraintInterface {
  validate (value: unknown): boolean {
    if (!Array.isArray(value) || value.length === 0) return false
    const last: unknown = value[value.length - 1]
    return (
      typeof last === 'object' &&
      last !== null &&
      'role' in last &&
      last.role === 'user'
    )
  }

  defaultMessage (): string {
    return 'last message must have role user'
  }
}

export class SearchDishFinderDto {
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(20)
  @ValidateNested({ each: true })
  @Type(() => ChatMessageDto)
  @Validate(LastMessageIsUserConstraint)
  messages!: ChatMessageDto[]
}
