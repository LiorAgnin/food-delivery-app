import { Inject, Injectable } from '@nestjs/common'
import { and, eq, inArray, or, sql, type SQL } from 'drizzle-orm'
import { DRIZZLE, type Database } from '../db/database.module'
import {
  DIETARY_TAGS,
  type DietaryTag,
  menuCategories,
  menuItems,
  openingHours,
  restaurants,
} from '../db/schema'
import { isOpenNow, type OpeningHourWindow } from '../restaurants/is-open-now'
import type { SearchIntent } from './search-intent'

export type DishResult = {
  menuItem: {
    id: string
    restaurantId: string
    categoryId: string
    name: string
    description: string
    priceAgorot: number
    dietaryTags: DietaryTag[]
    isAvailable: boolean
  }
  restaurant: {
    id: string
    name: string
    cuisine: string
    isOpen: boolean
  }
  orderable: boolean
}

type Candidate = {
  id: string
  restaurantId: string
  categoryId: string
  name: string
  description: string
  priceAgorot: number
  dietaryTags: string[]
  isAvailable: boolean
  restaurantName: string
  cuisine: string
  isAcceptingOrders: boolean
  timezone: string
  categoryName: string
}

const allowedTags = new Set<string>(DIETARY_TAGS)
const RESULT_LIMIT = 10

@Injectable()
export class DishSearchRepository {
  constructor (@Inject(DRIZZLE) private readonly db: Database) {}

  async search (intent: SearchIntent, now: Date): Promise<DishResult[]> {
    const filters = filtersFor(intent)
    const rows = await this.db
      .select({
        id: menuItems.id,
        restaurantId: menuItems.restaurantId,
        categoryId: menuItems.categoryId,
        name: menuItems.name,
        description: menuItems.description,
        priceAgorot: menuItems.priceAgorot,
        dietaryTags: menuItems.dietaryTags,
        isAvailable: menuItems.isAvailable,
        restaurantName: restaurants.name,
        cuisine: restaurants.cuisine,
        isAcceptingOrders: restaurants.isAcceptingOrders,
        timezone: restaurants.timezone,
        categoryName: menuCategories.name,
      })
      .from(menuItems)
      .innerJoin(restaurants, eq(menuItems.restaurantId, restaurants.id))
      .innerJoin(menuCategories, eq(menuItems.categoryId, menuCategories.id))
      .where(filters.length > 0 ? and(...filters) : undefined)

    const restaurantIds = [...new Set(rows.map((row) => row.restaurantId))]
    const hoursByRestaurant = await this.hoursFor(restaurantIds)

    // Open-now stays in process. The seeded menu is small, and isOpenNow
    // already owns the midnight-window rules, so the match query does not
    // reimplement them in SQL.
    const ranked = rows
      .map((row) => toRanked(row, hoursByRestaurant, intent, now))
      .filter((row) => row.score > 0 || intent.keywords.length === 0)
      .filter((row) => !intent.openNowOnly || row.result.restaurant.isOpen)
      .sort((left, right) => compareResults(left, right, intent.sort))

    return ranked.slice(0, RESULT_LIMIT).map((row) => row.result)
  }

  private async hoursFor (
    restaurantIds: readonly string[],
  ): Promise<Map<string, OpeningHourWindow[]>> {
    const grouped = new Map<string, OpeningHourWindow[]>()
    if (restaurantIds.length === 0) return grouped
    const rows = await this.db
      .select()
      .from(openingHours)
      .where(inArray(openingHours.restaurantId, [...restaurantIds]))
    for (const row of rows) {
      const list = grouped.get(row.restaurantId) ?? []
      list.push({
        dayOfWeek: row.dayOfWeek,
        opensAt: row.opensAt,
        closesAt: row.closesAt,
      })
      grouped.set(row.restaurantId, list)
    }
    return grouped
  }
}

