port module Twitch exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode


type alias Color =
    { hex : String
    , name : String
    }


type alias Tool =
    { name : String
    , url : String
    }


type alias Config =
    { colors : List Color
    , tools : List Tool
    , selectedColors : List Color
    }


decodeConfig : Decoder Config
decodeConfig =
    Decode.succeed Config
        |> required "colors" decodeColors
        |> required "tools" decodeTools
        |> required "selectedColors" decodeColors


decodeColors : Decoder (List Color)
decodeColors =
    Decode.list decodeColor


decodeTools : Decoder (List Tool)
decodeTools =
    Decode.list decodeTool


decodeColor : Decoder Color
decodeColor =
    Decode.succeed Color
        |> required "hex" Decode.string
        |> required "name" Decode.string


decodeTool : Decoder Tool
decodeTool =
    Decode.succeed Tool
        |> required "name" Decode.string
        |> required "url" Decode.string


encodeConfig : Config -> Encode.Value
encodeConfig config =
    Encode.object
        [ ( "colors", encodeColors <| config.colors )
        , ( "tools", encodeTools <| config.tools )
        , ( "selectedColors", encodeColors <| config.selectedColors )
        ]


encodeColors : List Color -> Encode.Value
encodeColors colors =
    Encode.list encodeColor colors


encodeColor : Color -> Encode.Value
encodeColor color =
    Encode.object
        [ ( "hex", Encode.string color.hex )
        , ( "name", Encode.string color.name )
        ]


encodeTools : List Tool -> Encode.Value
encodeTools tools =
    Encode.list encodeTool tools


encodeTool : Tool -> Encode.Value
encodeTool tool =
    Encode.object
        [ ( "name", Encode.string tool.name )
        , ( "url", Encode.string tool.url )
        ]


port log : Encode.Value -> Cmd msg


port saveConfig : Encode.Value -> Cmd msg


port receiveConfig : (Decode.Value -> msg) -> Sub msg
