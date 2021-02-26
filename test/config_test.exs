defmodule ECPayInvoice.ConfigTest do
  @moduledoc false

  @otp_app :ecpay_invoice

  use ExUnit.Case

  alias ECPayInvoice.Config

  defmacro with_config(config, do: block) do
    quote do
      existing_config = Application.get_all_env(@otp_app)

      for {key, value} <- unquote(config) do
        Application.put_env(@otp_app, key, value)
      end

      unquote(block)

      for {key, value} <- existing_config do
        Application.put_env(@otp_app, key, value)
      end
    end
  end

  defmacro with_config(key, config, do: block) do
    quote do
      existing_config = Application.get_env(@otp_app, unquote(key))
      Application.put_env(@otp_app, unquote(key), unquote(config))
      unquote(block)
      Application.put_env(@otp_app, unquote(key), existing_config)
    end
  end

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

    test "raises ArgumentError for non-existent profiles with atom keys" do
      key = :non_existent

      assert_raise ArgumentError, fn ->
        Config.get_config(key)
      end
    end

    test "raises ArgumentError for non-existent profiles with string keys" do
      key = "non_existent"

      assert_raise ArgumentError, fn ->
        Config.get_config(key)
      end
    end

    test "returns a profile configuration when called with no arguments" do
      actual = Config.get_config()
      assert is_config(actual)
    end
  end

  describe "default_profile/0" do
    test "returns the name of the default profile as atom" do
      with_config(:default_profile, :some_value) do
        actual = Config.default_profile()
        assert actual == :some_value
      end
    end
  end

  @sample_config [
    profiles: %{
      production: %{
        development: false,
        hash_iv: "4e160477e497e745",
        hash_key: "550dd051e74ebe69",
        merchant_id: "1234567"
      },
      development: %{
        merchant_id: "2000132",
        hash_key: "ejCk326UnaZWKisg",
        hash_iv: "q9jcZX8Ib9LM8wYk",
        development: true
      }
    },
    default_profile: :production
  ]

  @configuration_keys ~w(merchant_id hash_key hash_iv)a

  for key <- @configuration_keys do
    function_name = :"get_#{key}"

    describe "#{function_name}/1" do
      test "returns #{key} from default profile when called with nil" do
        with_config(@sample_config) do
          actual = apply(Config, unquote(function_name), [nil])
          expected = @sample_config[:profiles] |> Map.get(:production) |> Map.get(unquote(key))
          assert actual == expected
        end
      end

      test "returns #{key} from the named profile when called with atom key" do
        with_config(@sample_config) do
          actual = apply(Config, unquote(function_name), [:development])
          expected = @sample_config[:profiles] |> Map.get(:development) |> Map.get(unquote(key))
          assert actual == expected
        end
      end

      test "returns merchant_id from the named profile when called with string key" do
        with_config(@sample_config) do
          actual = apply(Config, unquote(function_name), ["development"])
          expected = @sample_config[:profiles] |> Map.get(:development) |> Map.get(unquote(key))
          assert actual == expected
        end
      end

      test "returns nil when called with a non-existent profile name as atom" do
        with_config(@sample_config) do
          assert_raise ArgumentError, fn ->
            apply(Config, unquote(function_name), [:non_existent])
          end
        end
      end

      test "returns nil when called with a non-existent profile name as string" do
        with_config(@sample_config) do
          assert_raise ArgumentError, fn ->
            apply(Config, unquote(function_name), ["non_existent"])
          end
        end
      end
    end
  end

  describe "development?/1" do
    test "returns the set value for the default profile when called with nil" do
      with_config(@sample_config) do
        actual = Config.development?(nil)
        refute actual
      end
    end

    test "returns the set value for a named profile when called with name as atom" do
      with_config(@sample_config) do
        actual = Config.development?(:production)
        refute actual
      end
    end

    test "returns the set value for a named profile when called with name as string" do
      with_config(@sample_config) do
        actual = Config.development?("production")
        refute actual
      end
    end

    test "raises ArgumentError for a non-existent profile called with string" do
      with_config(@sample_config) do
        assert_raise ArgumentError, fn ->
          Config.development?("non_existent")
        end
      end
    end

    test "raises ArgumentError for a non-existent profile called with atom" do
      with_config(@sample_config) do
        assert_raise ArgumentError, fn ->
          Config.development?(:non_existent)
        end
      end
    end
  end
end
