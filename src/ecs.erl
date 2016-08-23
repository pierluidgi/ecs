-module(ecs).

-include("ecs.hrl").

-export([
  new/0, new/1,
  get/1,
  test/0,
  add/2, add/3, del/2, like/2, claim/2]).



% json encode possible struct
-type block() :: #{
    binary()  => binary(),            %% <<"bid">>
    binary()  => binary()|undefined,  %% <<"root">>
    binary()  => binary()|undefined,  %% <<"last_child">>
    binary()  => list(),              %% <<"comments">>
    binary()  => map(),               %% <<"stat">>
    binary()  => list()               %% <<"cats">>
  }.
-export_type([block/0]).


% json encode possible struct
%-type comment() :: #{
%    binary()  => binary(),            %% <<"cid">>
%    binary()  => non_neg_integer(),   %% <<"level">>
%    binary()  => binary(),            %% <<"type">> => <<"comment">>
%    binary()  => binary(),            %% <<"text">>
%    binary()  => map(),               %% <<"owner">>
%    binary()  => [],                  %% <<"flags">>
%    binary()  => non_neg_integer(),   %% <<"like">>
%    binary()  => non_neg_integer()    %% <<"claim">>
%  }.
-type comment() :: map().
-export_type([comment/0]).

-type clink() :: #{
    type  => link,
    bkey  => binary()
  }.
-export_type([clink/0]).


%% See ?CB in include/ecs.hrl
-spec new() -> block(). 
new() ->
  Bid = ecs_misc:random_bin(16),
  new(Bid).
new(Bid) ->
  ?CB#{<<"bid">> := Bid, <<"rid">> := Bid, <<"lid">> := Bid}.

-spec get(block()) -> list().
get(#{<<"comments">> := Comments}) -> 
  {ok, [V || {_K, V} <- Comments]}.


-spec add(block(), comment()) -> {ok, block()}|err_answer().
add(Block, Comment) -> 
  ecs_add:add(Block, ?C#{<<"comment">> := Comment}).


-spec add(block(), binary(), comment()) -> {ok, block()}|{parent_not_found, list()}|err_answer().
add(Block, ParentCommentKey, Comment) -> 
  ecs_add:add(Block, ParentCommentKey, Comment).


-spec merge(block(), list()) -> {ok, block()}|err_answer().
merge(Block, Comments) ->
  ecs_merge:merge(Block, Comments).


-spec del(block(), binary()) -> {ok, block()}|{comment_not_found, list()}|err_answer().
del(Block, Cid) -> 
  ecs_del:del(Block, Cid).


-spec like(block(), binary()) -> {ok, block()}|{comment_not_found, list()}|err_answer().
like(Block, Cid) -> 
  ecs_count:inc(Block, Cid, <<"like">>).


-spec claim(block(), binary()) -> {ok, block()}|{comment_not_found, list()}|err_answer().
claim(Block, Cid) -> 
  ecs_count:inc(Block, Cid, <<"claim">>).


test() -> 1.
