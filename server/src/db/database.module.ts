import { Inject, Logger, Module, type OnModuleDestroy } from '@nestjs/common'
import { drizzle, type NodePgDatabase } from 'drizzle-orm/node-postgres'
import { Pool } from 'pg'
import { getEnv } from '../config/env'
import * as schema from './schema'

export const DRIZZLE = 'DRIZZLE'
export const PG_POOL = 'PG_POOL'

export type Database = NodePgDatabase<typeof schema>

export class DatabaseLifecycle implements OnModuleDestroy {
  constructor (@Inject(PG_POOL) private readonly pool: Pool) {}

  async onModuleDestroy (): Promise<void> {
    await this.pool.end()
  }
}

@Module({
  providers: [
    {
      provide: PG_POOL,
      useFactory: (): Pool => {
        const env = getEnv()
        const pool = new Pool({ connectionString: env.DATABASE_URL })
        const logger = new Logger('PostgresPool')
        pool.on('error', (error: Error) => {
          logger.error(error.message, error.stack)
        })
        return pool
      },
    },
    {
      provide: DRIZZLE,
      inject: [PG_POOL],
      useFactory: (pool: Pool): Database => drizzle(pool, { schema }),
    },
    DatabaseLifecycle,
  ],
  exports: [DRIZZLE],
})
export class DatabaseModule {}
