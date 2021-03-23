load("@bazel_skylib//rules:common_settings.bzl",
     "bool_flag",
     "string_flag",
     "BuildSettingInfo")

MinaProfileProvider = provider(
    doc = "",
    fields = {
        "profile": "Dictionary of parameters"
    }
)

# def _mina_test_config_impl(ctx):
#     return [DefaultInfo(files = ctx.attr.config[DefaultInfo].files)]

# mina_test_config = rule(
#     implementation = _mina_test_config_impl,
#     # defaults are from src/config/dev.mlh
#     attrs = {
#         "config": attr.label()
#     }
# )

###########################
def _mina_config_impl(ctx):
    _profile = ctx.attr.profile[MinaProfileProvider].profile
    runfiles = ctx.runfiles(files = [ctx.outputs.out])

    ctx.actions.expand_template(
        output = ctx.outputs.out,
        template = ctx.file._template,
        substitutions = {
            "{PROFILE}": _profile["name"], # ctx.label.name,
            "{LEDGER_DEPTH}": _profile["ledger_depth"],
            "{CURVE_SIZE}": _profile["curve_size"],
            "{COINBASE}"  : _profile["coinbase"],
            "{CONSENSUS_MECHANISM}": _profile["consensus_mechanism"],
            "{CONSENSUS_K}": _profile["consensus_k"],
            "{CONSENSUS_DELTA}": _profile["consensus_delta"],
            "{CONSENSUS_SLOTS_PER_EPOCH}": _profile["consensus_slots_per_epoch"],
            "{CONSENSUS_SLOTS_PER_SUBWINDOW}": _profile["consensus_slots_per_subwindow"],
            "{CONSENSUS_SUBWINDOWS_PER_WINDOW}": _profile["consensus_subwindows_per_window"],
            "{SCAN_STATE_WITH_TPS_GOAL}": _profile["scan_state_with_tps_goal"],
            "{SCAN_STATE_TPS_GOAL_X10}": _profile["scan_state_tps_goal_x10"],
            "{SCAN_STATE_TRANSACTION_CAPACITY_LOG_2}": _profile["scan_state_transaction_capacity_log_2"],
            "{SCAN_STATE_WORK_DELAY}": _profile["scan_state_work_delay"],
            "{DEBUG_LOGS}": _profile["debug_logs"],
            "{CALL_LOGGER}": _profile["call_logger"],
            "{TRACING}": _profile["tracing"],
            "{CACHE_EXCEPTIONS}": _profile["cache_exceptions"],
            "{RECORD_ASYNC_BACKTRACES}": _profile["record_async_backtraces"],

            "{PROOF_LEVEL}": _profile["proof_level"],
            "{TXN_POOL_MAX_SIZE}": _profile["txn_pool_max_size"],

            "{ACCOUNT_CREATION_FEE_INT}": _profile["account_creation_fee_int"],
            "{DEFAULT_TRANSACTION_FEE}": _profile["default_transaction_fee"],
            "{DEFAULT_SNARK_WORKER_FEE}": _profile["default_snark_worker_fee"],
            "{MINIMUM_USER_COMMAND_FEE}": _profile["minimum_user_command_fee"],

            "{CURRENT_PROTOCOL_VERSION}": _profile["current_protocol_version"],
            "{SUPERCHARGED_COINBASE_FACTOR}": _profile["supercharged_coinbase_factor"],

            "{FORKDEF}": _profile["fork"],
            "{FORK_PREVIOUS_LENGTH}": _profile["fork_previous_length"],
            "{FORK_PREVIOUS_STATE_HASH}": _profile["fork_previous_state_hash"],
            "{FORK_PREVIOUS_GLOBAL_SLOT}": _profile["fork_previous_global_slot"],

            "{FEATURE_TOKENS}": _profile["feature_tokens"],
            "{FEATURE_SNAPPS}": _profile["feature_snapps"],

            "{MAINNET}": _profile["mainnet"],

            "{TIME_OFFSETS}": _profile["time_offsets"],
            "{PLUGINS}": _profile["plugins"],
            "{FAKE_HASH}": _profile["fake_hash"],
            "{GENESIS_LEDGER}": _profile["genesis_ledger"],
            "{GENESIS_STATE_TIMESTAMP}": _profile["genesis_state_timestamp"],
            "{BLOCK_WINDOW_DURATION}": _profile["block_window_duration"],
            "{INTEGRATION_TESTS}": _profile["integration_tests"],
            "{FORCE_UPDATES}": _profile["force_updates"],
            "{DOWNLOAD_SNARK_KEYS}": _profile["download_snark_keys"],
            "{MOCK_FRONTEND_DATA}": _profile["mock_frontend_data"],
            "{PRINT_VERSIONED_TYPES}": _profile["print_versioned_types"],
            "{DAEMON_EXPIRY}": _profile["daemon_expiry"],
            "{TEST_FULL_EPOCH}": _profile["test_full_epoch"],

            "{COMPACTIONDEF}": _profile["compaction"],
            "{COMPACTION_INTERVAL}": _profile["compaction_interval"],
        },
    )
    return [DefaultInfo(files = depset([ctx.outputs.out]), runfiles=runfiles)]

