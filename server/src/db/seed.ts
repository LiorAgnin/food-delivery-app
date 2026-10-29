import path from 'node:path'
import { drizzle } from 'drizzle-orm/node-postgres'
import { Pool } from 'pg'
import { getEnv } from '../config/env'
import {
  type DietaryTag,
  menuCategories,
  menuItems,
  openingHours,
  restaurants,
} from './schema'

type ItemInput = {
  name: string
  description: string
  priceAgorot: number
  dietaryTags?: DietaryTag[]
  isAvailable?: boolean
}

type RestaurantInput = {
  number: number
  name: string
  cuisine: string
  address: string
  isAcceptingOrders: boolean
  minOrderAgorot: number
  deliveryFeeAgorot: number
  categories: Array<{ name: string; items: ItemInput[] }>
}

function fixedUuid (group: 1 | 2 | 3, n: number): string {
  return `${group}0000000-0000-4000-8000-${n.toString(10).padStart(12, '0')}`
}

// Two windows per day cover every local minute, so the only closed restaurant
// is the manual switch. 12:00–00:00 runs until midnight. Alei Gefen (number 1)
// uses a different Sunday split, so hours are not the same on every day.
const ALL_DAY_WINDOWS = [
  { opensAt: '00:00:00', closesAt: '12:00:00' },
  { opensAt: '12:00:00', closesAt: '00:00:00' },
] as const

const SUNDAY_WINDOWS = [
  { opensAt: '00:00:00', closesAt: '18:00:00' },
  { opensAt: '18:00:00', closesAt: '00:00:00' },
] as const

