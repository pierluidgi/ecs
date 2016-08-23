-module(ecs_merge).

-export([merge/2]).




merge(Block, Comments) -> 

  MergeFun = 
    fun
      (F, B, [C|Cs]) -> F(F, merge_comment(B, C), Cs);
      (_, B, []) -> B
    end,

  NewBlock = MergeFun(MergeFun, Block, lists:reverse(Comments)),

  {ok, NewBlock#{<<"merged">> => true}}.


merge_comment(Block = #{<<"comments">> := BCs, <<"bid">> := Bid}, Comment) ->
  NewComment = Comment#{
             <<"cid">>     => ecs_misc:random_bin(8),
             <<"parent">>  => Bid,
             <<"like">>    => 0,
             <<"level">>   => 1,
             <<"claim">>   => 0,
             <<"deleted">> => false},
  Block#{<<"comments">> := [NewComment|BCs]}.
