
-module(jop_SUITE).
-compile(export_all).
-include_lib("common_test/include/ct.hrl").
-import(ct_helper, [doc/1]).
-import(ct_helper, [name/0]).

%% ct.

all() ->
	ct_helper:all(?MODULE).

%% Tests.

log_and_dump(_) ->
    Tab = myjop,
    true = jop:init(Tab),
    jop:log(Tab, aa, {vv,112}),
    timer:sleep(12),
    true = jop:clear(Tab),
    true = jop:log(Tab, ab, {vv,113}),
    timer:sleep(12),
    true = jop:log(Tab, aa, {vv,112}),
    timer:sleep(12),
    true = jop:log(Tab, ab, {vv,113}),
    Fn = jop:dump(Tab),
    _ = [begin ct:pal(default, ?STD_IMPORTANCE, "~nContent of ~s:~n~s",[Fn++T,element(2,file:read_file(Fn++T))])
     end ||T <- ["dates", "keys"]],
    ok.