const CATALOG: RestaurantInput[] = [
  {
    number: 1,
    name: 'Alei Gefen',
    cuisine: 'Vegan',
    address: '5 Vital St, Tel Aviv',
    isAcceptingOrders: true,
    minOrderAgorot: 4500,
    deliveryFeeAgorot: 1200,
    categories: [
      {
        name: 'Starters',
        items: [
          {
            name: 'Quinoa tabbouleh',
            description: 'Herbs, lemon, and olive oil',
            priceAgorot: 3400,
            dietaryTags: ['vegan', 'gluten_free'],
          },
          {
            name: 'Sweet potato fries',
            description: 'Crisp fries with tahini',
            priceAgorot: 2800,
            dietaryTags: ['vegan'],
          },
          {
            name: 'Lentil soup',
            description: 'Cumin and lemon',
            priceAgorot: 2600,
            dietaryTags: ['vegan'],
          },
        ],
      },
      {
        name: 'Mains',
        items: [
          {
            name: 'Vegan burger',
            description: 'Chickpea and beet patty, tahini, pickles',
            priceAgorot: 5200,
            dietaryTags: ['vegan'],
          },
          {
            name: 'Lentil and mushroom stew',
            description: 'Brown lentils and oyster mushrooms',
            priceAgorot: 4800,
            dietaryTags: ['vegan'],
          },
          {
            name: 'Tofu sabich plate',
            description: 'Fried tofu, eggplant, and egg-free amba',
            priceAgorot: 5400,
            dietaryTags: ['vegan'],
          },
          {
            name: 'Roasted cauliflower steak',
            description: 'Tahini and pomegranate',
            priceAgorot: 6200,
            dietaryTags: ['vegan'],
          },
        ],
      },
      {
        name: 'Drinks',
        items: [
          {
            name: 'Fresh orange juice',
            description: 'Squeezed to order',
            priceAgorot: 1600,
            dietaryTags: ['vegan'],
          },
          {
            name: 'Oat cappuccino',
            description: 'Espresso with oat milk',
            priceAgorot: 1800,
            dietaryTags: ['vegan'],
          },
          {
            name: 'Soda water',
            description: 'Chilled',
            priceAgorot: 900,
            dietaryTags: ['vegan'],
          },
        ],
      },
    ],
  },
  {
    number: 2,
    name: 'HaTachana Grill',
    cuisine: 'Grill',
    address: '8 HaRakevet St, Tel Aviv',
    isAcceptingOrders: true,
    minOrderAgorot: 5500,
    deliveryFeeAgorot: 1800,
    categories: [
      {
        name: 'Starters',
        items: [
          {
            name: 'Hummus with beef',
            description: 'Warm hummus and beef ragu',
            priceAgorot: 3600,
          },
          {
            name: 'Pickled vegetables',
            description: 'House pickles',
            priceAgorot: 1600,
            dietaryTags: ['vegan'],
          },
          {
            name: 'Grilled eggplant',
            description: 'Tahini and parsley',
            priceAgorot: 2800,
            dietaryTags: ['vegan'],
          },
        ],
      },
      {
        name: 'Mains',
        items: [
          {
            name: 'Spicy chicken skewer',
            description: 'Harissa and amba',
            priceAgorot: 4800,
            dietaryTags: ['spicy'],
          },
          {
            name: 'Spicy chicken schnitzel',
            description: 'Chili crust and chopped salad',
            priceAgorot: 5600,
            dietaryTags: ['spicy'],
          },
          {
            name: 'Spicy chicken platter',
            description: 'Thigh, rice, and salatim',
            priceAgorot: 7600,
            dietaryTags: ['spicy'],
          },
          {
            name: 'Half spicy chicken',
            description: 'Charcoal half chicken',
            priceAgorot: 9200,
            dietaryTags: ['spicy'],
          },
        ],
      },
      {
        name: 'Drinks',
        items: [
          { name: 'Cola', description: 'Can', priceAgorot: 1000 },
          { name: 'Goldstar', description: 'Draft beer', priceAgorot: 2400 },
          {
            name: 'Lemonade',
            description: 'Mint and lemon',
            priceAgorot: 1400,
            dietaryTags: ['vegan'],
          },
        ],
      },
    ],
  },
  {
    number: 3,
    name: 'Sushi Yama',
    cuisine: 'Japanese',
    address: '21 Dizengoff St, Tel Aviv',
    isAcceptingOrders: true,
    minOrderAgorot: 7000,
    deliveryFeeAgorot: 2000,
    categories: [
      {
        name: 'Starters',
        items: [
          {
            name: 'Edamame',
            description: 'Sea salt',
            priceAgorot: 1800,
            dietaryTags: ['vegan'],
          },
          {
            name: 'Wakame salad',
            description: 'Sesame dressing',
            priceAgorot: 2600,
            dietaryTags: ['vegan', 'gluten_free'],
          },
          {
            name: 'Vegetable gyoza',
            description: 'Pan fried',
            priceAgorot: 3400,
            dietaryTags: ['vegan'],
          },
        ],
      },
      {
        name: 'Mains',
        items: [
          {
            name: 'Salmon nigiri',
            description: 'Four pieces',
            priceAgorot: 5200,
            dietaryTags: ['gluten_free'],
          },
          {
            name: 'Spicy tuna roll',
            description: 'Eight pieces',
            priceAgorot: 5800,
            dietaryTags: ['spicy'],
          },
          {
            name: 'Avocado maki',
            description: 'Eight pieces',
            priceAgorot: 3800,
            dietaryTags: ['vegan'],
          },
          {
            name: 'Salmon avocado roll',
            description: 'Eight pieces',
            priceAgorot: 6400,
          },
        ],
      },
      {
        name: 'Drinks',
        items: [
          {
            name: 'Green tea',
            description: 'Sencha',
            priceAgorot: 800,
            dietaryTags: ['vegan'],
          },
          {
            name: 'Ramune',
            description: 'Original',
            priceAgorot: 1400,
            dietaryTags: ['vegan'],
          },
          { name: 'Sake', description: 'Served cold', priceAgorot: 3600 },
        ],
      },
    ],
  },
  {
    number: 4,
    name: 'Trattoria HaYarkon',
    cuisine: 'Italian',
    address: '14 HaYarkon St, Tel Aviv',
    isAcceptingOrders: true,
    minOrderAgorot: 4900,
    deliveryFeeAgorot: 1500,
    categories: [
      {
        name: 'Starters',
        items: [
          {
            name: 'Focaccia',
            description: 'Olive oil and salt',
            priceAgorot: 2400,
            dietaryTags: ['vegetarian'],
          },
          {
            name: 'Caprese',
            description: 'Tomato and mozzarella',
            priceAgorot: 4200,
            dietaryTags: ['vegetarian'],
          },
          {
            name: 'Minestrone',
            description: 'Vegetable soup',
            priceAgorot: 3600,
            dietaryTags: ['vegan'],
          },
        ],
      },
      {
        name: 'Mains',
        items: [
          {
            name: 'Margherita',
            description: 'San Marzano tomato, mozzarella, and basil',
            priceAgorot: 5400,
            dietaryTags: ['vegetarian'],
          },
          {
            name: 'Pepperoni pizza',
            description: 'Tomato, mozzarella, and spicy salami',
            priceAgorot: 6400,
            dietaryTags: ['spicy'],
          },
          {
            name: 'Mushroom risotto',
            description: 'Porcini and parmesan',
            priceAgorot: 5800,
            dietaryTags: ['vegetarian'],
          },
          {
            name: 'White truffle tagliatelle',
            description: 'Seasonal pasta, currently off the line',
            priceAgorot: 12000,
            dietaryTags: ['vegetarian'],
            isAvailable: false,
          },
        ],
      },
      {
        name: 'Drinks',
        items: [
          {
            name: 'Sparkling water',
            description: '500ml',
            priceAgorot: 900,
            dietaryTags: ['vegan'],
          },
          { name: 'House red', description: 'Glass', priceAgorot: 3200 },
          { name: 'Espresso', description: 'Double shot', priceAgorot: 1100 },
        ],
      },
    ],
  },
  {
    number: 5,
    name: 'Falafel HaShuk',
    cuisine: 'Israeli',
    address: '3 HaShuk St, Jerusalem',
    isAcceptingOrders: false,
    minOrderAgorot: 3000,
    deliveryFeeAgorot: 800,
    categories: [
      {
        name: 'Starters',
        items: [
          {
            name: 'Hummus',
            description: 'Whole chickpeas and tahini',
            priceAgorot: 2200,
            dietaryTags: ['vegan'],
          },
          {
            name: 'Matbucha',
            description: 'Tomato and chili',
            priceAgorot: 1600,
            dietaryTags: ['vegan', 'spicy'],
          },
          {
            name: 'Moroccan cigars',
            description: 'Meat filled and fried',
            priceAgorot: 2800,
          },
        ],
      },
      {
        name: 'Mains',
        items: [
          {
            name: 'Falafel in pita',
            description: 'Hummus, salad, and tahini',
            priceAgorot: 2800,
            dietaryTags: ['vegan'],
          },
          {
            name: 'Sabich',
            description: 'Eggplant, egg, and amba',
            priceAgorot: 3800,
            dietaryTags: ['vegetarian'],
          },
          {
            name: 'Shawarma in pita',
            description: 'Turkey shawarma',
            priceAgorot: 4600,
          },
          {
            name: 'Chicken schnitzel pita',
            description: 'Schnitzel, salad, and tahini',
            priceAgorot: 4500,
          },
        ],
      },
      {
        name: 'Drinks',
        items: [
          {
            name: 'Mint lemonade',
            description: 'Fresh mint',
            priceAgorot: 1200,
            dietaryTags: ['vegan'],
          },
          { name: 'Cola', description: 'Can', priceAgorot: 1000 },
          {
            name: 'Turkish coffee',
            description: 'Cardamom',
            priceAgorot: 900,
          },
        ],
      },
    ],
  },
]

