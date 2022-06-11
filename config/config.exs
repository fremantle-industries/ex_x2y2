import Config

config :ex_x2y2, api_key: System.get_env("X2Y2_API_KEY")

config :exvcr,
  filter_request_headers: [
    "X-API-KEY"
  ],
  response_headers_blacklist: [
    "Set-Cookie",
    "account-id",
    "ETag",
    "cf-request-id",
    "CF-RAY",
    "X-Trace-Id"
  ]
