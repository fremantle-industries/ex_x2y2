defmodule ExX2Y2.Http.Request do
  @type protocol :: String.t()
  @type domain :: String.t()
  @type path :: String.t()
  @type http_method :: :get | :post | :put | :delete
  @type api_key :: String.t()
  @type params :: map

  @type t :: %__MODULE__{
    protocol: protocol | nil,
    domain: domain | nil,
    path: path,
    query: String.t() | nil,
    body: String.t() | nil,
    headers: keyword,
    method: http_method | nil
  }

  defstruct ~w[protocol domain path query body headers method]a

  @spec for_path(path) :: t
  def for_path(path) do
    %__MODULE__{path: path, headers: []}
  end

  @spec with_query(t, params) :: t
  def with_query(request, params) do
    query = URI.encode_query(params, :www_form)
    %{request | query: query}
  end

  @spec with_protocol(t, protocol) :: t
  def with_protocol(request, protocol) do
    %{request | protocol: protocol}
  end

  @spec with_domain(t, domain) :: t
  def with_domain(request, domain) do
    %{request | domain: domain}
  end

  @spec with_method(t, http_method) :: t
  def with_method(request, method) do
    %{request | method: method}
  end

  @spec with_auth(t, api_key) :: t
  def with_auth(request, api_key) do
    headers = Keyword.put(request.headers, :"X-API-KEY", api_key)
    %{request | headers: headers}
  end

  @spec url(t) :: String.t()
  def url(request) do
    %URI{
      scheme: request.protocol,
      host: request.domain,
      path: request.path,
      query: request.query
    }
    |> URI.to_string()
    |> String.trim("?")
  end
end
