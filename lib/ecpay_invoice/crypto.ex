defmodule ECPayInvoice.Crypto do
  alias ECPayInvoice.Config

  @cipher :aes_128_cbc

  def uri_escape(string) do
    string
    |> URI.encode_www_form()
    |> String.replace("%21", "!")
    |> String.replace("%2A", "*")
    |> String.replace("%28", "(")
    |> String.replace("%29", ")")
  end

  def encrypt_payload(data, key \\ Config.get_hash_key(), iv \\ Config.get_hash_iv())

  def encrypt_payload(data, key, iv) when is_map(data) do
    Jason.encode!(data)
    |> encrypt_payload(key, iv)
  end

  def encrypt_payload(data, key, iv) when is_binary(data) do
    data
    |> uri_escape()
    |> encrypt(key, iv)
    |> Base.encode64()
  end

  def encrypt(data, key \\ Config.get_hash_key(), iv \\ Config.get_hash_iv()) do
    :crypto.crypto_one_time(@cipher, key, iv, data, encrypt: true, padding: :pkcs_padding)
  end

  def decrypt(data, key \\ Config.get_hash_key(), iv \\ Config.get_hash_iv())
      when is_binary(data) do
    bytes =
      :crypto.crypto_one_time(@cipher, key, iv, data, encrypt: false, padding: :pkcs_padding)

    URI.decode(bytes)
  end

  def decrypt_base64(data, key \\ Config.get_hash_key(), iv \\ Config.get_hash_iv())
      when is_binary(data) do
    decoded = Base.decode64!(data)
    decrypt(decoded, key, iv)
  end
end
