module Elm_ipfs_api exposing(ipfs_cmd)
import Http exposing (..)
import Json.Decode exposing(Decoder)
-- import UrlParser as Url exposing ((</>), (<?>), s, int, stringParam, top)

--http://localhost:5001/api/v0/cat?arg=<ipfs-path>

type alias Stub = String

type alias Multihash = String

type alias Path = String

type alias Id = String

type alias Key = String

type alias Value = String

type alias File = String -- urls to get the data currently


-- to_url : String -> Ipfs -> String
-- to_url



daemon_url : String
daemon_url =
  "https://localhost:5001"

-- arg_vals : (a -> String) -> List a -> String
-- arg_vals args =
--   if (.isEmpty args) == True then
--     ""
--   else
--     String.concat |>
--     intersperse "&" |>
--     List.map args


args_to_str : String -> (a -> String) -> List a -> List a -> String
args_to_str argstr argfun args used_args =
  case (List.head args) of
    Just arg ->
      let new_argstr =
        if (List.member arg used_args) then
          (argstr ++ "&" ++ (argfun arg))
        else
          ""
      in
        args_to_str new_argstr argfun (List.drop 1 args) (arg::used_args)
    Nothing -> argstr


ipfs_cmd : Ipfs -> Decoder a -> Request a
ipfs_cmd cmd =
  let request =
    case cmd of
      Files_add cmd args ->
        args_to_str
          ("/api/v0/add?")
          (\arg ->
            case arg of
              Recursive_file_add -> "recurive=true"
              Quiet_file_add -> "quiet=true"
              Quieter -> "quieter=true"
              Silent -> "silent=true"
              Add_progress -> "progress=true"
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
      Files_cat cmd -> "/api/v0/cat?arg=" ++ cmd
      Files_get cmd args ->
        args_to_str
          ("/api/v0/get?arg=" ++ cmd)
          (\arg ->
            case arg of
              Output outpath -> "output=" ++ outpath
              Archive -> "archive=true"
              Compress level -> "compress=true&compression-level=" ++ (toString level)
          )
          args
          []
      Files_ls args ->
        args_to_str
          ("/api/v0/files/ls?")
          (\arg ->
            case arg of
              File_path f_path -> "arg=" ++ f_path
              Long_list -> "l=true"
          )
          args
          []
      -- Block_get
      -- Block_put
      -- Block_stat
      Repo_stat args ->
        args_to_str
          ("/api/v0/repo/stat?")
          (\arg ->
            case arg of
              Human_readable -> "human=true"
          )
          args
          []
      Repo_gc args ->
        args_to_str
          ("/api/v0/repo/gc?")
          (\arg ->
            case arg of
              Quiet1 -> "quiet=true"
              Stream_errors -> "stream_errors=true"
          )
          args
          []
      -- Dag_put
      Dag_get cmd -> "/api/v0/dag/get?arg=" ++ cmd
      -- Dag_tree
      Pin_add cmd args ->
        args_to_str
          ("/api/v0/pin/add?=" ++ cmd)
          (\arg ->
            case arg of
              Recursive1 -> "recursive=true"
              Progress -> "progress=true"
          )
          args
          []
      Pin_rm cmd args ->
        args_to_str
          ("/api/v0/pin/rm?arg=" ++ cmd)
          (\arg ->
            case arg of
              Recursive2 -> "recursive=true"
          )
          args
          []
      Pin_ls args ->
        args_to_str
          ("/api/v0/pin/ls?")
          (\arg ->
            case arg of
              Path path -> "arg=" ++ path
              Type pin_type ->
                case pin_type of
                  Direct -> "type=direct"
                  Indirect -> "type=indirect"
                  Recursive -> "type=recursive"
                  All_pins -> "type=all"
              Quiet -> "quiet=true"
          )
          args
          []
      Refs_local -> "/api/v0/refs/local"
      Bootstrap_list -> "/api/v0/bootstrap/list"
      Bootstrap_add_default -> "/api/v0/bootstrap/add/default"
      Bootstrap_rm -> "/api/v0/bootstrap/rm/all"
      Bitswap_wantlist args ->
        args_to_str
          ("/api/v0/bitswap/wantlist?")
          (\arg ->
            case arg of
              Peer_want peer -> "peer=" ++ peer
          )
          args
          []
      Bitswap_stat -> "/api/v0/stats/bitswap"
      Bitswap_unwant args ->
        args_to_str
          ("/api/v0/bitswap/unwant?")
          (\arg ->
            case arg of
              Peer_unwant peer -> "peer=" ++ peer
          )
          args
          []
      Dht_findprovs cmd args ->
        args_to_str
          ("/api/v0/dht/findprovs?")
          (\arg ->
            case arg of
              Verbose1 -> "verbose=true"
          )
          args
          []
      Dht_get cmd args ->
        args_to_str
          ("/api/v0/dht/findprovs?")
          (\arg ->
            case arg of
              Verbose2 -> "verbose=true"
          )
          args
          []
      Dht_put key val args ->
        args_to_str
          ("/api/v0/dht/put?arg=" ++ key ++ "&" ++ val)
          (\arg ->
            case arg of
              Verbose -> "verbose=true"
          )
          args
          []
      -- Pubsub_subscribe
      -- Pubsub_unsubscribe
      -- Pubsub_publish
      -- Pubsub_ls
      -- Pubsub_peers
      -- Swarm_addrs
      -- Swarm_connect
      -- Swarm_disconnect
      -- Swarm_peers
      -- Name_publish
      -- Name_resolve
      Misc_id args ->
        args_to_str
          ("/api/v0/id?")
          (\arg ->
            case arg of
              Peer_id p_id -> "arg=" ++ p_id
              Format format -> "format=" ++ format
          )
          args
          []
      Misc_version args ->
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
      Misc_ping cmd args ->
        args_to_str
          ("/api/v0/ping?" ++ cmd)
          (\arg ->
            case arg of
              Count tries -> "count=" ++ (toString tries)
          )
          args
          []
      Config_get -> "/api/v0/config/show"
      -- Config_set
      -- Config_replace cmd -> "/api/vo/config/replace"
      Log_ls -> "/api/v0/log/ls"
      Log_tail -> "/api/v0/log/tail"
      Log_Level log_identifier level ->
         "/api/v0/log/level?" ++ log_identifier ++ level
      -- Key_gen
      -- Key_list
  in
    get (daemon_url ++ request)


  -- in daemon_url ++ r_cmd
type Files_add_args
  = Recursive_file_add
  | Quiet_file_add
  | Quieter
  | Silent
  | Add_progress
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
  = Quiet1
  | Stream_errors

type Pin_add_args
  = Recursive1
  | Progress

type Pin_rm_args
  = Recursive2

type Pin_ls_args
  = Path String
  | Type Pin_type
  | Quiet

type Pin_type
  = Direct
  | Indirect
  | Recursive
  | All_pins

type Bitswap_wantlist_args
  = Peer_want String

type Bitswap_unwant_args
  = Peer_unwant String

type Dht_findprovs_args
  = Verbose1

type Dht_get_args
  = Verbose2

type Dht_put_args
  = Verbose

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

type Ipfs
  = Files_add File (List Files_add_args)
  | Files_cat Multihash
  | Files_get Multihash (List Files_get_args)
  | Files_ls (List Files_ls_args)
  -- | Block_get
  -- | Block_put
  -- | Block_stat
  | Repo_stat (List Repo_stat_args)
  | Repo_gc (List Repo_gc_args)
  -- | Dag_put
  | Dag_get Multihash
  -- | Dag_tree
  | Pin_add Multihash (List Pin_add_args)
  | Pin_rm Path (List Pin_rm_args)
  | Pin_ls (List Pin_ls_args)
  | Refs_local
  | Bootstrap_list
  | Bootstrap_add_default
  | Bootstrap_rm
  | Bitswap_wantlist (List Bitswap_wantlist_args)
  | Bitswap_stat
  | Bitswap_unwant (List Bitswap_unwant_args)
  | Dht_findprovs Key (List Dht_findprovs_args)
  | Dht_get Key (List Dht_get_args)
  | Dht_put Key Value (List Dht_put_args)
  -- | Pubsub_subscribe
  -- | Pubsub_unsubscribe
  -- | Pubsub_publish
  -- | Pubsub_ls
  -- | Pubsub_peers
  -- | Swarm_addrs
  -- | Swarm_connect
  -- | Swarm_disconnect
  -- | Swarm_peers
  -- | Name_publish
  -- | Name_resolve
  | Misc_id (List Misc_id_args)
  | Misc_version (List Misc_version_args)
  | Misc_ping String (List Misc_ping_args)
  | Config_get
  -- | Config_set
  -- | Config_replace
  | Log_ls
  | Log_tail
  | Log_Level String String
  -- | Key_gen
  -- | Key_list


-- type Ipfs
--   = Files
--   | Block
--   | Repo
--   | Dag
--   | Pin
--   | Refs
--   | Bootstrap
--   | Bitswap
--   | Dht
--   | Pubsub
--   | Swarm
--   | Name
--   | Misc
--   | Config
--   | Log
--   | Key
