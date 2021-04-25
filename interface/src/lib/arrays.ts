import { find } from "lodash"

export const addOrRemove = <T extends unknown>(list: T[], value: T) : T[] => {
  if (list.includes(value)) {
    return list.filter((ele) => ele !== value)
  } else {
    return list.concat([value])
  }
}

export const arraysMatch = <T extends unknown>(one: T[], two: T[]) : boolean => {
  return one.length === two.length &&
    one.reduce((acc : boolean, cur : T) : boolean => two.includes(cur) && acc, true)
}
