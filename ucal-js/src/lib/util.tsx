export function createStorageKey(name: string): string {
  return `~${window.ship}/${window.desk}/${name}`
}

// for purging storage with version updates
export function clearStorageMigration<T>() {
  return {} as T
}

export const storageVersion = parseInt(process.env.UCAL_STORAGE_VERSION, 10)
