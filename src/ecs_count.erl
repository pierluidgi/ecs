-module(ecs_count).
-export([inc/3]).

-include("ecs.hrl").


inc(Block, Cid, Field) ->
  inc(Block, Cid, Field, 1).

inc(Block = #{<<"comments">> := Comments}, Cid, Field, N) ->
  S = #{
    status      => ok,
    cid         => Cid,
    field       => Field,
    n           => N,
    new_block   => undefined,
    comments    => Comments,
    comment     => undefined,
    acc         => []
  },

  % Add fun list
  FunList = [
    fun find/1,
    fun inc_counter/1,
    fun make_new_comments/1
  ],

  %% Case recursion tru FunList
  #{status := Status, comments := NewComments} = ecs_misc:c_r(FunList, S),

  %io:format("inc debug: ~w:~w ~p~n", [?MODULE, ?LINE, Status]),

  case Status of
    ok         -> {ok, Block#{<<"comments">> := NewComments}};
    {ok, done} -> {ok, Block#{<<"comments">> := NewComments}};
    Else       -> Else
  end.


%
%
find(S = #{comments := [C = #{<<"cid">> := Cid2}|Comments], cid := Cid1}) when Cid1 == Cid2 ->
  S#{comment := C, comments := Comments};
%
find(S = #{comments := [C|Comments], acc := Acc}) ->
  find(S#{comments := Comments, acc := [C|Acc]});
%
find(S = #{comments := []}) ->
  S#{status := {err, {comment_not_found, ?p([])}} }.



%
inc_counter(S = #{comment     := Comment, 
                  field       := Field, 
                  n           := N}) -> 
  Count = maps:get(Field, Comment, 0),
  case is_integer(Count) of
    true -> 
      NewComment = Comment#{Field => Count + N},
      S#{comment := NewComment};
    false -> 
      S#{status := {err, {wrong_field_value_type, ?p([])}} }
  end.



%
make_new_comments(S = #{comments := Comments, comment := Comment, acc := Acc}) ->
  NewComments = lists:append([lists:reverse(Acc), [Comment], Comments]),
  S#{comments := NewComments}.






