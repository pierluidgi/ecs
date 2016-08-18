
%% Print message with module and line number point
-define(p(Str), list_to_binary(io_lib:format("Mod:~w line:~w ~100P~n", [?MODULE,?LINE, Str, 300]))).


-define(CB, #{ %% Comment Block definition
  <<"bid">>        => undefined,  % (Block id) Unique id for key in DB
  <<"rid">>        => undefined,  % (Root id) link to block with root comment (for jump to begin of thread)
  <<"lid">>        => undefined,  % (Last id) Link to block with last comment (for jump to the end of tread)
  <<"comments">>   => [],         % Comments list
  <<"c_time">>     => os:system_time(seconds),       % Create time 
  <<"m_time">>     => os:system_time(seconds),       % Modify time
  <<"s_time">>     => 0,                             % Save time  (for svart saving)
  <<"m_count">>    => 0,                             % Modifications count (for svart saving)
  <<"stat">>       => #{},        % stat of comments
  <<"cats">>       => []          % log of last cats, for searching comment
  }).


-define(C, #{ %% Comment definition
  <<"cid">>     => ecs_misc:random_bin(8),
  <<"c_time">>  => os:system_time(seconds),       % Create time 
  <<"m_time">>  => os:system_time(seconds),       % Modify time
  <<"level">>   => 0,
  <<"type">>    => comment,
  <<"link">>    => undefined,
  <<"comment">> => undefined,
  <<"parent">>  => undefined,
  <<"like">>    => 0,
  <<"claim">>   => 0
  }).


-define(L, #{ %% Link definition
  <<"level">> => 0,
  <<"type">>  => link,
  <<"link">>  => undefined
  }).


-type err_answer() :: {err, {ErrCone::atom(), ErrDesc::binary()}}. 

