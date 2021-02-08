defmodule ECPayInvoice.Config do
  @moduledoc """
  Convenience functions for working with ECPay credentials and configuration.
  """

  @staging_gateway_params %{
    merchant_id: "2000132",
    hash_key: "ejCk326UnaZWKisg",
    hash_iv: "q9jcZX8Ib9LM8wYk",
    development: true
  }

  def get_hash_iv, do: Map.get(@staging_gateway_params, :hash_iv)
  def get_hash_key, do: Map.get(@staging_gateway_params, :hash_key)
  def development?, do: Map.get(@staging_gateway_params, :development)
  def get_merchant_id, do: Map.get(@staging_gateway_params, :merchant_id)

  def get_endpoint(path \\ "") do
    if development?() do
      "https://einvoice-stage.ecpay.com.tw" <> path
    else
      "https://einvoice.ecpay.com.tw" <> path
    end
  end
end
