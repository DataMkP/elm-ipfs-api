module Elm_ipfs_api exposing(..)
import Http exposing (..)
import Json.Decode exposing(..)
-- import UrlParser as Url exposing ((</>), (<?>), s, int, stringParam, top)

--http://localhost:5001/api/v0/cat?arg=<ipfs-path>

type alias Stub = String

type alias Multihash = String

type alias Path = String

type alias Id = String

type alias Maddr = String

type alias Key = String

type alias Value = String

type alias File = String -- urls to get the data currently

type alias Answer = String

-- to_url : String -> Ipfs -> String
-- to_url

-- type alias Errfun =
--   Result Error a -> msg

daemon_url : String
daemon_url =
  "http://localhost:5001"

ipfs_msg_handler : (Result Http.Error String) -> String
ipfs_msg_handler result =
  case result of
    Ok val -> val
    Err errtype ->
      case errtype of
        BadUrl addr -> addr
        Timeout -> "timeout"
        NetworkError -> "nerwork err"
        _ -> "err"

to_req : String -> Cmd String
to_req query =
  send ipfs_msg_handler <| getString (daemon_url ++ query)


args_to_str : String -> (a -> String) -> List a -> List a -> String
args_to_str argstr argfun args used_args =
  case (List.head args) of
    Just arg ->
      let new_argstr =
        if (List.member arg used_args) then
          (argstr ++ "&" ++ (argfun arg))
        else
          argstr
      in
        args_to_str new_argstr argfun (List.drop 1 args) (arg::used_args)
    Nothing -> argstr

files_add : File -> List Files_add_args -> Cmd Answer
files_add file args =
  to_req <|
    args_to_str
      ("/api/v0/add?")
      (\arg ->
        case arg of
          Files_add_recursive -> "recurive=true"
          File_add_quiet -> "quiet=true"
          Quieter -> "quieter=true"
          Silent -> "silent=true"
          Files_add_progress -> "progress=true"
          Trickle -> "trickle=true"
          Only_hash -> "only-hash=true"
          Wrap_in_dir -> "wrap-with-directory=true"
          Hidden -> "hidden=true"
          Chunker algo -> "chunker=" ++ (toString algo)
          Raw_leaves -> "raw-leaves=true"
          Fscache -> "fscache=true"
      )
      args
      []


files_cat : Maddr -> Cmd Answer
files_cat maddr = to_req <| "/api/v0/cat?arg=" ++ maddr

files_get : Maddr -> List Files_get_args -> Cmd Answer
files_get maddr args =
  to_req <|
    args_to_str
      ("/api/v0/get?arg=" ++ maddr)
      (\arg ->
        case arg of
          Output outpath -> "output=" ++ outpath
          Archive -> "archive=true"
          Compress level -> "compress=true&compression-level=" ++ (toString level)
      )
      args
      []

files_ls : List Files_ls_args -> Cmd Answer
files_ls args =
  to_req <|
    args_to_str
      ("/api/v0/files/ls?")
      (\arg ->
        case arg of
          File_path f_path -> "arg=" ++ f_path
          Long_list -> "l=true"
      )
      args
      []

-- block_get
-- block_put
-- block_stat
repo_stat : List Repo_stat_args -> Cmd Answer
repo_stat args =
  to_req <|
  args_to_str
    ("/api/v0/repo/stat?")
    (\arg ->
      case arg of
        Human_readable -> "human=true"
    )
    args
    []

repo_gc : List Repo_gc_args -> Cmd Answer
repo_gc args =
  to_req <|
    args_to_str
      ("/api/v0/repo/gc?")
      (\arg ->
        case arg of
          Repo_gc_quiet -> "quiet=true"
          Stream_errors -> "stream_errors=true"
      )
      args
      []

-- dag_put
dag_get : Maddr -> Cmd Answer
dag_get maddr =   to_req <| "/api/v0/dag/get?arg=" ++ maddr



pin_add : Maddr -> List Pin_add_args -> Cmd Answer
pin_add maddr args =
  to_req <|
  args_to_str
    ("/api/v0/pin/add?=" ++ maddr)
    (\arg ->
      case arg of
        Pin_add_recursive -> "recursive=true"
        Pin_add_progress -> "progress=true"
    )
    args
    []

pin_rm : Path -> List Pin_rm_args -> Cmd Answer
pin_rm maddr args =
  to_req <|
  args_to_str
    ("/api/v0/pin/rm?arg=" ++ maddr)
    (\arg ->
      case arg of
        Pin_rm_recursive -> "recursive=true"
    )
    args
    []
pin_ls : List Pin_ls_args -> Cmd Answer
pin_ls args =
  to_req <|
  args_to_str
    ("/api/v0/pin/ls?")
    (\arg ->
      case arg of
        Path path -> "arg=" ++ path
        Type pin_type ->
          case pin_type of
            Direct -> "type=direct"
            Indirect -> "type=indirect"
            Pin_type_recursive -> "type=recursive"
            All_pins -> "type=all"
        Pin_ls_quiet -> "quiet=true"
    )
    args
    []

refs_local : Cmd Answer
refs_local =   to_req <| "/api/v0/refs/local"

bootstrap_list : Cmd Answer
bootstrap_list =   to_req <| "/api/v0/bootstrap/list"

bootstrap_add_default : Cmd Answer
bootstrap_add_default =   to_req <| "/api/v0/bootstrap/add/default"

