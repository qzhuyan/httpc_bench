% https://github.com/benoitc/hackney

-module(httpc_bench_ehttpc).
-include("httpc_bench.hrl").

-export([
    get/0,
    start/1,
    stop/0
]).

%% public
get() ->
    N = case get(pool_sel_n) of
                undefined ->
                        << 131, 88, 100, Size:16/big-unsigned-integer, _Node:Size/bytes,
                           PidInt:32/integer, _Left/binary>>
                                = term_to_binary(self(), [{compressed,0}]),
                        put(pool_sel_n, PidInt),
                        PidInt;
                X when is_integer(X) ->
                        X
        end,

    case ehttpc:request({httpc_bench, N}, get, {?PATH, ?HEADERS}, ?TIMEOUT) of
        {ok, _, _, _} ->
            ok;
        {error, Reason} ->
            {error, Reason}
    end.

start(PoolSize) ->
    application:ensure_all_started(ehttpc),
    PoolOpts = [{host, "127.0.0.1"},
                {port, 8080},
                {enable_pipelining, true},
                {pool_size, PoolSize},
                {pool_type, hash},
                {connect_timeout, 5000},
                {retry, 5},
                {retry_timeout, 1000}
                ],
    {ok, _} = ehttpc_sup:start_pool(httpc_bench, PoolOpts).

stop() ->
    ehttpc_sup:stop_pool(httpc_bench).