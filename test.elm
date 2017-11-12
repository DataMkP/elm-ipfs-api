import Elm_ipfs_api exposing (pin_ls)
import Html exposing (text)

type alias Model =
  { val : String
  }


type Msg = Show | Answer String | String

update : String -> Model -> (Model, Cmd String )
update msg model =
  ({model | val = msg}, Cmd.none)

-- VIEW

view : Model -> Html.Html String
view model =
  text model.val

subs model =
  Sub.none
-- main : Program Never
main =
  Html.program
  { init = (Model "a", pin_ls [Elm_ipfs_api.Type Elm_ipfs_api.All_pins])
  , view = view
  , subscriptions = subs
    -- \model -> Sub.none
  , update = update
  }
