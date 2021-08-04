import { Elm } from './src/Viewer.elm'

const twitch = window.Twitch ? window.Twitch.ext : null

const app = Elm.Viewer.init({
  node: document.getElementById('app'),
})

twitch.onAuthorized((auth) => {
  app.ports.authorization.send(auth)
})

twitch.configuration.onChanged(() => {
  let config = twitch.configuration.broadcaster
    ? twitch.configuration.broadcaster.content
    : {
        selectedColors: [],
        colors: [],
        tools: [],
      }
  try {
    config = JSON.parse(config)
  } catch (e) {
    config = {
      selectedColors: [],
      colors: [],
      tools: [],
    }
  }

  app.ports.receiveConfig.send(config)
})

app.ports.log.subscribe(function (message) {
  console.log(message)
  window.Twitch.ext.rig.log(message)
})
