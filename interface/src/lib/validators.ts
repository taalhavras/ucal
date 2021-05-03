export const validateShip = (ship: string) => /~?(\w{3}$|\w{6}$|\w{6}\-\w{6}$)/.test(ship)
