import fs from 'node:fs'
import path from 'node:path'
import { drizzle } from 'drizzle-orm/node-postgres'
import { migrate as applyMigrations } from 'drizzle-orm/node-postgres/migrator'
import { Pool } from 'pg'
import { getEnv } from '../config/env'

export function migrationsFolder (): string {
  const candidates = [
    path.resolve(__dirname, '../../drizzle'),
    path.resolve(process.cwd(), 'drizzle'),
  ]
  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) return candidate
  }
  throw new Error(
    `Migrations folder not found. Looked in ${candidates.join(', ')}`,
  )
}

export async function migrate (): Promise<void> {
  const env = getEnv()
  const pool = new Pool({ connectionString: env.DATABASE_URL })
  try {
    await applyMigrations(drizzle(pool), {
      migrationsFolder: migrationsFolder(),
    })
  } finally {
    await pool.end()
  }
}

function isDirectRun (): boolean {
  const entry = process.argv[1]
  if (!entry) return false
  return path.resolve(entry) === path.resolve(__filename)
}

if (isDirectRun()) {
  migrate()
    .then(() => {
      console.log('migrations applied')
    })
    .catch((error: unknown) => {
      console.error(error)
      process.exit(1)
    })
}
