%% Copyright (c) 2015, Renaud Mariana <rmariana@gmail.com>
%%
%% Permission to use, copy, modify, and/or distribute this software for any
%% purpose with or without fee is hereby granted, provided that the above
%% copyright notice and this permission notice appear in all copies.
%%
%% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
%% WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
%% MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
%% ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
%% WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
%% ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
%% OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

-module(jop).

-export([init/1, log/3, dump/1, clear/1]).
-define(tag_start,<<"jop_start">>).
-compile({inline,log/3}).

-spec init(atom()) -> true.
init(Tab) -> clear(Tab).

-spec clear(atom()) -> true.
clear(Tab) ->
    catch ets:delete(Tab),
    _ = ets:new(Tab,[bag, named_table, public]),
    log(Tab, ?tag_start, <<>>).

-spec log(Tab::atom(), Key::any(), Op::any()) -> true.
log(Tab, Key, Op) -> ets:insert(Tab, {Key, Op, erlang:monotonic_time(micro_seconds)}).

%% dump ets logs in ordered timestamps & ordered keys files
%% delete also the ets log
-spec dump(Tab::atom()) -> iolist().
dump(Tab) -> 
    Date = date_str(),
    Fname = fname(Tab, Date),
    {ok, Fd} = file:open([Fname,"dates"], [write]),
    {ok, Fb} = file:open([Fname,"keys"], [write]),
    [{_,_,T0}] = ets:lookup(Tab, ?tag_start),
    ets:delete(Tab, ?tag_start),
    [io:format(Fd, "~s ~w: ~w~n", [time_us(T-T0), K, B]) 
     || {K,B,T} <-  lists:keysort(3, ets:tab2list(Tab))],
    [io:format(Fb, "~w: ~w ~s~n", [K, B, time_us(T-T0)]) 
     || {K,B,T} <- lists:keysort(1, ets:tab2list(Tab))],
    _ = [file:close(Fi)|| Fi <- [Fd,Fb]],
    ets:delete(Tab),
    Fname.

%%@private
fname(Tab, Date) -> ["jop_", atom_to_list(Tab), Date, "_"].
	
date_str() ->
    HMS = lists:flatten([tuple_to_list(Y)|| Y <- tuple_to_list(calendar:universal_time_to_local_time(calendar:universal_time()))]),
    io_lib:format(".~p_~2.2.0w_~2.2.0w_~2.2.0w.~2.2.0w.~2.2.0w", HMS).

time_us(Duration_us) ->
    Sec = Duration_us div 1000000,
    Rem_us = Duration_us - Sec*1000000,
    Ms = Rem_us div 1000,
    Us = Rem_us - Ms*1000,
    {_, {H,M,S}} = calendar:gregorian_seconds_to_datetime(Sec),
    io_lib:format("~2.2.0w:~2.2.0w:~2.2.0w_~3.3.0w.~3.3.0w", [H, M, S, Ms, Us]).

