-module(erlang_ls_completion_provider).

-behaviour(erlang_ls_provider).

-include("erlang_ls.hrl").

-export([ handle_request/2
        , is_enabled/0
        ]).

%% Exported to ease testing.
-export([ keywords/0 ]).

%%==============================================================================
%% erlang_ls_provider functions
%%==============================================================================

-spec is_enabled() -> boolean().
is_enabled() ->
  true.

-spec handle_request(any(), erlang_ls_provider:state()) ->
  {any(), erlang_ls_provider:state()}.
handle_request({completion, Params}, State) ->
  #{ <<"position">>     := #{ <<"line">>      := Line
                            , <<"character">> := Character
                            }
   , <<"textDocument">> := #{<<"uri">> := Uri}
   } = Params,
  {ok, Document} = erlang_ls_utils:find_document(Uri),
  Text = erlang_ls_document:text(Document),
  case maps:find(<<"context">>, Params) of
    {ok, Context} ->
      TriggerKind = maps:get(<<"triggerKind">>, Context),
      TriggerCharacter = maps:get(<<"triggerCharacter">>, Context, <<>>),
      %% We subtract 1 to strip the character that triggered the
      %% completion from the string.
      Length = case Character > 0 of true -> 1; false -> 0 end,
      Prefix = case TriggerKind of
                 ?COMPLETION_TRIGGER_KIND_CHARACTER ->
                   erlang_ls_text:line(Text, Line, Character - Length);
                 ?COMPLETION_TRIGGER_KIND_INVOKED ->
                   erlang_ls_text:line(Text, Line, Character)
               end,
      Opts   = #{ trigger  => TriggerCharacter
                , document => Document
                },
      {find_completion(Prefix, TriggerKind, Opts), State};
    error ->
      {null, State}
  end.

%%==============================================================================
%% Internal functions
%%==============================================================================

-spec find_completion(binary(), integer(), map()) -> any().
find_completion( Prefix
               , ?COMPLETION_TRIGGER_KIND_CHARACTER
               , #{trigger := <<":">>}
               ) ->
  case erlang_ls_text:last_token(Prefix) of
    {atom, _, Module} -> exported_functions(Module, false);
    _ -> null
  end;
find_completion( _Prefix
               , ?COMPLETION_TRIGGER_KIND_CHARACTER
               , #{trigger := <<"?">>, document := Document}
               ) ->
  macros(Document);
find_completion( Prefix
               , ?COMPLETION_TRIGGER_KIND_INVOKED
               , #{document := Document}
               ) ->
  case lists:reverse(erlang_ls_text:tokens(Prefix)) of
    %% Check for "[...] fun atom:atom"
    [{atom, _, _}, {':', _}, {atom, _, Module}, {'fun', _} | _] ->
      exported_functions(Module, true);
    %% Check for "[...] atom:atom"
    [{atom, _, _}, {':', _}, {atom, _, Module} | _] ->
      exported_functions(Module, false);
    %% Check for "[...] ?anything"
    [_, {'?', _} | _] ->
      macros(Document);
    %% Check for "[...] Variable"
    [{var, _, _} | _] ->
      variables(Document);
    %% Check for "[...] fun atom"
    [{atom, _, _}, {'fun', _} | _] ->
      functions(Document, false, true);
    %% Check for "[...] atom"
    [{atom, _, Name} | _] ->
      NameBinary = atom_to_binary(Name, utf8),
      keywords() ++ modules(NameBinary) ++ functions(Document, false, false);
    _ ->
      []
  end;
find_completion(_Prefix, _TriggerKind, _Opts) ->
  null.

%%==============================================================================
%% Modules
%%==============================================================================

-spec modules(binary()) -> [map()].
modules(Prefix) ->
  Modules = erlang_ls_db:keys(modules),
  filter_by_prefix(Prefix, Modules, fun to_binary/1, fun item_kind_module/1).

-spec item_kind_module(binary()) -> map().
item_kind_module(Module) ->
  #{ label            => Module
   , kind             => ?COMPLETION_ITEM_KIND_MODULE
   , insertTextFormat => ?INSERT_TEXT_FORMAT_PLAIN_TEXT
   }.

%%==============================================================================
%% Functions
%%==============================================================================

-spec functions(erlang_ls_document:document(), boolean(), boolean()) -> [map()].
functions(Document, _OnlyExported = false, Arity) ->
  POIs = erlang_ls_document:points_of_interest(Document, [function]),
  List = [completion_item_function(POI, Arity) || POI <- POIs],
  lists:usort(List);
