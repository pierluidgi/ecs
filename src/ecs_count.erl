-module(ecs_count).
-export([like/2, claim/2]).


%
like(Block, CommentKey) -> increment(Block, CommentKey, <<"like">>).

%
claim(Block, CommentKey) -> increment(Block, CommentKey, <<"claim">>).


increment(Block, CommentKey, Field) ->
  increment(Block, CommentKey, Field, 1).

increment(Block, CommentKey, Field, N) ->
  S = #{
    status      => ok,
    block       => Block,
    comment_key => CommentKey,
    field       => Field,
    n           => N,
    new_block   => undefined,
    comment     => undefined
  },

  % Add fun list
  FunList = [
    fun find_comment/1,
    fun inc_counter/1
  ],

  %% Case recursion tru FunList
  #{status := Status, new_block := NewBlock} = ecs_misc:c_r(FunList, S),

  %io:format("inc debug: ~w:~w ~p~n", [?MODULE, ?LINE, Status]),

  case Status of
    ok         -> {ok, NewBlock};
    {ok, done} -> {ok, NewBlock};
    Else       -> Else
  end.


%
find_comment(S = #{block := #{<<"comments">> := Comments}, comment_key := Key}) ->
  case proplists:get_value(Key, Comments, u) of
    u -> S#{status := {err, {comment_not_found, <<"sfd">>}}};
    Comment -> S#{comment := Comment}
  end;
find_comment(S) -> S#{status := {err, {comments_not_found, <<"sfd">>}}}.


%
inc_counter(S = #{comment     := Comment, 
                  field       := Field, 
                  n           := N, 
                  block       := Block = #{<<"comments">> := Comments}, 
                  comment_key := Key}) ->
  Count = maps:get(Field, Comment, 0),
  NewComment = Comment#{Field => Count + N},
  NewBlock = Block#{<<"comments">> := lists:keystore(Key, 1, Comments, {Key, NewComment})},
  S#{block := NewBlock}.



