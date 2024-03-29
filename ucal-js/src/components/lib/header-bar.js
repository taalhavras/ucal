import React from "react"
import { Row, Box, Text, Icon } from "@tlon/indigo-react"
import { StatusBarItem } from "./icons/StatusBarItem"
import { Sigil } from "./icons/sigil"
import { useHistory } from "react-router-dom"

const HeaderBar = () => {
  const history = useHistory()
  const display = !window.location.href.includes("popout/") ? "grid" : "none"

  return (
    <Box
      display={display}
      width="100%"
      gridTemplateRows="30px"
      gridTemplateColumns="3fr 1fr"
      py={2}
    >
      <Row collapse>
        <StatusBarItem mr={2} onClick={() => history.push("/")}>
          <Icon icon="Home" color="black" />
        </StatusBarItem>
      </Row>
      {/* <Row justifyContent="flex-end" collapse>
        <StatusBarItem onClick={() => (window.location.href = "/~profile")}>
          <Sigil
            ship={window.ship}
            size={24}
            color={"#000000"}
            classes="dib mix-blend-diff"
          />
          <Text ml={2} display={["none", "inline"]} fontFamily="mono">
            ~{window.ship}
          </Text>
        </StatusBarItem>
      </Row> */}
    </Box>
  )
}

export default HeaderBar
