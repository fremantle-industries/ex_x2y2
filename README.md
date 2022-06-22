# ExX2Y2
[![Build Status](https://github.com/fremantle-industries/ex_x2y2/workflows/test/badge.svg?branch=main)](https://github.com/fremantle-industries/ex_x2y2/actions?query=workflow%3Atest)
[![hex.pm version](https://img.shields.io/hexpm/v/ex_x2y2.svg?style=flat)](https://hex.pm/packages/ex_x2y2)

X2Y2 API client for Elixir

## Installation

Add the `ex_x2y2` package to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_x2y2, "~> 0.0.2"}
  ]
end
```

## Requirements

- Erlang 22+
- Elixir 1.13+

## REST API

https://x2y2-io.github.io/api-reference

#### Orders

- [x] `GET /v1/orders`

#### Events

- [x] `GET /v1/events`

## Legacy REST API

https://docs.x2y2.io/developers/api

#### Orders

- [ ] `GET /api/orders`
- [ ] `POST /api/orders/sign`
- [ ] `POST /api/orders/cancel`
- [ ] `POST /api/orders/add`

#### Contracts

- [ ] `POST /api/contracts/payment_info`

## Authors

- Alex Kwiatkowski - alex+git@fremantle.io

## License

`ex_x2y2` is released under the [MIT license](./LICENSE)
