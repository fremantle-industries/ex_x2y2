defmodule ExX2Y2.Events.IndexTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Mock
  alias ExX2Y2.Events.Index
  doctest ExX2Y2.Events.Index

  @api_key System.get_env("X2Y2_API_KEY")
  @default_type "list"

  defmodule ErrorAdapter do
    def send(_request) do
      {:error, :from_adapter}
    end
  end

  setup_all do
    HTTPoison.start()
    :ok
  end

  test ".get/1 returns an event page cursor" do
    use_cassette "events/index/get_ok" do
      assert {:ok, cursor} = Index.get(@api_key, %{type: @default_type})
      assert %ExX2Y2.PageCursor{} = cursor
      assert length(cursor.data) > 1
    end
  end

  test ".get/1 can limit the number of results returned" do
    use_cassette "events/index/get_filter_limit_ok" do
      assert {:ok, cursor} = Index.get(@api_key, %{limit: 1, type: @default_type})
      assert length(cursor.data) == 1
    end
  end

  test ".get/1 can filter by from_address" do
    from_address = "0x85472981e13c7cd11df52f21e69493353e1c6d87"

    use_cassette "events/index/get_filter_by_from_address_ok" do
      assert {:ok, cursor} = Index.get(@api_key, %{from_address: from_address, type: @default_type})

      assert length(cursor.data) > 1
      assert Enum.all?(cursor.data, &(&1["from_address"] == from_address)) == true
    end
  end

  test ".get/1 can filter by to_address" do
    to_address = "0x3263abb600ef98c4268a0dd60021ca4f2edf7b33"

    use_cassette "events/index/get_filter_by_to_address_ok" do
      assert {:ok, cursor} = Index.get(@api_key, %{to_address: to_address})

      assert length(cursor.data) > 1
      assert Enum.all?(cursor.data, &(&1["to_address"] == to_address)) == true
    end
  end

  test ".get/1 can filter by contract" do
    contract_address = "0xbce3781ae7ca1a5e050bd9c4c77369867ebc307e"

    use_cassette "events/index/get_filter_by_contract_address_ok" do
      assert {:ok, cursor} = Index.get(@api_key, %{contract: contract_address, type: @default_type})

      assert length(cursor.data) > 1
      assert Enum.all?(cursor.data, &(&1["token"]["contract"] == contract_address)) == true
    end
  end

  test ".get/1 can filter by type" do
    type = "sale"

    use_cassette "events/index/get_filter_by_type_ok" do
      assert {:ok, cursor} = Index.get(@api_key, %{type: type})

      assert length(cursor.data) > 1
      assert Enum.all?(cursor.data, &(&1["type"] == type)) == true
    end
  end

  test ".get/1 can filter by the token id of a contract" do
    contract_address = "0xbce3781ae7ca1a5e050bd9c4c77369867ebc307e"
    token_id = 2260

    use_cassette "events/index/get_filter_by_token_id_ok" do
      params = %{contract: contract_address, token_id: token_id, type: @default_type}
      assert {:ok, cursor} = Index.get(@api_key, params)

      assert length(cursor.data) > 1
      assert Enum.all?(cursor.data, &(&1["token"]["contract"] == contract_address)) == true
      assert Enum.all?(cursor.data, &(&1["token"]["token_id"] == "#{token_id}")) == true
    end
  end

  test ".get/1 can filter by created_before" do
    created_before = 1_655_142_926

    use_cassette "events/index/get_filter_by_created_before_ok" do
      assert {:ok, cursor} = Index.get(@api_key, %{created_before: created_before, type: @default_type})

      assert length(cursor.data) > 1
      assert Enum.all?(cursor.data, &(&1["created_at"] < created_before)) == true
    end
  end

  test ".get/1 can filter by created_after" do
    created_after = 1_655_142_926

    use_cassette "events/index/get_filter_by_created_after_ok" do
      assert {:ok, cursor} = Index.get(@api_key, %{created_after: created_after, type: @default_type})

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
