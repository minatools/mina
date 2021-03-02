(* genesis_ledger_from_tsv.ml -- create JSON-format genesis ledger from tab-separated-value data *)

(* columns in spreadsheet:

 Wallet Address (Public Key)|Amount (MINA)|Initial Minimum Balance|(MINA) Cliff Time (Months)|Cliff Unlock Amount (MINA)|Unlock Frequency (0: per slot, 1: per month)|Unlock Amount (MINA)|Delegate (Public Key) [Optional]

*)

open Core_kernel
open Async
open Mina_numbers
open Signature_lib

(* populated during validation pass *)
let delegates_tbl : unit String.Table.t = String.Table.create ()

let add_delegate pk = ignore (String.Table.add delegates_tbl ~key:pk ~data:())

(* populated during validation pass *)
let accounts_tbl : unit String.Table.t = String.Table.create ()

let add_account pk =
  match String.Table.add accounts_tbl ~key:pk ~data:() with
  | `Ok ->
      true
  | `Duplicate ->
      false

let valid_pk pk = Or_error.is_ok @@ Public_key.Compressed.of_base58_check pk

let is_pending pk =
  List.mem ["pending"; "finoa"; "secret"] pk ~equal:String.Caseless.equal

let no_delegatee pk = String.is_empty pk || String.equal pk "0"

let slot_duration_ms =
  Consensus.Configuration.t
    ~constraint_constants:Genesis_constants.Constraint_constants.compiled
    ~protocol_constants:Genesis_constants.compiled.protocol
  |> Consensus.Configuration.slot_duration

(* a month = 30 days, for purposes of vesting *)
let slots_per_month = 30 * 24 * 60 * 60 * 1000 / slot_duration_ms

let valid_mina_amount amount =
  let is_num_string s = String.for_all s ~f:Char.is_digit in
  match String.split ~on:'.' amount with
  | [whole] ->
      is_num_string whole
  | [whole; decimal] when String.length decimal <= 9 ->
      is_num_string whole && is_num_string decimal
  | _ ->
      false

