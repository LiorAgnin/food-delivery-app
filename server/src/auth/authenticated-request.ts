export type AuthenticatedCustomer = { id: string }

export type RequestWithCustomer = {
  headers: { authorization?: string | string[] }
  customer?: AuthenticatedCustomer
}
