import React, { MouseEvent } from "react"
import { Box } from "@tlon/indigo-react"

export const DropdownBackground = ({ onClick }: { onClick: () => void }) => {
  return (
    <Box
      onClick={(e: MouseEvent) => {
        e.preventDefault()
        e.stopPropagation()
        onClick()
      }}
      position="fixed"
      top="0"
      bottom="0"
      right="0"
      left="0"
      background="transparent"
    />
  )
}
