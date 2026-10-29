import { Inject, Injectable } from '@nestjs/common'
import { asc, eq } from 'drizzle-orm'
import { DomainError } from '../common/domain-error'
import { DRIZZLE, type Database } from '../db/database.module'
import {
  DIETARY_TAGS,
  type DietaryTag,
  type MenuItemRow,
  type OpeningHourRow,
  type RestaurantRow,
  menuCategories,
  menuItems,
  openingHours,
  restaurants,
} from '../db/schema'
import { formatTimeOfDay, isOpenNow } from './is-open-now'

export type OpeningHoursResponse = {
  dayOfWeek: number
  opensAt: string
  closesAt: string
}

export type RestaurantResponse = {
  id: string
  name: string
  cuisine: string
  address: string
  isOpen: boolean
  openingHours: OpeningHoursResponse[]
  minOrderAgorot: number
  deliveryFeeAgorot: number
}

export type MenuItemResponse = {
  id: string
  restaurantId: string
  categoryId: string
  name: string
  description: string
  priceAgorot: number
  dietaryTags: DietaryTag[]
  isAvailable: boolean
}

export type MenuCategoryResponse = {
  id: string
  name: string
  items: MenuItemResponse[]
}

const allowedTags = new Set<string>(DIETARY_TAGS)

@Injectable()
export class RestaurantsService {
  constructor (@Inject(DRIZZLE) private readonly db: Database) {}

  async list (now = new Date()): Promise<{ restaurants: RestaurantResponse[] }> {
    const [restaurantRows, hourRows] = await Promise.all([
      this.db.select().from(restaurants),
      this.db.select().from(openingHours),
    ])
    const hoursByRestaurant = groupHours(hourRows)
    const result = restaurantRows.map((row) =>
      toRestaurant(row, hoursByRestaurant.get(row.id) ?? [], now),
    )
    result.sort((left, right) => {
      if (left.isOpen !== right.isOpen) return left.isOpen ? -1 : 1
      return left.name.localeCompare(right.name, 'en')
    })
    return { restaurants: result }
  }

  async menu (
    id: string,
    now = new Date(),
  ): Promise<{
    restaurant: RestaurantResponse
    categories: MenuCategoryResponse[]
  }> {
    const [restaurant] = await this.db
      .select()
      .from(restaurants)
      .where(eq(restaurants.id, id))
    if (!restaurant) {
      throw new DomainError('NOT_FOUND', 'Restaurant not found')
    }

    const [hourRows, categoryRows, itemRows] = await Promise.all([
      this.db
        .select()
        .from(openingHours)
        .where(eq(openingHours.restaurantId, id)),
      this.db
        .select()
        .from(menuCategories)
        .where(eq(menuCategories.restaurantId, id))
        .orderBy(asc(menuCategories.sortOrder), asc(menuCategories.name)),
      this.db
        .select()
        .from(menuItems)
        .where(eq(menuItems.restaurantId, id))
        .orderBy(asc(menuItems.name), asc(menuItems.id)),
    ])

    const itemsByCategory = new Map<string, MenuItemResponse[]>()
    for (const item of itemRows) {
      const list = itemsByCategory.get(item.categoryId) ?? []
      list.push(toMenuItem(item))
      itemsByCategory.set(item.categoryId, list)
    }

    return {
      restaurant: toRestaurant(restaurant, hourRows, now),
      categories: categoryRows.map((category) => ({
        id: category.id,
        name: category.name,
        items: itemsByCategory.get(category.id) ?? [],
      })),
    }
  }
}

function groupHours (rows: OpeningHourRow[]): Map<string, OpeningHourRow[]> {
  const grouped = new Map<string, OpeningHourRow[]>()
  for (const row of rows) {
    const list = grouped.get(row.restaurantId) ?? []
    list.push(row)
    grouped.set(row.restaurantId, list)
  }
  return grouped
}

function toRestaurant (
  row: RestaurantRow,
  hours: OpeningHourRow[],
  now: Date,
): RestaurantResponse {
  const openingHoursResponse = [...hours]
    .sort(
      (left, right) =>
        left.dayOfWeek - right.dayOfWeek ||
        left.opensAt.localeCompare(right.opensAt),
    )
    .map((hour) => ({
      dayOfWeek: hour.dayOfWeek,
      opensAt: formatTimeOfDay(hour.opensAt),
      closesAt: formatTimeOfDay(hour.closesAt),
    }))

  return {
    id: row.id,
    name: row.name,
    cuisine: row.cuisine,
    address: row.address,
    isOpen: isOpenNow(row, hours, now),
    openingHours: openingHoursResponse,
    minOrderAgorot: row.minOrderAgorot,
    deliveryFeeAgorot: row.deliveryFeeAgorot,
  }
}

function toMenuItem (item: MenuItemRow): MenuItemResponse {
  return {
    id: item.id,
    restaurantId: item.restaurantId,
    categoryId: item.categoryId,
    name: item.name,
    description: item.description,
    priceAgorot: item.priceAgorot,
    dietaryTags: item.dietaryTags.filter((tag): tag is DietaryTag =>
      allowedTags.has(tag),
    ),
    isAvailable: item.isAvailable,
  }
}
