import { Elm } from './src/Config.elm'

const VSN = '0.0.1'

const twitch = window.Twitch ? window.Twitch.ext : null

const app = Elm.Config.init({
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

app.ports.saveConfig.subscribe(function (config) {
  twitch.configuration.set('broadcaster', VSN, JSON.stringify(config))
})

app.ports.log.subscribe(function (message) {
  console.log('LOG', message)
  window.Twitch.ext.rig.log(message)
})
