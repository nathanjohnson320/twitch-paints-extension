module UI exposing (Button(..), twButton)

import Css
import Html.Styled exposing (Attribute, Html, button)
import Html.Styled.Attributes exposing (css, type_)
import Tailwind.Utilities as Tw


type Button
    = Info
    | Error


twButton : Button -> List (Attribute msg) -> List (Html msg) -> Html msg
twButton buttonType attrs =
    let
        { text, bg, ring, hover } =
            case buttonType of
                Info ->
                    { text = Tw.text_indigo_700
                    , bg = Tw.bg_indigo_100
                    , ring = Tw.ring_indigo_500
                    , hover = Tw.bg_indigo_200
                    }

                Error ->
                    { text = Tw.text_red_700
                    , bg = Tw.bg_red_100
                    , ring = Tw.bg_red_500
                    , hover = Tw.bg_red_200
                    }
    in
    button
        (attrs
            ++ [ css
                    [ Tw.inline_flex
                    , Tw.items_center
                    , Tw.px_2_dot_5
                    , Tw.py_1_dot_5
                    , Tw.border
                    , Tw.border_transparent
                    , Tw.text_xs
                    , Tw.font_medium
                    , Tw.rounded
                    , text
                    , bg
                    , Css.focus
                        [ Tw.outline_none
                        , Tw.ring_2
                        , Tw.ring_offset_2
                        , ring
                        ]
                    , Css.hover
                        [ hover
                        ]
                    ]
               ]
        )
