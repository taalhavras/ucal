import React, { useState } from "react"
import {
  Text,
  Box,
  Row,
  Button,
  StatelessTextInput,
  Checkbox,
} from "@tlon/indigo-react"
import { match, RouteComponentProps, withRouter } from "react-router-dom"
import { History, Location, LocationState } from "history"
import { useCalendarsAndEvents } from "../hooks/useCalendarsAndEvents"

interface Props extends RouteComponentProps<RouterProps> {
  history: History
  location: Location
  match: match<RouterProps>
}

const ImportView: React.FC<Props> = ({ history, match }) => {
  const importCalendar = async (url: string): Promise<void> => {
    console.log("IMPORTING FROM: ", url)
    let response = await fetch(url)
    if (!response.ok) {
      // NOCOMMIT what should the real error handling be? we probably want to
      // just alert the user somehow... not sure what the best way to thread
      // that info back is? throwing + caller catching and redirecting?
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    const blob = response.blob()
    if (blob.type != "text/calendar") {
      throw new Error(
        `Data at ${url} had type ${blob.type} instead of text/calendar`
      )
    }

    await api.action("ucal-store", "ucal-action", {
      "import-from-ics": {
        data: blob.text(),
      },
    })

    await getCalendars()
    history.goBack()
  }

  const [importURLState, setImportURLState] = useState("")
  const changeURLState = (e: React.ChangeEvent<HTMLInputElement>): void => {
    setImportURLState(e.target.value)
  }

  return (
    <Box
      height="100%"
      p="4"
      display="flex"
      flexDirection="column"
      borderWidth={["none", "1px"]}
      borderStyle="solid"
      borderColor="washedGray"
    >
      <Row width="100%">
        <Button fontSize="16px" marginRight="20px" onClick={history.goBack}>
          X
        </Button>
        <StatelessTextInput
          fontSize="1"
          placeholder="URL"
          width="40%"
          marginRight="20px"
          onChange={changeURLState}
          value={importURLState}
        />
        <Button
          className="dark"
          marginRight="20px"
          onClick={() => importCalendar(importURLState)}
        >
          Import
        </Button>
      </Row>
    </Box>
  )
}

export default withRouter(ImportView)
