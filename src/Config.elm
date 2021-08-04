module Config exposing (..)

import Authentication exposing (Auth, authorization, decodeAuth, emptyAuth)
import Browser
import Css
import Html.Styled as Html exposing (Attribute, Html, a, button, div, form, h1, input, label, span, table, tbody, td, text, th, thead, toUnstyled, tr)
import Html.Styled.Attributes exposing (css, for, href, id, name, placeholder, scope, type_, value)
import Html.Styled.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Tailwind.Breakpoints as Bp
import Tailwind.Utilities as Tw
import Twitch exposing (Color, Config, Tool, decodeConfig, encodeConfig, log, receiveConfig, saveConfig)
import UI exposing (Button(..), twButton)



---- MODEL ----


type alias Model =
    { auth : Auth
    , colors : List Color
    , tools : List Tool
    , selectedColors : List Color
    , newColor : Color
    }


modelToConfig : Model -> Config
modelToConfig model =
    { colors = model.colors
    , tools = model.tools
    , selectedColors = model.selectedColors
    }


init : ( Model, Cmd Msg )
init =
    ( { auth = emptyAuth
      , colors = []
      , tools = []
      , selectedColors = []
      , newColor = Color "#ffffff" ""
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp
    | Log Encode.Value
    | SaveConfig Encode.Value
    | ReceiveConfig Decode.Value
    | Authorize Decode.Value
    | AddColor Color
    | RemoveColor Color
    | ChangeName String
    | ChangeColor String
    | SelectColor Color
    | RemoveSelectedColor Color


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeName name ->
            let
                newColor =
                    Color model.newColor.hex name
            in
            ( { model | newColor = newColor }, Cmd.none )

        ChangeColor hex ->
            let
                newColor =
                    Color hex model.newColor.name
            in
            ( { model | newColor = newColor }, Cmd.none )

        AddColor color ->
            ( { model
                | colors = color :: model.colors
              }
            , Cmd.none
            )

        SelectColor color ->
            ( { model
                | selectedColors = color :: model.selectedColors
              }
            , Cmd.none
            )

        RemoveSelectedColor color ->
            ( { model
                | selectedColors = List.filter (\c -> c.name /= color.name) model.selectedColors
              }
            , Cmd.none
            )

        RemoveColor color ->
            ( { model
                | colors =
                    List.filter (\c -> c.name /= color.name) model.colors
              }
            , Cmd.none
            )

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
                        | colors = config.colors
                        , tools = config.tools
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( model, log <| Encode.string <| Decode.errorToString err )

        Log value ->
            ( model, log value )

        SaveConfig value ->
            ( model, saveConfig value )

        NoOp ->
            ( model, Cmd.none )



---- VIEW ----


selectedColorTable : Model -> Html Msg
selectedColorTable model =
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
                        , Tw.overflow_hidden
                        , Tw.border_b
                        , Tw.border_gray_200
                        , Bp.sm
                            [ Tw.rounded_lg
                            ]
                        ]
                    ]
                    [ table
                        [ css
                            [ Tw.min_w_full
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
                                        , Tw.text_xs
                                        , Tw.font_medium
                                        , Tw.text_gray_500
                                        , Tw.uppercase
                                        , Tw.tracking_wider
                                        ]
                                    ]
                                    [ text "Color" ]
                                , th
                                    [ scope "col"
                                    , css
                                        [ Tw.px_6
                                        , Tw.py_3
                                        , Tw.text_left
                                        , Tw.text_xs
                                        , Tw.font_medium
                                        , Tw.text_gray_500
                                        , Tw.uppercase
                                        , Tw.tracking_wider
                                        ]
                                    ]
                                    [ text "Name" ]
                                , th
                                    [ scope "col"
                                    , css
                                        [ Tw.px_6
                                        , Tw.py_3
                                        , Tw.text_left
                                        , Tw.text_xs
                                        , Tw.font_medium
                                        , Tw.text_gray_500
                                        , Tw.uppercase
                                        , Tw.tracking_wider
                                        ]
                                    ]
                                    []
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
                                                , Tw.text_sm
                                                , Tw.font_medium
                                                , Tw.text_gray_900
                                                , Tw.flex
                                                , Tw.items_center
                                                ]
                                            ]
                                            [ div
                                                [ css
                                                    [ Tw.w_8
                                                    , Tw.h_8
                                                    , Tw.mr_1
                                                    , Css.backgroundColor <| Css.hex color.hex
                                                    ]
                                                ]
                                                []
                                            , text color.hex
                                            ]
                                        , td
                                            [ css
                                                [ Tw.px_6
                                                , Tw.py_4
                                                , Tw.whitespace_nowrap
                                                , Tw.text_sm
                                                , Tw.text_gray_500
                                                ]
                                            ]
                                            [ text color.name ]
                                        , td
                                            [ css
                                                [ Tw.px_6
                                                , Tw.py_4
                                                , Tw.whitespace_nowrap
                                                , Tw.text_sm
                                                , Tw.font_medium
                                                ]
                                            ]
                                            [ twButton Error
                                                [ type_ "button"
                                                , onClick (RemoveSelectedColor color)
                                                ]
                                                [ text "Remove" ]
                                            ]
                                        ]
                                )
                                model.selectedColors
                            )
                        ]
                    ]
                ]
            ]
        ]


