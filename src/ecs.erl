-module(ecs).

-include("ecs.hrl").

-export([
  new/0, 
  get/1,
  add/3, like/2, claim/2]).



% json encode possible struct
-type block() :: #{
    binary()  => binary(),            %% <<"bkey">>
    binary()  => binary()|undefined,  %% <<"root">>
    binary()  => binary()|undefined,  %% <<"last_child">>
    binary()  => list(),              %% <<"comments">>
    binary()  => map(),               %% <<"stat">>
    binary()  => list()               %% <<"cats">>
  }.
-export_type([block/0]).


% json encode possible struct
-type comment() :: #{
    binary()  => binary(),            %% <<"ckey">>
    binary()  => non_neg_integer(),   %% <<"level">>
    binary()  => binary(),            %% <<"type">> => <<"comment">>
    binary()  => binary(),            %% <<"text">>
    binary()  => map(),               %% <<"owner">>
    binary()  => [],                  %% <<"flags">>
    binary()  => non_neg_integer(),   %% <<"like">>
    binary()  => non_neg_integer()    %% <<"claim">>
  }.
-export_type([comment/0]).

-type clink() :: #{
    type  => link,
    bkey  => binary()
  }.
-export_type([clink/0]).


%% See ?BC in include/ecs.hrl
-spec new() -> block(). 
new() ->
  Key = ecs_misc:random_bin(16),
  ?CB#{<<"ckey">> := Key}.


-spec get(block()) -> list().
get(Block = #{<<"comments">> := Comments}) -> 
  {ok, [V || {_K, V} <- Comments]}.


-spec add(block(), binary(), comment()) -> {ok, block()}|{parent_not_found, list()}|err_answer().
add(Block, _ParentCommentKey, _Comment) -> 
  NewBlock = Block,
  {ok, NewBlock}.


-spec like(block(), binary()) -> {ok, block()}|{parent_not_found, list()}|err_answer().
like(Block, CommentKey) -> ecs_count:like(Block, CommentKey).


-spec claim(block(), binary()) -> block().
claim(Block, CommentKey) -> ecs_count:claim(Block, CommentKey).



