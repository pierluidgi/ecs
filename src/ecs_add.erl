-module(ecs_add).
-export([add/3]).


add(Block = #{<<"comments">> := Comments}, ParentCommentKey, Comment) ->
  % Add state
  S = #{
    status      => ok,
    block       => Block,
    c_acc       => [],                % For recursion search parrent comment
    c_rest      => Comments,          % For recursion search parrent comment 
    parent      => ParentCommentKey,
    new_block   => undefined,
    comment     => Comment,
    level       => 0,                 % Comment level
    parent_key  => ParentCommentKey
  },
 
  % Add fun list
  FunList = [
    fun find_parent/1,
    fun insert_comment/1
  ],
  
  %% Case recursion tru FunList
  #{status := Status, new_block := NewBlock} = ecs_misc:c_r(FunList, S),

  %io:format("Add debug: ~w:~w ~p~n", [?MODULE, ?LINE, Status]),

  case Status of
    ok         -> {ok, NewBlock};
    {ok, done} -> {ok, NewBlock};
    Else       -> Else
  end.


%
find_parent(S = #{c_rest := [Parent = #{<<"ckey">> := K}|Rest], c_acc := Acc, parent_key := PK}) ->
  case PK == K of
    false -> find_parent(S#{c_rest := Rest, c_acc := [Parent|Acc]});
    true -> 
      #{comment := Comment} = S, 
      #{<<"level">> := Level} = Parent,
      NewComment = Comment#{<<"level">> := Level+1},
      S#{c_rest := Rest, c_acc := [Parent|Acc], comment := NewComment, level := Level+1}
  end;
find_parent(S = #{c_rest := []}) -> S#{status := {err, {parent_not_found, <<"sfd">>}}}.


%
insert_comment(S = #{c_rest := [C = #{<<"level">> := L}|Rest], c_acc := Acc, level := CL}) -> 
  case L < CL of
    false -> insert_comment(S#{c_rest := Rest, c_acc := [C|Acc]});
    true -> 
      #{comment := Comment, block := Block} = S,
      NewComments = lists:append(lists:reverse(Acc), [Comment], [C|Rest]),
      NewBlock = Block#{<<"comments">> := NewComments},
      S#{block := NewBlock}
  end;
insert_comment(S = #{c_rest := [], block := Block, c_acc := Acc, comment := Comment}) ->
  NewComments = lists:reverse([Comment|Acc]),
  NewBlock = Block#{<<"comments">> := NewComments},
  S#{block := NewBlock}.
  



