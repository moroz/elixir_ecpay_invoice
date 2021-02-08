defmodule ECPayInvoice.Config do
  @moduledoc """
  Convenience functions for working with ECPay credentials and configuration.
  """

  def get_config(profile_name \\ nil)

  def get_config(nil), do: Application.get_env(:ecpay_invoice, :profiles)

  def get_config(profile_name), do: get_config(nil) |> Map.get(to_string(profile_name))

  def get_hash_iv(profile_name \\ :staging), do: Map.get(get_config(profile_name), :hash_iv)
  def get_hash_key(profile_name \\ :staging), do: Map.get(get_config(profile_name), :hash_key)
  def development?(profile_name \\ :staging), do: Map.get(get_config(profile_name), :development)

  def get_merchant_id(profile_name \\ :staging),
    do: Map.get(get_config(profile_name), :merchant_id)

  def get_endpoint(path \\ "") do
    if development?() do
      "https://einvoice-stage.ecpay.com.tw" <> path
    else
      "https://einvoice.ecpay.com.tw" <> path
    end
  end
end
