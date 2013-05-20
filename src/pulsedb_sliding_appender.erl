-module(pulsedb_sliding_appender).
-include("pulsedb.hrl").
-export([open/1, append/2]).

open(Path) ->
  {ok, #dbstate{meta_path = Path}}.


append({row,TS,Values} = Row, #dbstate{meta_path = Meta, current_day = undefined}) ->
  MetaFile = filename:join(Meta, ".pulseinfo"),
  ok = filelib:ensure_dir(MetaFile),
  case file:read_file_info(MetaFile) of
    {ok, _} -> ok;
    _ -> ok = file:write_file(MetaFile, "pulsedb\n")
  end,
  {{Y,M,D} = Day,_} = pulsedb_time:date_time(TS),
  Path = lists:flatten(io_lib:format("~s/~4..0B/~2..0B/~2..0B.pulse", [Meta, Y,M,D])),

  Options = case Values of
    [{_,_}|_] -> [{columns, [iolist_to_binary(io_lib:format("~s",[K])) || {K,_} <- Values]}];
    _ -> []
  end,
  {ok, #dbstate{} = Appender} = pulsedb_appender:open(Path, Options),
  append(Row, Appender#dbstate{current_day = Day, meta_path = Meta});

append({row,TS,_} = Row, #dbstate{meta_path = Meta, current_day = CurrentDay} = Pulsedb) ->
  {Day,_} = pulsedb_time:date_time(TS),
  case Day of
    CurrentDay -> 
      pulsedb_appender:append(Row, Pulsedb);
    _ ->
      pulsedb_appender:close(Pulsedb),
      append(Row, #dbstate{meta_path = Meta})
  end.
