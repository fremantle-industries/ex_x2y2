defmodule ExX2Y2.Orders.IndexTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Mock
  alias ExX2Y2.Orders.Index
  doctest ExX2Y2.Orders.Index

  @api_key System.get_env("X2Y2_API_KEY")

  defmodule ErrorAdapter do
    def send(_request) do
      {:error, :from_adapter}
    end
  end

  setup_all do
    HTTPoison.start()
    :ok
  end

  test ".get/1 returns an order page cursor" do
    use_cassette "orders/index/get_ok" do
      assert {:ok, cursor} = Index.get(@api_key)
      assert %ExX2Y2.PageCursor{} = cursor
      assert length(cursor.data) > 1
    end
  end

  test ".get/1 can limit the number of results returned" do
    use_cassette "orders/index/get_filter_limit_ok" do
      assert {:ok, cursor} = Index.get(@api_key, %{limit: 1})
      assert length(cursor.data) == 1
    end
  end

  test ".get/1 sort by property" do
    use_cassette "orders/index/get_filter_sort_property_ok" do
      assert {:ok, cursor} = Index.get(@api_key, %{sort: "price"})
      assert length(cursor.data) > 1
      data_0 = Enum.at(cursor.data, 0)
      data_1 = Enum.at(cursor.data, 1)
      assert data_0["price"] <= data_1["price"]
    end
  end

  test ".get/1 can set the direction of sort order" do
    use_cassette "orders/index/get_filter_sort_direction_ok", match_requests_on: [:query] do
      assert {:ok, asc_cursor} = Index.get(@api_key, %{limit: 2, direction: "asc"})
      assert length(asc_cursor.data) == 2
      asc_data_0 = Enum.at(asc_cursor.data, 0)
      asc_data_1 = Enum.at(asc_cursor.data, 1)
      assert asc_data_0["created_at"] < asc_data_1["created_at"]

      assert {:ok, desc_cursor} = Index.get(@api_key, %{limit: 2, direction: "desc"})
      assert length(desc_cursor.data) == 2
      desc_data_0 = Enum.at(desc_cursor.data, 0)
      desc_data_1 = Enum.at(desc_cursor.data, 1)
      assert desc_data_0["created_at"] > desc_data_1["created_at"]
    end
  end

  test ".get/1 can filter by cursor page" do
    use_cassette "orders/index/get_filter_cursor_ok", match_requests_on: [:query] do
      assert {:ok, cursor_page_0} = Index.get(@api_key, %{limit: 1})
      assert length(cursor_page_0.data) == 1

      assert {:ok, cursor_page_1} = Index.get(@api_key, %{limit: 1, cursor: cursor_page_0.next})
      assert length(cursor_page_1.data) == 1
      assert cursor_page_0.data != cursor_page_1.data
    end
  end

  test ".get/1 can filter by maker wallet address" do
    maker_wallet_address = "0x62682982afb10010629d15f2f27d752d07673fbb"

    use_cassette "orders/index/get_filter_maker_ok" do
      assert {:ok, cursor} = Index.get(@api_key, %{maker: maker_wallet_address})
      assert length(cursor.data) > 1
      assert Enum.all?(cursor.data, &(&1["maker"] == maker_wallet_address)) == true
    end
  end

  test ".get/1 can filter by contract address" do
    contract_address = "0xbce3781ae7ca1a5e050bd9c4c77369867ebc307e"

    use_cassette "orders/index/get_filter_contract_ok" do
      assert {:ok, cursor} = Index.get(@api_key, %{contract: contract_address})
      assert length(cursor.data) > 1
      assert Enum.all?(cursor.data, &(&1["token"]["contract"] == contract_address)) == true
    end
  end

  @tag :skip
  test ".get/1 can filter by token id" do
    contract_address = "0xbce3781ae7ca1a5e050bd9c4c77369867ebc307e"
    token_id = 8041

    use_cassette "orders/index/get_filter_token_id_ok" do
      assert {:ok, cursor} =
               Index.get(@api_key, %{contract: contract_address, token_id: token_id})

      assert length(cursor.data) > 1
      assert Enum.all?(cursor.data, &(&1["token"]["token_id"] == token_id)) == true
    end
  end

  test ".get/1 can filter by created before" do
    created_before = 1_655_142_926

    use_cassette "orders/index/get_filter_created_before_ok" do
      assert {:ok, cursor} = Index.get(@api_key, %{created_before: created_before})

      assert length(cursor.data) > 1
      assert Enum.all?(cursor.data, &(&1["created_at"] < created_before)) == true
    end
  end

  test ".get/1 can filter by created_after" do
    created_after = 1_655_142_926

    use_cassette "orders/index/get_filter_created_after_ok" do
      assert {:ok, cursor} = Index.get(@api_key, %{created_after: created_after})

      assert length(cursor.data) > 1
      assert Enum.all?(cursor.data, &(&1["created_at"] > created_after)) == true
    end
  end

  test ".get/1 bubbles error tuples" do
    with_mock HTTPoison, request: fn _url -> {:error, %HTTPoison.Error{reason: :timeout}} end do
      assert Index.get(@api_key) == {:error, :timeout}
    end
  end
end
