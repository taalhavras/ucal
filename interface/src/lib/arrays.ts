import { find } from "lodash"

export const addOrRemove = <T extends unknown>(list: T[], value: T) : T[] => {
  if (list.includes(value)) {
    return list.filter((ele) => ele !== value)
  } else {
    return list.concat([value])
  }
}
