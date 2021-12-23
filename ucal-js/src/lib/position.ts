import { Timeframe } from "../types/Calendar"

export const scrollToSelectedDay =
  (timeframe: Timeframe, selectedDay: Date) => (ref) => {
    if (ref) {
      switch (timeframe) {
        case Timeframe.month:
          ref.scrollTop = Math.floor(selectedDay.getDate() / 7) * 102
          break
        case Timeframe.year:
          ref.scrollTop = Math.floor(selectedDay.getMonth() / 2) * 266
          break
        default:
          ref.scrollTop = Math.floor(new Date().getHours()) * 99
          break
      }
    }
  }
