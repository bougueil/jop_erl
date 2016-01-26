JOP
===

journal in ets {key, operation} and dump ets in files sorted by dates and by keys.  
only R18

Test
-----

```sh
    $ make ct
```






# Erlang JOP: an in-memory key value logger. #

2015 Renaud Mariana.

__Version:__ 1.0.0.

## Erlang JOP

Erlang JOP logs key-values in an ETS table that is eventually written in 2 files:
One file contains values sorted by time and the other, values sorted by keys.
So it's very easy to read one or the other log files and concentrate on temporal or spatial issues. 

The logger can be called by any process.

Usage:
------

Its usage is very simple.

```erlang

Tab = mynewlog,
true = jop:init(Tab),

jop:log(Tab, issue_aa, {vv,112}),
...
Fn = jop:dump(Tab),

[io:format("~nContent of ~s:~n~s",[Fn++E,element(2,file:read_file(Fn++E))]) || E <- ["dates", "keys"]].
```


## Build

```
$ make
```

