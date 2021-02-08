defmodule ECPayInvoice.CryptoTest do
  use ExUnit.Case

  alias ECPayInvoice.Crypto

  @key "A123456789012345"
  @iv "B123456789012345"

  @data "{\"Name\":\"Test\",\"ID\":\"A123456789\"}"
  @base64 "7woM9RorZKAtXJRVccAb0qhHYm+5lnlhBzyfh5EZdNck7PacNsRHgv/Jvp//ajJidqcQcs0UmAgPQVjXQHeziw=="
  @expected "%7B%22Name%22%3A%22Test%22%2C%22ID%22%3A%22A123456789%22%7D"

  describe "uri_escape/1" do
    test "encodes binary to non-standard URL-encoded uppercase string" do
      actual = Crypto.uri_escape(@data)
      assert actual == @expected
    end

    @nonstandard ["!", "*", "(", ")"]

    test "handles non-standard .NET encoding of certain characters" do
      for char <- @nonstandard do
        assert Crypto.uri_escape(char) == char
      end
    end
  end

  describe "encrypt_payload/3" do
    test "escapes, encrypts, and encodes binary payload as Base64" do
      actual = Crypto.encrypt_payload(@data, @key, @iv)
      assert actual == @base64
    end
  end

  describe "decrypt_base64" do
    test "decodes Base64-encoded payload to JSON" do
      actual = Crypto.decrypt_base64(@base64, @key, @iv)
      assert actual == @data
    end
  end
end
