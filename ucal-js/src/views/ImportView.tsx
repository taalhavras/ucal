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
import UrbitApi from "../logic/api"

interface Props extends RouteComponentProps<RouterProps> {
  history: History
  location: Location
  match: match<RouterProps>
}

const ImportView: React.FC<Props> = ({ history, match }) => {
  const { calendars, getCalendars } = useCalendarsAndEvents()
  const api = new UrbitApi()
  const importCalendar = async (url: string): Promise<void> => {
    console.log("IMPORTING FROM: ", url)
    await api.action("ucal-store", "ucal-action", {
      "import-from-ics": {
        url: url,
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