formRow : Color -> Html Msg
formRow color =
    tr []
        [ td
            [ css
                [ Tw.px_6
                , Tw.py_4
                , Tw.whitespace_nowrap
                , Tw.text_sm
                , Tw.font_medium
                , Tw.text_gray_900
                , Tw.flex
                , Tw.items_center
                ]
            ]
            [ div
                [ css
                    [ Tw.w_8
                    , Tw.h_8
                    , Tw.mr_1
                    , Css.backgroundColor <| Css.hex color.hex
                    ]
                ]
                []
            , text color.hex
            ]
        , td
            [ css
                [ Tw.px_6
                , Tw.py_4
                , Tw.whitespace_nowrap
                , Tw.text_sm
                , Tw.text_gray_500
                ]
            ]
            [ text color.name ]
        , td
            [ css
                [ Tw.px_6
                , Tw.py_4
                , Tw.whitespace_nowrap
                , Tw.text_sm
                , Tw.font_medium
                ]
            ]
            [ twButton Info
                [ type_ "button"
                , onClick (SelectColor color)
                , css [ Tw.mr_2 ]
                ]
                [ text "Select" ]
            , twButton Error
                [ type_ "button"
                , onClick (RemoveColor color)
                ]
                [ text "Delete" ]
            ]
        ]


colorsForm : Model -> Html Msg
colorsForm model =
    div []
        [ h1 [] [ text "Define Colors" ]
        , div [ css [ Tw.flex, Tw.items_center, Tw.justify_around, Tw.my_2 ] ]
            [ div []
                [ label
                    [ for "name"
                    , css
                        [ Tw.block
                        , Tw.text_sm
                        , Tw.font_medium
                        , Tw.text_gray_700
                        ]
                    ]
                    [ text "Color Name" ]
                , div
                    [ css
                        [ Tw.mt_1
                        ]
                    ]
                    [ input
                        [ type_ "text"
                        , name "name"
                        , id "name"
                        , css
                            [ Tw.shadow_sm
                            , Tw.block
                            , Tw.w_40
                            , Tw.border_gray_300
                            , Tw.rounded_md
                            , Css.focus
                                [ Tw.ring_indigo_500
                                , Tw.border_indigo_500
                                ]
                            , Bp.sm
                                [ Tw.text_sm
                                ]
                            ]
                        , placeholder "Name"
                        , value model.newColor.name
                        , onInput ChangeName
                        ]
                        []
                    ]
                ]
            , div []
                [ label
                    [ for "color"
                    , css
                        [ Tw.block
                        , Tw.text_sm
                        , Tw.font_medium
                        , Tw.text_gray_700
                        ]
                    ]
                    [ text "Color Code" ]
                , input
                    [ type_ "color"
                    , name "color"
                    , id "color"
                    , placeholder "Color"
                    , value model.newColor.hex
                    , onInput ChangeColor
                    ]
                    []
                ]
            , twButton Info
                [ type_ "button"
                , onClick (AddColor model.newColor)
                ]
                [ text "Add" ]
            ]
        , div
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
                            , Tw.overflow_hidden
                            , Tw.border_b
                            , Tw.border_gray_200
                            , Bp.sm
                                [ Tw.rounded_lg
                                ]
                            ]
                        ]
                        [ table
                            [ css
                                [ Tw.min_w_full
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
                                            , Tw.text_xs
                                            , Tw.font_medium
                                            , Tw.text_gray_500
                                            , Tw.uppercase
                                            , Tw.tracking_wider
                                            ]
                                        ]
                                        [ text "Color" ]
                                    , th
                                        [ scope "col"
                                        , css
                                            [ Tw.px_6
                                            , Tw.py_3
                                            , Tw.text_left
                                            , Tw.text_xs
                                            , Tw.font_medium
                                            , Tw.text_gray_500
                                            , Tw.uppercase
                                            , Tw.tracking_wider
                                            ]
                                        ]
                                        [ text "Name" ]
                                    , th
                                        [ scope "col"
                                        , css
                                            [ Tw.px_6
                                            , Tw.py_3
                                            , Tw.text_left
                                            , Tw.text_xs
                                            , Tw.font_medium
                                            , Tw.text_gray_500
                                            , Tw.uppercase
                                            , Tw.tracking_wider
                                            ]
                                        ]
                                        []
                                    ]
                                ]
                            , tbody
                                [ css
                                    [ Tw.bg_white
                                    , Tw.divide_y
                                    , Tw.divide_gray_200
                                    ]
                                ]
                                (List.map formRow model.colors)
                            ]
                        ]
                    ]
                ]
            ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ form [ onSubmit (SaveConfig <| encodeConfig <| modelToConfig model) ]
            [ h1 [] [ text "Selected Colors" ]
            , selectedColorTable model
            , colorsForm model
            , twButton Info
                [ type_ "submit"
                , css [ Tw.w_full, Tw.mt_4 ]
                ]
                [ span [ css [ Tw.w_full, Tw.text_center ] ] [ text "Save" ] ]
            ]
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
