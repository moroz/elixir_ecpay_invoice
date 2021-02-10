defmodule ECPayInvoice.PayloadTest do
  use ExUnit.Case

  alias ECPayInvoice.Payload
  alias ECPayInvoice.Crypto
  alias ECPayInvoice.Config

  @payload %{
    "Pope" => "John Paul II",
    "Number" => 2137
  }

  describe "encode/2" do
    test "encodes the given payload as encrypted JSON" do
      encoded = Payload.encode(@payload, :staging)
      assert is_binary(encoded)
      %{"Data" => actual} = Jason.decode!(encoded)
      assert is_binary(actual)
      decrypted = Crypto.decrypt_base64(actual, :staging)
      assert String.valid?(decrypted)
      assert @payload == Jason.decode!(decrypted)
    end

    test "sets MerchantID" do
      encoded = Payload.encode(@payload, :staging)
      assert is_binary(encoded)
      %{"MerchantID" => actual} = Jason.decode!(encoded)
      assert actual == Config.get_merchant_id(:staging)
    end

    test "sets RqHeader with a Timestamp and Revision key" do
      encoded = Payload.encode(@payload, :staging)
      assert is_binary(encoded)
      %{"RqHeader" => %{"Revision" => "3.0.0", "Timestamp" => actual}} = Jason.decode!(encoded)
      timestamp = :os.system_time(:seconds)
      timediff = timestamp - actual
      assert timediff < 5
    end
  end
end
