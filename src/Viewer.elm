module Viewer exposing (..)

import Authentication exposing (Auth, authorization, decodeAuth, emptyAuth)
import Browser
import Css
import Html.Styled exposing (Html, div, table, tbody, td, text, th, thead, toUnstyled, tr)
import Html.Styled.Attributes exposing (css, scope)
import Json.Decode as Decode
import Json.Encode as Encode
import Tailwind.Breakpoints as Bp
import Tailwind.Utilities as Tw
import Twitch exposing (Color, decodeConfig, log, receiveConfig)



---- MODEL ----


type alias Model =
    { auth : Auth
    , selectedColors : List Color
    }


init : ( Model, Cmd Msg )
init =
    ( { auth = emptyAuth
      , selectedColors = []
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp
    | Log Encode.Value
    | Authorize Decode.Value
    | ReceiveConfig Decode.Value


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

        ReceiveConfig value ->
            case
                Decode.decodeValue decodeConfig value
            of
                Ok config ->
                    ( { model
                        | selectedColors = config.selectedColors
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log <| Encode.string <| Decode.errorToString err )

        Log value ->
            ( model, log value )

        NoOp ->
            ( model, Cmd.none )



---- VIEW ----


sortedColors : Model -> List Color
sortedColors model =
    List.sortBy .name model.selectedColors


colorTable : Model -> Html Msg
colorTable model =
    div
        [ css
            [ Tw.flex
            , Tw.flex_col
            ]
        ]
        [ div
            [ css
                [ Tw.neg_my_2
                ]
            ]
            [ div
                [ css
                    [ Tw.py_2
                    , Tw.align_middle
                    , Tw.inline_block
                    , Tw.min_w_full
                    ]
                ]
                [ div
                    [ css
                        [ Tw.shadow
                        , Tw.overflow_scroll
                        , Tw.border_b
                        , Tw.border_gray_200
                        , Tw.h_screen
                        , Bp.sm
                            [ Tw.rounded_lg
                            ]
                        ]
                    ]
                    [ table
                        [ css
                            [ Tw.min_w_full
                            , Tw.table_fixed
                            , Tw.divide_y
                            , Tw.divide_gray_200
                            ]
                        ]
                        [ thead
                            [ css
                                [ Tw.bg_gray_50
                                ]
                            ]
                            [ tr []
                                [ th
                                    [ scope "col"
                                    , css
                                        [ Tw.px_6
                                        , Tw.py_3
                                        , Tw.text_left
                                        , Tw.text_4xl
                                        , Tw.font_medium
                                        , Tw.text_gray_500
                                        , Tw.uppercase
                                        , Tw.tracking_wider
                                        , Tw.w_1over6
                                        ]
                                    ]
                                    [ text "Color" ]
                                , th
                                    [ scope "col"
                                    , css
                                        [ Tw.px_6
                                        , Tw.py_3
                                        , Tw.text_left
                                        , Tw.text_4xl
                                        , Tw.font_medium
                                        , Tw.text_gray_500
                                        , Tw.uppercase
                                        , Tw.tracking_wider
                                        ]
                                    ]
                                    [ text "Name" ]
                                ]
                            ]
                        , tbody
                            [ css
                                [ Tw.bg_white
                                , Tw.divide_y
                                , Tw.divide_gray_200
                                ]
                            ]
                            (List.map
                                (\color ->
                                    tr []
                                        [ td
                                            [ css
                                                [ Tw.px_6
                                                , Tw.py_4
                                                , Tw.whitespace_nowrap
                                                , Tw.font_medium
                                                , Tw.text_gray_900
                                                , Tw.flex
                                                , Tw.items_center
                                                ]
                                            ]
                                            [ div
                                                [ css
                                                    [ Tw.w_full
                                                    , Tw.h_14
                                                    , Tw.border_gray_300
                                                    , Tw.border_solid
                                                    , Css.backgroundColor <| Css.hex color.hex
                                                    ]
                                                ]
                                                []
                                            ]
                                        , td
                                            [ css
                                                [ Tw.px_6
                                                , Tw.py_4
                                                , Tw.whitespace_nowrap
                                                , Tw.text_7xl
                                                , Tw.text_gray_500
                                                ]
                                            ]
                                            [ text color.name ]
                                        ]
                                )
                                (sortedColors model)
                            )
                        ]
                    ]
                ]
            ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ colorTable model
        ]



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ authorization Authorize
        , receiveConfig ReceiveConfig
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view >> toUnstyled
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
