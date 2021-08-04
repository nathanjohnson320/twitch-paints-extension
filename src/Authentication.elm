port module Authentication exposing (..)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)


type alias Auth =
    { channelId : String
    , clientId : String
    , token : String
    , userId : String
    }


emptyAuth : Auth
emptyAuth =
    { channelId = ""
    , clientId = ""
    , token = ""
    , userId = ""
    }


decodeAuth : Decoder Auth
decodeAuth =
    Decode.succeed Auth
        |> required "channelId" string
        |> required "clientId" string
        |> required "token" string
        |> required "userId" string


port authorization : (Decode.Value -> msg) -> Sub msg
