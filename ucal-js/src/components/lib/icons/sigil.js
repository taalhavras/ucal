import React from "react"
import { sigil, reactRenderer } from "urbit-sigil-js"

export const Sigil = ({ size, color, ship, classes = "" }) => {
  if (ship.length > 14) {
    return (
      <div
        className={"bg-black dib " + classes}
        style={{ width: size, height: size }}
      />
    )
  } else {
    return (
      <div
        className={"dib " + classes}
        style={{ flexBasis: 32, backgroundColor: color }}
      >
        {sigil({
          patp: ship,
          renderer: reactRenderer,
          size: size,
          colors: [color, "white"],
        })}
      </div>
    )
  }
}