bootstrap_rm : Cmd Answer
bootstrap_rm =   to_req <| "/api/v0/bootstrap/rm/all"

bitswap_wantlist : List Bitswap_wantlist_args -> Cmd Answer
bitswap_wantlist args =
  to_req <|
  args_to_str
    ("/api/v0/bitswap/wantlist?")
    (\arg ->
      case arg of
        Peer_want peer -> "peer=" ++ peer
    )
    args
    []

bitswap_stat : Cmd Answer
bitswap_stat =   to_req <| "/api/v0/stats/bitswap"

bitswap_unwant : List Bitswap_unwant_args -> Cmd Answer
bitswap_unwant args =
  to_req <|
  args_to_str
    ("/api/v0/bitswap/unwant?")
    (\arg ->
      case arg of
        Peer_unwant peer -> "peer=" ++ peer
    )
    args
    []
dht_findprovs : Key -> List Dht_findprovs_args -> Cmd Answer
dht_findprovs key args =
  to_req <|
  args_to_str
    ("/api/v0/dht/findprovs?arg=" ++ key)
    (\arg ->
      case arg of
        Dht_findprovs_verbose -> "verbose=true"
    )
    args
    []

dht_get : Key -> List Dht_get_args -> Cmd Answer
dht_get key args =
  to_req <|
  args_to_str
    ("/api/v0/dht/findprovs?arg=" ++key)
    (\arg ->
      case arg of
        Dht_get_verbose -> "verbose=true"
    )
    args
    []
dht_put : Key -> Value -> List Dht_put_args -> Cmd Answer
dht_put key val args =
  to_req <|
  args_to_str
    ("/api/v0/dht/put?arg=" ++ key ++ "&" ++ val)
    (\arg ->
      case arg of
        Ipld_format node_format ->
          case node_format of
            Cbor -> "format=cbor"
            _ -> ""
        Input_enc enc ->  "input-enc=" ++ "json"
    )
    args
    []
-- pubsub_subscribe
-- pubsub_unsubscribe
-- pubsub_publish
-- pubsub_ls
-- pubsub_peers
-- swarm_addrs
-- swarm_connect
-- swarm_disconnect
-- swarm_peers
-- name_publish
-- name_resolve
misc_id : List Misc_id_args -> Cmd Answer
misc_id args =
  to_req <|
  args_to_str
    ("/api/v0/id?")
    (\arg ->
      case arg of
        Peer_id p_id -> "arg=" ++ p_id
        Format format -> "format=" ++ format
    )
    args
    []

misc_version : List Misc_version_args -> Cmd Answer
misc_version args =
  to_req <|
  args_to_str
    ("/api/v0/version?")
    (\arg ->
      case arg of
        Number -> "number=true"
        Commit -> "commit=true"
        Repo -> "repo=true"
        All -> "all=true"
    )
    args
    []
misc_ping : String -> List Misc_ping_args -> Cmd Answer
misc_ping cmd args =
  to_req <|
  args_to_str
    ("/api/v0/ping?" ++ cmd)
    (\arg ->
      case arg of
        Count tries -> "count=" ++ (toString tries)
    )
    args
    []
config_get : Cmd Answer
config_get =   to_req <| "/api/v0/config/show"

-- config_set
-- config_replace

log_ls : Cmd Answer
log_ls =   to_req <| "/api/v0/log/ls"

log_tail : Cmd Answer
log_tail =   to_req <| "/api/v0/log/tail"

log_level : String -> String -> Cmd Answer
log_level log_identifier level =
     to_req <| "/api/v0/log/level?" ++ log_identifier ++ level

-- key_get
-- key_list


type Files_add_args
  = Files_add_recursive
  | File_add_quiet
  | Quieter
  | Silent
  | Files_add_progress
  | Trickle
  | Only_hash
  | Wrap_in_dir
  | Hidden
  | Chunker Int
  | Raw_leaves
  | Fscache

type Files_get_args
  = Output String
  | Archive
  | Compress Int


type Files_ls_args
  = File_path String
  | Long_list

type Repo_stat_args
  = Human_readable

type Repo_gc_args
  = Repo_gc_quiet
  | Stream_errors

type Pin_add_args
  = Pin_add_recursive
  | Pin_add_progress

type Pin_rm_args
  = Pin_rm_recursive

type Pin_ls_args
  = Path String
  | Type Pin_type
  | Pin_ls_quiet

type Pin_type
  = Direct
  | Indirect
  | Pin_type_recursive
  | All_pins

type Bitswap_wantlist_args
  = Peer_want String

type Bitswap_unwant_args
  = Peer_unwant String

type Dht_findprovs_args
  = Dht_findprovs_verbose

type Dht_get_args
  = Dht_get_verbose

type Node_format
  = Cid
  | Ipld_node_interface
  | Ipld_resolver
  | Cbor
  | Merkledag_Protobuf
  | Raw
  | Unixfs_v2
  | Git
  | Bitcoin
  | Zcash
  | Ethereum
  | Bencode
  | Torrent_info
  | Torrent_file
  | Ipld_selectors

type Enc
  = Json


type Dht_put_args
  = Ipld_format Node_format
  | Input_enc Enc

type Misc_id_args
  = Peer_id Id
  | Format String

type Misc_version_args
  = Number
  | Commit
  | Repo
  | All

type Misc_ping_args
  = Count Int
