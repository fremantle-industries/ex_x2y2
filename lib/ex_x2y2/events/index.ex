defmodule ExX2Y2.Events.Index do
  alias ExX2Y2.Http

  @type api_key :: Http.Request.api_key()
  @type address :: String.t()
  @type unix_timestamp :: non_neg_integer
  @type params :: %{
          optional(:limit) => non_neg_integer,
          optional(:from_address) => address,
          optional(:to_address) => address,
          optional(:contract) => address,
          optional(:token_id) => non_neg_integer(),
          optional(:type) => String.t(),
          optional(:created_before) => unix_timestamp,
          optional(:created_after) => unix_timestamp
        }
  @type event_page_cursor :: ExX2Y2.EventPageCursor.t()
  @type error_reason :: :parse_result_item | String.t()
  @type result :: {:ok, event_page_cursor} | {:error, error_reason}

  @spec get(api_key) :: result
  @spec get(api_key, params) :: result
  def get(api_key, params \\ %{}) do
    "/v1/events"
    |> Http.Request.for_path()
    |> Http.Request.with_query(params)
    |> Http.Request.with_auth(api_key)
    |> Http.Client.get()
    |> parse_response()
  end

  defp parse_response({:ok, data}) do
    Mapail.map_to_struct(data, ExX2Y2.EventPageCursor)
  end

  defp parse_response({:error, _reason} = error) do
    error
  end
end
