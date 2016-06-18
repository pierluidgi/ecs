-module(ecs_misc).
-compile(export_all).

% Case recursion for function list
c_r(FunList, Args) ->
  case_recursion(FunList, Args).
case_recursion(FunList, Args) ->
  Fun = fun (F, [N|R], Acc = #{status := ok}) -> F(F, R, apply(N, [Acc])); (_F, _,  Acc) -> Acc end,
  Fun(Fun, FunList, Args).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%               
%% Randoms                                           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%               
random_bin(N)  -> list_to_binary(random_str(N)).
%% random string
random_str(short) -> random_str(4);
random_str(long) -> random_str(8);
random_str(Length) ->
  AllowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789",
  {A,B,C} = erlang:timestamp(),
  random:seed(A,B,C),
  lists:foldl(
    fun(_, Acc) ->
      [lists:nth(random:uniform(length(AllowedChars)), AllowedChars)] ++ Acc
    end, [], lists:seq(1, Length)).

%
random_int(1) -> 1;
random_int(N) ->
  {A,B,C} = erlang:timestamp(),
  random:seed(A,B,C),
  random:uniform(N).
random_int(S, T) when S > 0, T > 0, T > S ->
  {A,B,C} = erlang:timestamp(),
  random:seed(A,B,C),
  random:uniform(T-S+1)+S-1.

