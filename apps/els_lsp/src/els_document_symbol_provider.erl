-module(els_document_symbol_provider).

-behaviour(els_provider).

-export([
    handle_request/1
]).

-include("els_lsp.hrl").

%%==============================================================================
%% els_provider functions
%%==============================================================================
-spec handle_request(any()) -> {response, any()}.
handle_request({document_symbol, Params}) ->
    #{<<"textDocument">> := #{<<"uri">> := Uri}} = Params,
    Symbols = symbols(Uri),
    case Symbols of
        [] -> {response, null};
        _ -> {response, lists:reverse(Symbols)}
    end.

%%==============================================================================
%% Internal Functions
%%==============================================================================
-spec symbols(uri()) -> [map()].
symbols(Uri) ->
    {ok, Document} = els_utils:lookup_document(Uri),
    POIs = els_dt_document:pois(Document, [
        function,
        define,
        record,
        type_definition
    ]),
    lists:reverse([els_poi:to_symbol(Uri, POI) || POI <- POIs]).
