-module(ecs_del).
-export([del/2]).

-include("ecs.hrl").


del(Block = #{<<"comments">> := Comments}, Cid) ->
  S = #{
    status      => ok,
    cid         => Cid,
    comments    => Comments,
    comment     => undefined,
    acc         => []
  },

  % Add fun list
  FunList = [
    fun find/1,
    fun mark_deleted/1,
    fun make_new_comments/1
  ],

  %% Case recursion tru FunList
  #{status := Status, comments := NewComments} = ecs_misc:c_r(FunList, S),

  %io:format("Add debug: ~w:~w ~p~n", [?MODULE, ?LINE, Status]),

  case Status of
    ok         -> {ok, Block#{<<"comments">> := NewComments}};
    {ok, done} -> {ok, Block#{<<"comments">> := NewComments}};
    Else       -> Else
  end.


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
mark_deleted(S = #{comment := Comment}) ->
  NewComment = Comment#{<<"deleted">> => true},
  S#{comment := NewComment}.

%
make_new_comments(S = #{comments := Comments, comment := Comment, acc := Acc}) ->
  NewComments = lists:append([lists:reverse(Acc), [Comment], Comments]),
  S#{comments := NewComments}.
  
