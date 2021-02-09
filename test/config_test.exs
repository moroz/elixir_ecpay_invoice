defmodule ECPayInvoice.ConfigTest do
  @moduledoc false

  use ExUnit.Case

  alias ECPayInvoice.Config

  @required_keys ~w(merchant_id hash_iv hash_key development)a

  def is_config(map) when is_map(map) do
    for key <- @required_keys do
      assert Map.get(map, key)
    end
  end

  describe "get_all_config/0" do
    test "lists all profiles with their configurations" do
      actual = Config.get_all_config()

      assert is_map(actual)

      for {key, profile} <- actual do
        assert is_atom(key)
        assert is_config(profile)
      end
    end
  end

  describe "get_config/1" do
    test "returns profile configuration if exists with atom keys" do
      all_config = Config.get_all_config()
      profile_name = Map.keys(all_config) |> List.first()
      assert is_atom(profile_name)
      actual = Config.get_config(profile_name)
      assert is_config(actual)
    end

    test "returns profile configuration if exists for string keys" do
      all_config = Config.get_all_config()
      profile_name = Map.keys(all_config) |> List.first() |> to_string()
      actual = Config.get_config(profile_name)
      assert is_config(actual)
    end
  end
end
