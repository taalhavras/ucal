import moment from 'moment'
import { Timeframe } from '../types/Calendar'
import Event from '../types/Event'

const daysInYear = (year: number) => (year % 400 === 0 || (year % 100 !== 0 && year % 4 === 0)) ? 366 : 365

export const addDays = (day: Date, days: number) : Date => moment(day).add(days, 'days').toDate()

export const getFirstOfWeek = (day: Date) : Date => moment(day).subtract(day.getDay(), 'days').toDate();

export const getLastOfWeek = (day: Date) : Date => moment(day).add(6 - day.getDay(), 'days').toDate();

export const spansMonths = (day: Date) : boolean => getFirstOfWeek(day).getMonth() !== day.getMonth() || getLastOfWeek(day).getMonth() !== day.getMonth()

export const getWeekDays = (currentDay: Date) : Date[] => {
  const firstDay = moment(getFirstOfWeek(currentDay))
  const days = [firstDay.toDate()]

  for(let i = 0; i < 6; i++) {
    days.push(firstDay.add(1, 'days').toDate())
  }
  return days
}

export const getMonthDays = (year: number, month: number, excludeExtra?: boolean) : Date[][] => {
  const firstDay = moment(getFirstOfWeek(new Date(year, month, 1)))
  const days = [[firstDay.toDate()]]

  for(let i = 1; i < 42; i++) {
    if (i % 7 === 0) {
      days.push([])
    }
    days[Math.floor(i / 7)].push(firstDay.add(1, 'days').toDate())
  }
  if (excludeExtra && days[5] && days[5][0].getMonth() !== month) {
    days.pop()
  }
  return days
}

export const getHours = () : number[] => [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]

export const padTime = (time: number) => time.toString().padStart(2, '0')

export const getQuarterHours = () : string[] => {
  const increments : string[] = []
  for (let i = 0; i < 24; i++) {
    for (let j = 0; j < 60; j += 15) {
      increments.push(`${padTime(i)}:${padTime(j)}`)
    }
  }
  return increments
}

export const getDefaultStartEndTimes = () : { startTime: string, endTime: string } => {
  const toAdd = 15 - (moment().minutes() % 15)

  return {
    startTime: moment().add(toAdd, 'minutes').format('HH:mm'),
    endTime: moment().add(toAdd + 30, 'minutes').format('HH:mm'),
  }
}

export const isSameDay = (one: Date, two: Date) : boolean => moment(one).isSame(moment(two), 'day')

export const sameMonthDay = (one: Date, two: Date) : boolean => `${one.getMonth()}${one.getDate()}` === `${two.getMonth()}${two.getDate()}`

export const getHoursMinutes = (date: Date) : string => moment(date).format('HH:mm')