(* for delegatee that does not have an entry in the TSV,
   generate an entry with zero balance, untimed
*)
let generate_delegate_account ~logger delegatee_pk =
  [%log info] "Generating account for delegatee $delegatee"
    ~metadata:[("delegatee", `String delegatee_pk)] ;
  let pk = Some delegatee_pk in
  let balance = Currency.Balance.zero in
  let timing = None in
  let delegate = None in
  { Runtime_config.Json_layout.Accounts.Single.default with
    pk
  ; balance
  ; timing
  ; delegate }

let generate_missing_delegate_accounts ~logger =
  (* for each delegate that doesn't have a corresponding account,
     generate an account
  *)
  let delegates = String.Table.keys delegates_tbl in
  let missing_delegates =
    List.filter delegates ~f:(fun delegate ->
        not (String.Table.mem accounts_tbl delegate) )
  in
  let delegate_accounts =
    List.map missing_delegates ~f:(generate_delegate_account ~logger)
  in
  (delegate_accounts, List.length delegate_accounts)

let runtime_config_account ~logger ~wallet_pk ~amount ~initial_min_balance
    ~cliff_time_months ~cliff_amount ~unlock_frequency ~unlock_amount
    ~delegatee_pk ~dummy_pks =
  [%log info] "Processing record for $wallet_pk"
    ~metadata:[("wallet_pk", `String wallet_pk)] ;
  let pk, dummy_pks' =
    if is_pending wallet_pk then
      match dummy_pks with
      | pk :: tl ->
          (* make sure dummy key isn't same as any real key *)
          let pk_str = Public_key.Compressed.to_base58_check pk in
          if String.Table.mem accounts_tbl pk_str then
            failwith "Dummy key found among real keys" ;
          (Some pk_str, tl)
      | _ ->
          failwith "Ran out of dummy public keys"
    else (Some wallet_pk, dummy_pks)
  in
  let balance = Currency.Balance.of_formatted_string amount in
  let initial_minimum_balance =
    (* if omitted in the TSV, use balance *)
    if String.is_empty initial_min_balance then balance
    else Currency.Balance.of_formatted_string initial_min_balance
  in
  let cliff_time =
    Global_slot.of_int (Int.of_string cliff_time_months * slots_per_month)
  in
  let cliff_amount = Currency.Amount.of_formatted_string cliff_amount in
  let vesting_period =
    match Int.of_string unlock_frequency with
    | 0 ->
        Global_slot.of_int 1
    | 1 ->
        Global_slot.of_int slots_per_month
    | _ ->
        failwithf "Expected unlock frequency to be 0 or 1, got %s"
          unlock_frequency ()
  in
  let vesting_increment = Currency.Amount.of_formatted_string unlock_amount in
  let timing =
    Some
      { Runtime_config.Json_layout.Accounts.Single.Timed.initial_minimum_balance
      ; cliff_time
      ; cliff_amount
      ; vesting_period
      ; vesting_increment }
  in
  let delegate =
    (* 0 or empty string denotes "no delegation" *)
    if no_delegatee delegatee_pk then None else Some delegatee_pk
  in
  ( { Runtime_config.Json_layout.Accounts.Single.default with
      pk
    ; balance
    ; timing
    ; delegate }
  , dummy_pks' )

let account_of_tsv ~logger tsv dummy_pks =
  match String.split tsv ~on:'\t' with
  | [ wallet_pk
    ; amount
    ; initial_min_balance
    ; cliff_time_months
    ; cliff_amount
    ; unlock_frequency
    ; unlock_amount
    ; delegatee_pk ] ->
      runtime_config_account ~logger ~wallet_pk ~amount ~initial_min_balance
        ~cliff_time_months ~cliff_amount ~unlock_frequency ~unlock_amount
        ~delegatee_pk ~dummy_pks
  | _ ->
      (* should not occur, we've already validated the record *)
      failwithf "TSV line does not contain expected number of fields: %s" tsv
        ()

let validate_fields ~wallet_pk ~amount ~initial_min_balance ~cliff_time_months
    ~cliff_amount ~unlock_frequency ~unlock_amount ~delegatee_pk =
  let pending_wallet_pk = is_pending wallet_pk in
  let valid_wallet_pk = pending_wallet_pk || valid_pk wallet_pk in
  let not_duplicate_wallet_pk = pending_wallet_pk || add_account wallet_pk in
  let valid_amount = valid_mina_amount amount in
  let valid_init_min_balance =
    String.is_empty initial_min_balance
    || valid_mina_amount initial_min_balance
  in
  let valid_cliff_time_months =
    try
      let n = Int.of_string cliff_time_months in
      n >= 0
    with _ -> false
  in
  let valid_cliff_amount = valid_mina_amount cliff_amount in
  let valid_unlock_frequency =
    List.mem ["0"; "1"] unlock_frequency ~equal:String.equal
  in
  let valid_unlock_amount = valid_mina_amount unlock_amount in
  let valid_delegatee_pk =
    no_delegatee delegatee_pk
    || (add_delegate delegatee_pk ; valid_pk delegatee_pk)
  in
  let valid_field_descs =
    [ ("wallet_pk", valid_wallet_pk)
    ; ("wallet_pk (duplicate)", not_duplicate_wallet_pk)
    ; ("amount", valid_amount)
    ; ("initial_minimum_balance", valid_init_min_balance)
    ; ("cliff_time_months", valid_cliff_time_months)
    ; ("cliff_amount", valid_cliff_amount)
    ; ("unlock_frequency", valid_unlock_frequency)
    ; ("unlock_amount", valid_unlock_amount)
    ; ("delegatee_pk", valid_delegatee_pk) ]
  in
  let valid_str = "VALID" in
  let invalid_fields =
    List.map valid_field_descs ~f:(fun (field, valid) ->
        if valid then valid_str else field )
    |> List.filter ~f:(fun field -> not (String.equal field valid_str))
    |> String.concat ~sep:","
  in
  if String.is_empty invalid_fields then None else Some invalid_fields

let validate_record tsv =
  match String.split tsv ~on:'\t' with
  | [ wallet_pk
    ; amount
    ; initial_min_balance
    ; cliff_time_months
    ; cliff_amount
    ; unlock_frequency
    ; unlock_amount
    ; delegatee_pk ] ->
      validate_fields ~wallet_pk ~amount ~initial_min_balance
        ~cliff_time_months ~cliff_amount ~unlock_frequency ~unlock_amount
        ~delegatee_pk
  | _ ->
      Some "TSV line does not contain expected number of fields"

let remove_commas s = String.filter s ~f:(fun c -> not (Char.equal c ','))

let main ~tsv_file ~output_file () =
  let logger = Logger.create () in
  (* validation pass *)
  let validation_errors =
    In_channel.with_file tsv_file ~f:(fun in_channel ->
        [%log info] "Opened TSV file $tsv_file for validation"
          ~metadata:[("tsv_file", `String tsv_file)] ;
        let rec go num_accounts validation_errors =
          match In_channel.input_line in_channel with
          | Some line ->
              let underscored_line = remove_commas line in
              let validation_errors =
                match validate_record underscored_line with
                | None ->
                    validation_errors
                | Some invalid_fields ->
                    [%log error]
                      "Validation failure at row $row, invalid fields: \
                       $invalid_fields"
                      ~metadata:
                        [ ("row", `Int (num_accounts + 2))
                        ; ("invalid_fields", `String invalid_fields) ] ;
                    true
              in
              go (num_accounts + 1) validation_errors
          | None ->
              validation_errors
        in
        (* skip first line *)
        let _headers = In_channel.input_line in_channel in
        go 0 false )
  in
  if validation_errors then (
    [%log fatal] "Input has validation errors, exiting" ;
    Core_kernel.exit 1 )
  else [%log info] "No validation errors found" ;
  (* translation pass *)
  let provided_accounts, num_accounts =
    In_channel.with_file tsv_file ~f:(fun in_channel ->
        [%log info] "Opened TSV file $tsv_file for translation"
          ~metadata:[("tsv_file", `String tsv_file)] ;
        let rec go accounts num_accounts dummy_pks =
          match In_channel.input_line in_channel with
          | Some line ->
              let underscored_line = remove_commas line in
              let account, dummy_pks' =
                account_of_tsv ~logger underscored_line dummy_pks
              in
              go (account :: accounts) (num_accounts + 1) dummy_pks'
          | None ->
              (List.rev accounts, num_accounts)
        in
        (* skip first line *)
        let _headers = In_channel.input_line in_channel in
        let num_dummy_pks = 2000 in
        let dummy_pks =
          Quickcheck.random_value
            (Quickcheck.Generator.list_with_length num_dummy_pks
               Public_key.Compressed.gen)
        in
        if List.contains_dup dummy_pks ~compare:Public_key.Compressed.compare
        then failwith "Dummy keys contains a duplicate" ;
        go [] 0 dummy_pks )
  in
  [%log info] "Processed %d records" num_accounts ;
  let generated_accounts, num_generated =
    generate_missing_delegate_accounts ~logger
  in
  [%log info] "Generated %d delegate accounts" num_generated ;
  [%log info] "Writing JSON output" ;
  let accounts = provided_accounts @ generated_accounts in
  Out_channel.with_file output_file ~f:(fun out_channel ->
      let json =
        `List (List.map accounts ~f:Runtime_config.Accounts.Single.to_yojson)
      in
      Out_channel.output_string out_channel (Yojson.Safe.pretty_to_string json) ;
      Out_channel.newline out_channel ) ;
  return ()

let () =
  Command.(
    run
      (let open Let_syntax in
      async
        ~summary:"Convert tab-separated-values genesis ledger to JSON format"
        (let%map output_file =
           Param.flag "--output-file"
             ~doc:
               "PATH File that will contain the genesis ledger in JSON format"
             Param.(required string)
         and tsv_file =
           Param.flag "--tsv-file"
             ~doc:
               "PATH File containing genesis ledger in tab-separated-value \
                format"
             Param.(required string)
         in
         main ~tsv_file ~output_file)))
