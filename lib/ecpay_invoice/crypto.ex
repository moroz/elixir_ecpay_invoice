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
    |> String.replace("%40", "%2540")
    |> String.replace("%257C", "%7C")
  end

  def encrypt_payload(data, key \\ Config.get_hash_iv(), iv \\ Config.get_hash_iv())

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

  def encrypt(data, key \\ Config.get_hash_iv(), iv \\ Config.get_hash_iv()) do
    padded = PKCS7.pad(data)
    :crypto.crypto_one_time(@cipher, key, iv, padded, true)
  end

  def decrypt(data, key \\ Config.get_hash_iv(), iv \\ Config.get_hash_iv())
      when is_binary(data) do
    decrypted = :crypto.crypto_one_time(@cipher, key, iv, data, false)
    encoded = PKCS7.unpad(decrypted)
    URI.decode(encoded)
  end

  def decrypt_base64(data, key \\ Config.get_hash_iv(), iv \\ Config.get_hash_iv())
      when is_binary(data) do
    decoded = Base.decode64!(data)
    decrypt(decoded, key, iv)
  end
end