function filtersFor (intent: SearchIntent): SQL[] {
  const filters: SQL[] = []
  if (intent.keywords.length > 0) {
    const keywordFilter = or(
      ...intent.keywords.map((keyword) => keywordMatches(keyword)),
    )
    if (keywordFilter) filters.push(keywordFilter)
  }
  for (const keyword of intent.excludeKeywords) {
    const pattern = likePattern(keyword)
    filters.push(sql`(
      ${menuItems.name} NOT ILIKE ${pattern} ESCAPE '\\'
      AND ${menuItems.description} NOT ILIKE ${pattern} ESCAPE '\\'
    )`)
  }
  if (intent.includeTags.length > 0) {
    filters.push(
      sql`${menuItems.dietaryTags} @> ${textArray(intent.includeTags)}`,
    )
  }
  if (intent.excludeTags.length > 0) {
    filters.push(
      sql`NOT (${menuItems.dietaryTags} && ${textArray(intent.excludeTags)})`,
    )
  }
  if (intent.maxPriceAgorot != null) {
    filters.push(sql`${menuItems.priceAgorot} <= ${intent.maxPriceAgorot}`)
  }
  if (intent.cuisines.length > 0) {
    const cuisineFilter = or(
      ...intent.cuisines.map(
        (cuisine) =>
          sql`lower(${restaurants.cuisine}) = ${cuisine.toLowerCase()}`,
      ),
    )
    if (cuisineFilter) filters.push(cuisineFilter)
  }
  return filters
}

function keywordMatches (keyword: string): SQL {
  const pattern = likePattern(keyword)
  // Restaurant name is included so "sushi" still hits Sushi Yama when an
  // item's own copy does not say sushi. Rows still come only from the menu.
  return sql`(
    ${menuItems.name} ILIKE ${pattern} ESCAPE '\\'
    OR ${menuItems.description} ILIKE ${pattern} ESCAPE '\\'
    OR ${menuCategories.name} ILIKE ${pattern} ESCAPE '\\'
    OR ${restaurants.cuisine} ILIKE ${pattern} ESCAPE '\\'
    OR ${restaurants.name} ILIKE ${pattern} ESCAPE '\\'
  )`
}

function likePattern (keyword: string): string {
  const escaped = keyword.replace(/[\\%_]/g, (char) => `\\${char}`)
  return `%${escaped}%`
}

function textArray (values: readonly string[]): SQL {
  return sql`ARRAY[${sql.join(
    values.map((value) => sql`${value}`),
    sql`, `,
  )}]::text[]`
}

type Ranked = {
  result: DishResult
  score: number
}

function toRanked (
  row: Candidate,
  hoursByRestaurant: Map<string, OpeningHourWindow[]>,
  intent: SearchIntent,
  now: Date,
): Ranked {
  const hours = hoursByRestaurant.get(row.restaurantId) ?? []
  const isOpen = isOpenNow(
    { isAcceptingOrders: row.isAcceptingOrders, timezone: row.timezone },
    hours,
    now,
  )
  const result: DishResult = {
    menuItem: {
      id: row.id,
      restaurantId: row.restaurantId,
      categoryId: row.categoryId,
      name: row.name,
      description: row.description,
      priceAgorot: row.priceAgorot,
      dietaryTags: row.dietaryTags.filter((tag): tag is DietaryTag =>
        allowedTags.has(tag),
      ),
      isAvailable: row.isAvailable,
    },
    restaurant: {
      id: row.restaurantId,
      name: row.restaurantName,
      cuisine: row.cuisine,
      isOpen,
    },
    orderable: row.isAvailable && isOpen,
  }
  return {
    result,
    score: keywordScore(row, intent.keywords),
  }
}

function keywordScore (row: Candidate, keywords: readonly string[]): number {
  const name = row.name.toLowerCase()
  const fields = [
    name,
    row.description.toLowerCase(),
    row.categoryName.toLowerCase(),
    row.cuisine.toLowerCase(),
    row.restaurantName.toLowerCase(),
  ]
  let score = 0
  for (const keyword of keywords) {
    const needle = keyword.toLowerCase()
    if (fields.some((field) => field.includes(needle))) score += 1
    if (name.includes(needle)) score += 1
  }
  return score
}

function compareResults (
  left: Ranked,
  right: Ranked,
  sort: SearchIntent['sort'],
): number {
  if (left.result.orderable !== right.result.orderable) {
    return left.result.orderable ? -1 : 1
  }
  if (
    sort === 'price_asc' &&
    left.result.menuItem.priceAgorot !== right.result.menuItem.priceAgorot
  ) {
    return left.result.menuItem.priceAgorot - right.result.menuItem.priceAgorot
  }
  if (left.score !== right.score) return right.score - left.score
  const byName = left.result.menuItem.name.localeCompare(
    right.result.menuItem.name,
    'en',
  )
  if (byName !== 0) return byName
  return left.result.menuItem.id.localeCompare(right.result.menuItem.id)
}
