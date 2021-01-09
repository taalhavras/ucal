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
