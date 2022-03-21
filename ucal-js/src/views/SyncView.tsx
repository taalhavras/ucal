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

const SyncView: React.FC<Props> = ({ history, match }) => {
  const { calendars, getCalendars } = useCalendarsAndEvents()
  const api = new UrbitApi()
  const syncCalendar = async (url: string): Promise<void> => {
    console.log("SYNCING FROM: ", url)
    await api.action("ucal-sync", "ucal-sync-action", {
      add: {
        url: url,
        timeout: "~m5",
      },
    })

    await getCalendars()
    history.goBack()
  }

  const [syncURLState, setSyncURLState] = useState("")
  const changeURLState = (e: React.ChangeEvent<HTMLInputElement>): void => {
    setSyncURLState(e.target.value)
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
          value={syncURLState}
        />
        <Button
          className="dark"
          marginRight="20px"
          onClick={() => syncCalendar(syncURLState)}
        >
          Sync
        </Button>
      </Row>
    </Box>
  )
}

export default withRouter(SyncView)
