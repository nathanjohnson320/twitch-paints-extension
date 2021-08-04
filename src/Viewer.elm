module Viewer exposing (..)

import Authentication exposing (Auth, authorization, decodeAuth, emptyAuth)
import Browser
import Html exposing (Html, button, div, h1, text)
import Json.Decode as Decode
import Json.Encode as Encode
import Twitch exposing (log)



---- MODEL ----


type alias Model =
    { auth : Auth
    }


init : ( Model, Cmd Msg )
init =
    ( { auth = emptyAuth }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | Log Encode.Value
    | Authorize Decode.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Authorize value ->
            case
                Decode.decodeValue decodeAuth value
            of
                Ok auth ->
                    ( { model | auth = auth }, Cmd.none )

                Err err ->
                    ( model, log <| Encode.string <| Decode.errorToString err )

        Log value ->
            ( model, log value )

        NoOp ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view _ =
    div []
        [ h1 [] [ text "Your Elm App is working!" ]
        , button [] [ text "Log something" ]
        ]



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ authorization Authorize
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
