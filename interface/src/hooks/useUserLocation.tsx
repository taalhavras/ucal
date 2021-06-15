import React, { createContext, useContext, useState } from "react"

type UserLocationContextType = {
  userLocation: string
  setUserLocation: (arg: string) => void
}

export const UserLocationContext = createContext<UserLocationContextType>({
  userLocation: "",
  setUserLocation: () => {},
})

export const UserLocationProvider: React.FC = ({ children }) => {
  const [userLocation, setUserLocation] = useState("")

  const { Provider } = UserLocationContext

  return (
    <Provider
      value={{
        userLocation,
        setUserLocation,
      }}
    >
      {children}
    </Provider>
  )
}

export const useUserLocation = () => useContext(UserLocationContext)
