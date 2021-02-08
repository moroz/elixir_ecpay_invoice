defmodule ECPayInvoice.Payload do
  alias ECPayInvoice.Crypto

  def encode(data) do
    %{
      MerchantID: MERCHANT_ID,
      RqHeader: %{
        Timestamp: timestamp(),
        Revision: "3.0.0"
      },
      Data: Crypto.encrypt_payload(data)
    }
  end

  def timestamp, do: :os.system_time(:seconds)
end
