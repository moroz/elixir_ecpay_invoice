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

  def encrypt_payload(data, profile \\ :staging)

  def encrypt_payload(data, profile) when is_map(data) do
    Jason.encode!(data)
    |> encrypt_payload(profile)
  end

  def encrypt_payload(data, profile) when is_binary(data) do
    with {key, iv} <- Config.get_key_and_iv(profile) do
      encrypt_payload(data, key, iv)
    end
  end

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

  def encrypt(data, profile \\ :staging) do
    with {key, iv} <- Config.get_key_and_iv(profile) do
      encrypt(data, key, iv)
    end
  end

  def encrypt(data, key, iv) do
    :crypto.crypto_one_time(@cipher, key, iv, data, encrypt: true, padding: :pkcs_padding)
  end

  def decrypt(data, profile \\ :staging)
      when is_binary(data) do
    with {key, iv} <- Config.get_key_and_iv(profile) do
      decrypt(data, key, iv)
    end
  end

  def decrypt(data, key, iv) do
    :crypto.crypto_one_time(@cipher, key, iv, data, encrypt: false, padding: :pkcs_padding)
    |> URI.decode()
  end

  def decrypt_base64(data, profile \\ :staging) when is_binary(data) do
    decoded = Base.decode64!(data)
    decrypt(decoded, profile)
  end

  def decrypt_base64(data, key, iv) when is_binary(data) do
    decoded = Base.decode64!(data)
    decrypt(decoded, key, iv)
  end
end
