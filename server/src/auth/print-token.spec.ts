import { readPhoneArg } from './print-token'

describe('readPhoneArg', () => {
  const argv = ['node', 'print-token.ts']

  it('rejects a missing phone', () => {
    expect(() => readPhoneArg(argv)).toThrow(
      'usage: npm run token -- <E.164 phone>',
    )
  })

  it('rejects a phone that is not E.164', () => {
    expect(() => readPhoneArg([...argv, '0501234567'])).toThrow(
      'usage: npm run token -- <E.164 phone>',
    )
  })

  it('returns an E.164 phone', () => {
    expect(readPhoneArg([...argv, '+972501234567'])).toBe('+972501234567')
  })
})
