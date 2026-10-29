import { Injectable } from '@nestjs/common'

@Injectable()
export class Clock {
  private offsetMs = 0

  now (): Date {
    return new Date(Date.now() + this.offsetMs)
  }

  advance (milliseconds: number): void {
    this.offsetMs += milliseconds
  }
}
