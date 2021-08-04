import { Elm } from './src/Viewer.elm'

const twitch = window.Twitch ? window.Twitch.ext : null

const app = Elm.Viewer.init({
  node: document.getElementById('app'),
})

twitch.onAuthorized((auth) => {
  app.ports.authorization.send(auth)
})

app.ports.log.subscribe(function (message) {
  console.log(message)
  window.Twitch.ext.rig.log(message)
})
