defmodule ECPayInvoice.Payload do
  alias ECPayInvoice.Config
  alias ECPayInvoice.Crypto

  @spec encode(data :: map(), profile :: atom() | binary()) :: binary()
  def encode(data, profile \\ :staging) when is_map(data) do
    Jason.encode!(%{
      MerchantID: Config.get_merchant_id(profile),
      RqHeader: %{
        Timestamp: :os.system_time(:seconds),
        Revision: "3.0.0"
      },
      Data: Crypto.encrypt_payload(data, profile)
    })
  end
end
