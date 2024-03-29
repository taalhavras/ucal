export const capitalize = (word: string) =>
  word[0].toUpperCase() + word.substring(1)

export const warnError = (prefix: string) => (error: any) =>
  console.warn(prefix, error)

export const formatShip = (ship: string) =>
  ship[0] === "~" ? ship : `~${ship}`
