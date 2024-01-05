let apiBaseUrl: string = 'https://api.doyoueventrack.app'
let authBaseUrl: string = 'https://auth.doyoueventrack.app/auth'
let appBaseUrl: string = 'https://bro.doyoueventrack.app'

// let testBaseUri: string = 'dyet.test.kubernetes.lan.basmaas.nl'
// if ((window.location.origin).includes(testBaseUri)){
//   apiBaseUrl = `https://api.${testBaseUri}`
//   authBaseUrl = `https://auth.${testBaseUri}/auth`
//   appBaseUrl = `https://bro.${testBaseUri}`
// }

export const environment = {
  production: true,
  apiBaseUrl: apiBaseUrl,
  authBaseUrl: authBaseUrl,
  redirectUrl: appBaseUrl
};