const CATEGORY_SORT_ORDER: Record<string, number> = {
  Starters: 0,
  Mains: 1,
  Drinks: 2,
}

// Response order is open-first, then by name. Insert the closed restaurant
// first and the open ones out of alphabetical order.
const RESTAURANT_INSERT_ORDER = [5, 4, 3, 2, 1]

// sort_order stays 0/1/2. Drinks are inserted before Starters.
const CATEGORY_INSERT_ORDER = ['Drinks', 'Starters', 'Mains']

function restaurantsInInsertOrder (): RestaurantInput[] {
  return RESTAURANT_INSERT_ORDER.map((number) => {
    const restaurant = CATALOG.find((item) => item.number === number)
    if (!restaurant) throw new Error(`Missing seeded restaurant ${number}`)
    return restaurant
  })
}

function categoriesInInsertOrder (
  categories: RestaurantInput['categories'],
): RestaurantInput['categories'] {
  return CATEGORY_INSERT_ORDER.map((name) => {
    const category = categories.find((item) => item.name === name)
    if (!category) throw new Error(`Missing seeded category ${name}`)
    return category
  })
}

function categorySortOrder (name: string): number {
  const sortOrder = CATEGORY_SORT_ORDER[name]
  if (sortOrder === undefined) throw new Error(`Missing sort order for ${name}`)
  return sortOrder
}

