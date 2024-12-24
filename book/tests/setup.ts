// tests/setup.ts
import { beforeAll, afterAll } from 'vitest'
import { Chain } from '@stacks/network'

beforeAll(async () => {
  // Any global setup needed before tests
  console.log('Setting up test environment...')
})

afterAll(async () => {
  // Cleanup after tests
  console.log('Cleaning up test environment...')
})
