
-define(CB, #{ %% Comment Block definition
  <<"ckey">>       => undefined,  % Unique id for key in DB
  <<"root">>       => undefined,  % Link to comment part with root comment (for jump to begin of thread)
  <<"last_child">> => undefined,  % Link to cooment part wish last comment (for jump to the end of tread)
  <<"comments">>   => [],         % Comments list
  <<"c_time">>     => os:system_time(seconds),       % Create time 
  <<"m_time">>     => os:system_time(seconds),       % Modify time
  <<"stat">>       => #{},        % stat of comments
  <<"cats">>       => []          % log of last cats, for searching comment
  }).


-define(C, #{ %% Comment definition
  <<"key">>     => undefined,
  <<"c_time">>  => os:system_time(seconds),       % Create time 
  <<"m_time">>  => os:system_time(seconds),       % Modify time
  <<"level">>   => 0,
  <<"type">>    => comment,
  <<"link">>    => undefined,
  <<"text">>    => undefined,
  <<"owner">>   => #{<<"nid">> => undefined, <<"nw">> => undefined},
  <<"like">>    => 0,
  <<"claim">>   => 0
  }).


-define(L, #{ %% Link definition
  <<"level">> => 0,
  <<"type">>  => link,
  <<"link">>  => undefined
  }).


-type err_answer() :: {err, {ErrCone::atom(), ErrDesc::binary()}}. 

