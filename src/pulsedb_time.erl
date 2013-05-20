-module(pulsedb_time).

-export([daystart/1, timestamp/1, date_time/1]).


daystart(UTCms) when is_integer(UTCms) ->
  % calendar:datetime_to_gregorian_seconds({Date, {0,0,0}})
  % DaystartMilliSeconds = UTCms - calendar:datetime_to_gregorian_seconds({{1970,1,1}, {0,0,0}})*1000,
  DayMS = timer:hours(24),
  (UTCms div DayMS)*DayMS.



% Convert seconds to milliseconds
timestamp(UnixTime) when is_integer(UnixTime), UnixTime < 4000000000 ->
  UnixTime * 1000;

% No convertion needed
timestamp(UTC) when is_integer(UTC) ->
  UTC;

% Convert given {Date, Time} or {Megasec, Sec, Microsec} to millisecond timestamp
timestamp({{_Y,_Mon,_D} = Day,{H,Min,S}}) ->
  timestamp({Day, {H,Min,S, 0}});

timestamp({{_Y,_Mon,_D} = Day,{H,Min,S, Milli}}) ->
  GregSeconds_Zero = calendar:datetime_to_gregorian_seconds({{1970,1,1}, {0,0,0}}),
  GregSeconds_Now = calendar:datetime_to_gregorian_seconds({Day,{H,Min,S}}),
  (GregSeconds_Now - GregSeconds_Zero)*1000 + Milli;

timestamp({Megaseconds, Seconds, Microseconds}) ->
  (Megaseconds*1000000 + Seconds)*1000 + Microseconds div 1000.


date_time(Day) when length(Day) == 10 ->
  [Y,M,D] = string:tokens(Day, "-"),
  {{to_i(Y),to_i(M),to_i(D)},{0,0,0}};

date_time({Y,M,D}) when is_integer(Y),is_integer(M),is_integer(D) ->
  {{Y,M,D},{0,0,0}};

date_time(Timestamp) when is_number(Timestamp) ->
  GregSeconds_Zero = calendar:datetime_to_gregorian_seconds({{1970,1,1}, {0,0,0}}),
  GregSeconds = GregSeconds_Zero + Timestamp div 1000,
  calendar:gregorian_seconds_to_datetime(GregSeconds).


to_i(L) -> list_to_integer(L).