functions(Document, _OnlyExported = true, Arity) ->
  Exports   = erlang_ls_document:points_of_interest(Document, [exports_entry]),
  Functions = erlang_ls_document:points_of_interest(Document, [function]),
  ExportsFA = [FA || #{data := FA} <- Exports],
  List      = [ completion_item_function(POI, Arity)
                || #{data := FA} = POI <- Functions, lists:member(FA, ExportsFA)
              ],
  lists:usort(List).

-spec completion_item_function(poi(), boolean()) -> map().
completion_item_function(#{data := {F, A}, tree := Tree}, false) ->
  #{ label            => list_to_binary(io_lib:format("~p/~p", [F, A]))
   , kind             => ?COMPLETION_ITEM_KIND_FUNCTION
   , insertText       => snippet_function_call(F, function_args(Tree, A))
   , insertTextFormat => ?INSERT_TEXT_FORMAT_SNIPPET
   };
completion_item_function(#{data := {F, A}}, true) ->
  #{ label            => list_to_binary(io_lib:format("~p/~p", [F, A]))
   , kind             => ?COMPLETION_ITEM_KIND_FUNCTION
   , insertTextFormat => ?INSERT_TEXT_FORMAT_PLAIN_TEXT
   }.

-spec exported_functions(module(), boolean()) -> [map()] | null.
exported_functions(Module, Arity) ->
  case erlang_ls_utils:find_module(Module) of
    {ok, Uri} ->
      {ok, Document} = erlang_ls_utils:find_document(Uri),
      functions(Document, true, Arity);
    {error, _Error} ->
      null
  end.

-spec function_args(tree(), arity()) -> [{integer(), string()}].
function_args(Tree, Arity) ->
  Clause   = hd(erl_syntax:function_clauses(Tree)),
  Patterns = erl_syntax:clause_patterns(Clause),
  [ case erl_syntax:type(P) of
      variable -> {N, erl_syntax:variable_literal(P)};
      _        -> {N, "Arg" ++ integer_to_list(N)}
    end
    || {N, P} <- lists:zip(lists:seq(1, Arity), Patterns)
  ].

-spec snippet_function_call(atom(), [{integer(), string()}]) -> binary().
snippet_function_call(Function, Args0) ->
  Args    = [ ["${", integer_to_list(N), ":", A, "}"]
              || {N, A} <- Args0
            ],
  Snippet = [atom_to_list(Function), "(", string:join(Args, ", "), ")"],
  iolist_to_binary(Snippet).

%%==============================================================================
%% Variables
%%==============================================================================

-spec variables(erlang_ls_document:document()) -> [map()].
variables(Document) ->
  POIs = erlang_ls_document:points_of_interest(Document, [variable]),
  Vars = [ #{ label => atom_to_binary(Name, utf8)
            , kind  => ?COMPLETION_ITEM_KIND_VARIABLE
            }
           || #{data := Name} <- POIs
         ],
  lists:usort(Vars).

%%==============================================================================
%% Macros
%%==============================================================================

-spec macros(erlang_ls_document:document()) -> [map()].
macros(Document) ->
  Macros = lists:flatten([local_macros(Document), included_macros(Document)]),
  lists:usort(Macros).

-spec local_macros(erlang_ls_document:document()) -> [map()].
local_macros(Document) ->
  POIs   = erlang_ls_document:points_of_interest(Document, [define]),
   [ #{ label => atom_to_binary(Name, utf8)
      , kind  => ?COMPLETION_ITEM_KIND_CONSTANT
      }
     || #{data := Name} <- POIs
   ].

-spec included_macros(erlang_ls_document:document()) -> [[map()]].
included_macros(Document) ->
  Kinds = [include, include_lib],
  POIs  = erlang_ls_document:points_of_interest(Document, Kinds),
  [include_file_macros(Kind, Name) || #{kind := Kind, data := Name} <- POIs].

-spec include_file_macros('include' | 'include_lib', string()) -> [map()].
include_file_macros(Kind, Name) ->
  Filename = erlang_ls_utils:include_filename(Kind, Name),
  M = list_to_atom(Filename),
  case erlang_ls_utils:find_module(M) of
    {ok, Uri} ->
      {ok, IncludeDocument} = erlang_ls_utils:find_document(Uri),
      local_macros(IncludeDocument);
    {error, _} ->
      []
  end.

%%==============================================================================
%% Keywords
%%==============================================================================

-spec keywords() -> [map()].
keywords() ->
  Keywords = [ 'after', 'and', 'andalso', 'band', 'begin', 'bnot', 'bor', 'bsl'
             , 'bsr', 'bxor', 'case', 'catch', 'cond', 'div', 'end', 'fun'
             , 'if', 'let', 'not', 'of', 'or', 'orelse', 'receive', 'rem'
             , 'try', 'when', 'xor'],
  [ #{ label => atom_to_binary(K, utf8)
     , kind  => ?COMPLETION_ITEM_KIND_KEYWORD
     } || K <- Keywords ].

%%==============================================================================
%% Filter by prefix
%%==============================================================================

-spec filter_by_prefix(binary(), [binary()], function(), function()) -> [map()].
filter_by_prefix(Prefix, List, ToBinary, ItemFun) ->
  FilterMapFun = fun(X) ->
                     Str = ToBinary(X),
                     case string:prefix(Str, Prefix)  of
                       nomatch -> false;
                       _       -> {true, ItemFun(Str)}
                     end
                 end,
  lists:filtermap(FilterMapFun, List).

-spec to_binary(any()) -> binary().
to_binary(X) when is_atom(X) ->
  atom_to_binary(X, utf8);
to_binary(X) when is_binary(X) ->
  X.