-module(ecs_basic_SUITE).
-include_lib("common_test/include/ct.hrl").


-export([all/0]).
-export([test1/1, test2/1]).
 

all() -> [test1,test2].
 
test1(_Config) ->
  1 = 1.
 

test2(_Config) ->
  New = ecs:new(),
  New.

