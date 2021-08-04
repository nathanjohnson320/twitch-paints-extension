port module Twitch exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode


port log : Encode.Value -> Cmd msg


port saveConfig : Encode.Value -> Cmd msg


port receiveConfig : (Decode.Value -> msg) -> Sub msg