###################
mina_config = rule(
    implementation = _mina_config_impl,
    attrs = dict(
        out     = attr.output(
            doc       = "Experimental.",
            mandatory = True,
        ),
        profile = attr.label(
            doc       = "Experimental.",
            # defaults from src/config/dev.mlh
            default   = "//src/config/dev",
            providers = [MinaProfileProvider]
        ),
        _template = attr.label(
            allow_single_file = True,
            default="//bzl/templates:config.mlh"
        )
    )
)

################################################################
def _mina_profile_impl(ctx):
    ## NB: use lower() to convert True/False
    _profile = dict(
        name = ctx.label.name,
        ledger_depth = str(ctx.attr.ledger_depth[BuildSettingInfo].value),
        curve_size =str(ctx.attr.curve_size[BuildSettingInfo].value),
        coinbase =str(ctx.attr.coinbase[BuildSettingInfo].value),
        consensus_mechanism = ctx.attr.consensus_mechanism[BuildSettingInfo].value,
        consensus_k = str(ctx.attr.consensus_k[BuildSettingInfo].value),
        consensus_delta = str(ctx.attr.consensus_delta[BuildSettingInfo].value),
        consensus_slots_per_epoch = str(ctx.attr.consensus_slots_per_epoch[BuildSettingInfo].value),
        consensus_slots_per_subwindow = str(ctx.attr.consensus_slots_per_subwindow[BuildSettingInfo].value),
        consensus_subwindows_per_window = str(ctx.attr.consensus_subwindows_per_window[BuildSettingInfo].value),
        scan_state_with_tps_goal = str(
            ctx.attr.scan_state_with_tps_goal[BuildSettingInfo].value
        ).lower(),
        scan_state_tps_goal_x10 = str(
            ctx.attr.scan_state_tps_goal_x10[BuildSettingInfo].value
        ),
        scan_state_transaction_capacity_log_2 = str(
            ctx.attr.scan_state_transaction_capacity_log_2[BuildSettingInfo].value
        ),
        scan_state_work_delay = str(ctx.attr.scan_state_work_delay[BuildSettingInfo].value),

        debug_logs =str(ctx.attr.debug_logs[BuildSettingInfo].value).lower(),
        call_logger =str(ctx.attr.call_logger[BuildSettingInfo].value).lower(),
        tracing =str(ctx.attr.tracing[BuildSettingInfo].value).lower(),
        cache_exceptions =str(ctx.attr.cache_exceptions[BuildSettingInfo].value).lower(),
        record_async_backtraces =str(ctx.attr.record_async_backtraces[BuildSettingInfo].value).lower(),

        proof_level = ctx.attr.proof_level[BuildSettingInfo].value,
        txn_pool_max_size =str(ctx.attr.txn_pool_max_size[BuildSettingInfo].value),

        account_creation_fee_int =str(
            ctx.attr.account_creation_fee_int[BuildSettingInfo].value
        ),
        default_transaction_fee =str(
            ctx.attr.default_transaction_fee[BuildSettingInfo].value
        ),
        default_snark_worker_fee =str(
            ctx.attr.default_snark_worker_fee[BuildSettingInfo].value
        ),
        minimum_user_command_fee =str(
            ctx.attr.minimum_user_command_fee[BuildSettingInfo].value
        ),

        current_protocol_version =str(
            ctx.attr.current_protocol_version[BuildSettingInfo].value
        ),
        supercharged_coinbase_factor =str(
            ctx.attr.supercharged_coinbase_factor[BuildSettingInfo].value
        ),
        fork = "define" if ctx.attr.fork[BuildSettingInfo].value else "undef",
        fork_previous_length = str(
            " " + ctx.attr.fork_previous_length[BuildSettingInfo].value
        ) if ctx.attr.fork[BuildSettingInfo].value else "",
        fork_previous_state_hash = str(
            " " + ctx.attr.fork_previous_state_hash[BuildSettingInfo].value
        ) if ctx.attr.fork_previous_state_hash[BuildSettingInfo].value != "" else "",
        fork_previous_global_slot = str(
            " " + ctx.attr.fork_previous_global_slot[BuildSettingInfo].value
        ) if ctx.attr.fork_previous_global_slot[BuildSettingInfo].value else "",

        feature_tokens =str(
            ctx.attr.feature_tokens[BuildSettingInfo].value
        ).lower(),
        feature_snapps =str(
            ctx.attr.feature_snapps[BuildSettingInfo].value
        ).lower(),

        mainnet =str(
            ctx.attr.mainnet[BuildSettingInfo].value
        ).lower(),

        time_offsets =str(
            ctx.attr.time_offsets[BuildSettingInfo].value,
        ).lower(),
        plugins =str(
            ctx.attr.plugins[BuildSettingInfo].value,
        ).lower(),
        fake_hash =str(ctx.attr.fake_hash[BuildSettingInfo].value).lower(),
        genesis_ledger = ctx.attr.genesis_ledger[BuildSettingInfo].value,
        genesis_state_timestamp = ctx.attr.genesis_state_timestamp[BuildSettingInfo].value,
        block_window_duration =str(
            ctx.attr.block_window_duration[BuildSettingInfo].value,
        ),
        integration_tests =str(
            ctx.attr.integration_tests[BuildSettingInfo].value
        ).lower(),
        force_updates =str(
            ctx.attr.force_updates[BuildSettingInfo].value
        ).lower(),
        download_snark_keys =str(
            ctx.attr.download_snark_keys[BuildSettingInfo].value
        ).lower(),
        mock_frontend_data =str(
            ctx.attr.mock_frontend_data[BuildSettingInfo].value
        ).lower(),
        print_versioned_types =str(
            ctx.attr.print_versioned_types[BuildSettingInfo].value,
        ).lower(),
        daemon_expiry = ctx.attr.daemon_expiry[BuildSettingInfo].value,
        test_full_epoch =str(
            ctx.attr.test_full_epoch[BuildSettingInfo].value
        ).lower(),

        compaction = "define" if ctx.attr.compaction[BuildSettingInfo].value else "undef",
        compaction_interval =str(
            " " + str(ctx.attr.compaction_interval[BuildSettingInfo].value)
        ) if ctx.attr.compaction[BuildSettingInfo].value else ""

    )
    # print("_PROFILE: %s" % _profile)
    return [DefaultInfo(), MinaProfileProvider(profile = _profile)]

