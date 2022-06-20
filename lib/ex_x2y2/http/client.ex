defmodule ExX2Y2.Http.Client do
  alias ExX2Y2.Http

  @type request :: Http.Request.t()
  @type data :: map | list
  @type error_reason :: Jason.DecodeError.t() | Http.Adapter.error_reason()
  @type result :: {:ok, data} | {:error, error_reason}

  @spec rest_domain :: String.t()
  def rest_domain, do: Application.get_env(:ex_magic_eden, :rest_domain, "api.x2y2.org")

  @spec protocol :: String.t()
  def protocol, do: Application.get_env(:ex_magic_eden, :protocol, "https")

  @spec adapter :: module
  def adapter, do: Application.get_env(:ex_magic_eden, :adapter, Http.HTTPoisonAdapter)

  @spec get(request) :: result
  def get(request) do
    request
    |> Http.Request.with_method(:get)
    |> send_rest()
  end

  @spec send_rest(request) :: result
  def send_rest(request) do
    http_adapter = adapter()

    request
    |> Http.Request.with_protocol(protocol())
    |> Http.Request.with_domain(rest_domain())
    |> http_adapter.send()
    |> parse_response()
  end

  defp parse_response({:ok, %Http.Response{status_code: status_code, body: body}}) do
    cond do
      status_code >= 200 && status_code < 300 ->
        Jason.decode(body)

      status_code >= 400 && status_code < 500 ->
        case Jason.decode(body) do
          {:ok, json} -> {:error, json}
          {:error, _} = result -> result
        end

      true ->
        {:error, body}
    end
  end

  defp parse_response({:error, _reason} = error) do
    error
  end
end
