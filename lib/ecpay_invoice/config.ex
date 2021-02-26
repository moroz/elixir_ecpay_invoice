defmodule ECPayInvoice.Config do
  @moduledoc """
  Convenience functions for working with ECPay credentials and configuration.
  """

  def default_profile, do: Application.get_env(:ecpay_invoice, :default_profile)

  def get_all_config, do: Application.get_env(:ecpay_invoice, :profiles)

  def get_config(profile_name \\ default_profile())

  def get_config(nil), do: get_config(default_profile())

  def get_config(profile_name) when is_binary(profile_name) do
    get_config(String.to_atom(profile_name))
  end

  def get_config(profile_name) when is_atom(profile_name) do
    all = get_all_config()

    case Map.fetch(all, profile_name) do
      {:ok, value} ->
        value

      _ ->
        all_keys = Map.keys(all) |> Enum.join(", ")

        raise ArgumentError,
              "No invoice configuration found for profile #{profile_name}. Available configuration profiles: #{
                all_keys
              }."
    end
  end

  def get_hash_iv(profile_name), do: Map.get(get_config(profile_name) || %{}, :hash_iv)
  def get_hash_key(profile_name), do: Map.get(get_config(profile_name) || %{}, :hash_key)
  def development?(profile_name), do: Map.get(get_config(profile_name) || %{}, :development)

  def get_key_and_iv(profile) do
    {get_hash_key(profile), get_hash_iv(profile)}
  end

  def get_merchant_id(profile_name), do: Map.get(get_config(profile_name) || %{}, :merchant_id)

  def get_endpoint(path, profile) do
    if development?(profile) do
      "https://einvoice-stage.ecpay.com.tw" <> path
    else
      "https://einvoice.ecpay.com.tw" <> path
    end
  end
end