mina_profile = rule(
    implementation = _mina_profile_impl,
    # defaults are from src/config/dev.mlh
    attrs = {
        # [%%import "/src/config/ledger_depth/small.mlh"]
        "ledger_depth": attr.label(default="//src/config/ledger_depth"),  # 10

        # [%%import "/src/config/curve/medium.mlh"]
        "curve_size": attr.label(default="//src/config/curve_size"), # 255

        # [%%import "/src/config/coinbase/standard.mlh"]
        "coinbase": attr.label(default="//src/config/coinbase"), # 20

        #[%%import "/src/config/supercharged_coinbase_factor/two.mlh"]
        "supercharged_coinbase_factor": attr.label(default="//src/config/coinbase/supercharged_factor"), # 2

        # [%%import "/src/config/consensus/postake_short.mlh"]
        "consensus_mechanism": attr.label(default="//src/config/consensus/mechanism"), # POS
        "consensus_k": attr.label(default="//src/config/consensus/k"),           # 24
        "consensus_delta": attr.label(default="//src/config/consensus/delta"),   # 0
        "consensus_slots_per_epoch": attr.label(default="//src/config/consensus/slots/epoch"), # # 576
        "consensus_slots_per_subwindow": attr.label(
            default="//src/config/consensus/slots/subwindow"), # 2
        "consensus_subwindows_per_window": attr.label(
            default="//src/config/consensus/subwindows/window"), # 3

        # [%%import "/src/config/scan_state/medium.mlh"]
        "scan_state_with_tps_goal": attr.label(
            default="//src/config/scan_state/tps_goal"),         # False
        "scan_state_transaction_capacity_log_2": attr.label(
            default="//src/config/scan_state/txn_capacity/log2"), # 3
        "scan_state_work_delay": attr.label(
            default="//src/config/scan_state/work_delay"),        # 2
        ## WARNING: the following is only used if with_tps_goal = True
        ## but we always include it with unit default
        "scan_state_tps_goal_x10": attr.label(
            default="//src/config/scan_state/tps_goal/x10"
        ),

        # [%%import "/src/config/debug_level/some.mlh"]
        "debug_logs": attr.label(default="//src/config/debug/logs"),         # False
        "call_logger": attr.label(default="//src/config/debug/call_logger"), # False
        "tracing": attr.label(default="//src/config/debug/tracing"),         # True
        "cache_exceptions": attr.label(default="//src/config/debug/cache_exceptions"), # True
        "record_async_backtraces": attr.label(default="//src/config/debug/record_async_backtraces"), # False

        # [%%import "/src/config/proof_level/check.mlh"]
        "proof_level":  attr.label( default="//src/config/proof_level" ),  # "check"

        # [%%import "/src/config/txpool_size.mlh"]
        "txn_pool_max_size": attr.label(default="//src/config/txn_pool/size/max"),  # 3000

        # [%%import "/src/config/account_creation_fee/low.mlh"]
        "account_creation_fee_int": attr.label(
            default="//src/config/fees/account_creation"),  # 0.001

        # [%%import "/src/config/amount_defaults/standard.mlh"]
        "default_transaction_fee": attr.label( default="//src/config/fees/txn" ), # 5
        "default_snark_worker_fee": attr.label( default="//src/config/fees/snark_worker"), # 1
        "minimum_user_command_fee": attr.label( default="//src/config/fees/user_cmd/min" ), # 2

        # [%%import "/src/config/protocol_version/current.mlh"]
        "current_protocol_version": attr.label(
            default="//src/config/protocol/version:current",
        ),

        # [%%import "/src/config/fork.mlh"], fork_at_3757.mlh
        "fork":  attr.label(default="//src/config/fork:disable"),
        ## the following 3 are only enabled if fork:enable ( = fork True)
        "fork_previous_length": attr.label(default="//src/config/fork/prev/length"), # ""
        "fork_previous_state_hash": attr.label(default="//src/config/fork/prev/state_hash"), # 0
        "fork_previous_global_slot": attr.label(default="//src/config/fork/prev/global_slot"), # 0

        # [%%import "/src/config/features/dev.mlh"]
        "feature_tokens": attr.label(default="//src/config/features/tokens"),   # True
        "feature_snapps": attr.label(default="//src/config/features/snapps"),   # True

        "mainnet": attr.label(default="//src/config/mainnet:disable"), # False

        ## src/config/dev.mlh:
        "time_offsets": attr.label(default = "//src/config/time_offsets"), # True
        "plugins": attr.label(default = "//src/config/plugins"),           # True
        "fake_hash": attr.label(default = "//src/config/fake_hash"),       # False
        "block_window_duration": attr.label(default = "//src/config/block_window/duration"), # 2000

        "genesis_ledger": attr.label(default = "//src/config/genesis/ledger"), # "test"
        "genesis_state_timestamp": attr.label(
            default = "//src/config/genesis/state_timestamp"), # "2019-01-30 12:00:00-08:00"

        "integration_tests": attr.label(default = "//src/config/integration_tests"),         # True
        "force_updates": attr.label(default = "//src/config/force_updates"),                 # False
        "download_snark_keys": attr.label(default = "//src/config/snark_keys/download"),     # False
        "mock_frontend_data": attr.label(default = "//src/config/mock_frontend_data"),       # False
        "print_versioned_types": attr.label(default = "//src/config/print_versioned_types"), # False
        "daemon_expiry": attr.label(default = "//src/config/daemon/expiry"),                 # "never"
        "test_full_epoch": attr.label(default = "//src/config/test/epoch_full"),             # False

        "compaction": attr.label(default = "//src/config/compaction"),                       # False
        "compaction_interval": attr.label(default = "//src/config/compaction/interval"),     # 360000
    },
)
