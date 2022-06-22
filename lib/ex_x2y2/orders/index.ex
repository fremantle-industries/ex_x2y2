defmodule ExX2Y2.Orders.Index do
  alias ExX2Y2.Http
  alias ExX2Y2.PageCursor

  @type api_key :: Http.Request.api_key()
  @type address :: String.t()
  @type unix_timestamp :: non_neg_integer
  @type params :: %{
          optional(:limit) => non_neg_integer,
          optional(:direction) => String.t(),
          optional(:maker) => address,
          optional(:cursor) => address,
          optional(:contract) => address,
          optional(:token_id) => non_neg_integer(),
          optional(:created_before) => unix_timestamp,
          optional(:created_after) => unix_timestamp,
          optional(:sort) => String.t()
        }
  @type error_reason :: :parse_result_item | String.t()
  @type result :: {:ok, PageCursor.t()} | {:error, error_reason}

  @spec get(api_key) :: result
  @spec get(api_key, params) :: result
  def get(api_key, params \\ %{}) do
    "/v1/orders"
    |> Http.Request.for_path()
    |> Http.Request.with_query(params)
    |> Http.Request.with_auth(api_key)
    |> Http.Client.get()
    |> parse_response()
  end

  defp parse_response({:ok, data}) do
    Mapail.map_to_struct(data, PageCursor)
  end

  defp parse_response({:error, _reason} = error) do
    error
  end
end