function windowsFor (
  restaurantNumber: number,
  dayOfWeek: number,
): ReadonlyArray<{ opensAt: string; closesAt: string }> {
  if (restaurantNumber === 1 && dayOfWeek === 0) return SUNDAY_WINDOWS
  return ALL_DAY_WINDOWS
}

export async function seed (): Promise<void> {
  const env = getEnv()
  const pool = new Pool({ connectionString: env.DATABASE_URL })
  const db = drizzle(pool)
  try {
    await db.transaction(async (tx) => {
      const seeded = restaurantsInInsertOrder()

      await tx
        .insert(restaurants)
        .values(
          seeded.map((restaurant) => ({
            id: fixedUuid(1, restaurant.number),
            name: restaurant.name,
            cuisine: restaurant.cuisine,
            address: restaurant.address,
            timezone: 'Asia/Jerusalem',
            isAcceptingOrders: restaurant.isAcceptingOrders,
            minOrderAgorot: restaurant.minOrderAgorot,
            deliveryFeeAgorot: restaurant.deliveryFeeAgorot,
          })),
        )
        .onConflictDoNothing()

      await tx
        .insert(openingHours)
        .values(
          seeded.flatMap((restaurant) =>
            [0, 1, 2, 3, 4, 5, 6].flatMap((dayOfWeek) =>
              windowsFor(restaurant.number, dayOfWeek).map((window) => ({
                restaurantId: fixedUuid(1, restaurant.number),
                dayOfWeek,
                opensAt: window.opensAt,
                closesAt: window.closesAt,
              })),
            ),
          ),
        )
        .onConflictDoNothing()

      await tx
        .insert(menuCategories)
        .values(
          seeded.flatMap((restaurant) =>
            categoriesInInsertOrder(restaurant.categories).map((category) => {
              const sortOrder = categorySortOrder(category.name)
              return {
                id: fixedUuid(2, restaurant.number * 10 + sortOrder + 1),
                restaurantId: fixedUuid(1, restaurant.number),
                name: category.name,
                sortOrder,
              }
            }),
          ),
        )
        .onConflictDoNothing()

      await tx
        .insert(menuItems)
        .values(
          seeded.flatMap((restaurant) =>
            categoriesInInsertOrder(restaurant.categories).flatMap(
              (category) => {
                const sortOrder = categorySortOrder(category.name)
                return category.items.map((item, itemIndex) => ({
                  id: fixedUuid(
                    3,
                    restaurant.number * 100 + sortOrder * 20 + itemIndex + 1,
                  ),
                  restaurantId: fixedUuid(1, restaurant.number),
                  categoryId: fixedUuid(
                    2,
                    restaurant.number * 10 + sortOrder + 1,
                  ),
                  name: item.name,
                  description: item.description,
                  priceAgorot: item.priceAgorot,
                  dietaryTags: item.dietaryTags ?? [],
                  isAvailable: item.isAvailable ?? true,
                }))
              },
            ),
          ),
        )
        .onConflictDoNothing()
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
  seed()
    .then(() => {
      console.log('seed applied')
    })
    .catch((error: unknown) => {
      console.error(error)
      process.exit(1)
    })
}
