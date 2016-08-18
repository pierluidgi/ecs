-module(ecs_add).
-export([add/2, add/3]).


add(Block = #{<<"rid">> := Rid}, Comment) ->
  add(Block, Rid, Comment).
add(Block = #{<<"comments">> := Comments, <<"rid">> := Rid}, ParentCommentKey, Comment) ->
  % Add state
  S = #{
    status      => ok,
    rid         => Rid,
    block       => Block,
    c_acc       => [],                % For recursion search parrent comment
    c_rest      => Comments,          % For recursion search parrent comment 
    parent      => ParentCommentKey,
    parent_flag => false,
    new_block   => undefined,
    comment     => Comment,
    len         => 0,
    level       => 0                 % Comment level
  },
 
  % Add fun list
  FunList = [
    fun construct_comment1/1,
    fun construct_comment2/1,
    fun root_parent/1,
    fun find_parent/1,
    fun insert_comment/1
  ],
  
  %% Case recursion tru FunList
  #{status := Status, new_block := NewBlock, len := Len} = ecs_misc:c_r(FunList, S),

  io:format("Add debug: ~p~n", [{?MODULE, ?LINE, Status, Len}]),

  case Status of
    ok         -> {ok, NewBlock};
    {ok, done} -> {ok, NewBlock};
    Else       -> Else
  end.


% Add like and clime counters
construct_comment1(S = #{comment := Comment}) when is_map(Comment) ->
  NewComment = 
    Comment#{<<"cid">>     => ecs_misc:random_bin(8),
             <<"like">>    => 0, 
             <<"claim">>   => 0, 
             <<"deleted">> => false},
  S#{comment := NewComment}.

% Add parent field
construct_comment2(S = #{rid := Rid, parent := Parent }) when Rid == Parent -> 
  S;
construct_comment2(S = #{comment := Comment, parent := Parent }) ->
  NewComment = Comment#{<<"parent">> => Parent},
  S#{comment := NewComment}.



root_parent(S = #{rid := Rid, parent := PK, c_rest := Comments, comment := Comment}) when Rid == PK ->
  NewComment = Comment#{<<"level">> => 1},
  S#{c_rest := [], c_acc := Comments, comment := NewComment, level := 1, parent_flag := true};
root_parent(S) -> S.


%
find_parent(S = #{parent_flag := true}) -> S;
find_parent(S = #{c_rest := [Parent = #{<<"cid">> := K}|Rest], 
                  c_acc := Acc, 
                  parent := PK, 
                  parent_flag := false}) ->
  case PK == K of
    false -> find_parent(S#{c_rest := Rest, c_acc := [Parent|Acc]});
    true -> 
      #{comment := Comment} = S, 
      #{<<"level">> := Level} = Parent,
      NewComment = Comment#{<<"level">> := Level+1},
      S#{c_rest := Rest, c_acc := [Parent|Acc], comment := NewComment, level := Level+1}
  end;
find_parent(S = #{c_rest := [ParentCandidate|Rest],
                  c_acc := Acc,
                  parent_flag := false}) ->
  S#{c_rest := Rest, c_acc := [ParentCandidate|Acc]};
find_parent(S = #{c_rest := [], parent_flag := false}) -> S#{status := {err, {parent_not_found, <<"sfd">>}}}.


%
insert_comment(S = #{c_rest := [C = #{<<"level">> := L}|Rest], c_acc := Acc, level := CL}) -> 
  case L < CL of
    false -> insert_comment(S#{c_rest := Rest, c_acc := [C|Acc]});
    true -> 
      #{comment := Comment, block := Block} = S,
      NewComments = lists:append([lists:reverse(Acc), [Comment], [C|Rest]]),
      Len = length(NewComments),
      NewBlock = Block#{<<"comments">> := NewComments},
      S#{new_block := NewBlock, len := Len}
  end;
insert_comment(S = #{c_rest := [], block := Block, c_acc := Acc, comment := Comment}) ->
  NewComments = lists:append(Acc, [Comment]),
  Len = length(NewComments),
  NewBlock = Block#{<<"comments">> := NewComments},
  S#{new_block := NewBlock, len := Len}.
  



