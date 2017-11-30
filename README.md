# elm-ipfs-api
  elm wrapper for the http ipfs api
  this is a experiment for typesafe wrapping http
  returns json as string

#### exposes functions for ipfs with the structure:
  `function needed_args1 [list_optional_arguments]`

example:

  `pin_add "Qmsomehash" [Recursive1, Progress]`

  because kiss i stayed with uniqe arguments-type-names for every functions
  as the repeated arguments **could** be abstracted like:
  `function needed_args1 [list_reocurring_arguments][list_unique_arguments]`

example:

  `pin_add "Qmsomehash" [Recursive1, Progress] []`

  as recursive is e.g. also an option for function `pin_ls`

#### behaviour:
  * ignores doubled query arguments
  * arguments are types -> no malformed queries possible
  * if argument is used it has value true

#### alternatives:
  * [erl](http://package.elm-lang.org/packages/sporto/erl/latest/Erl)
  * [httpbuilder](http://package.elm-lang.org/packages/lukewestby/elm-http-builder/latest)

#### todo:
  * should work, not tested
  * finish coverage
  * implement file support, when ready in elm-lang
  * maybe optional decoders to records, for usability
    other commands

#### futher thoughts:

  being able to throw compile errors in elm could be nice
  this is a workaroud for having sets of argument-types,
  which would be better than lists,
