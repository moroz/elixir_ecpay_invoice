defmodule ECPayInvoice.Payload do
  alias ECPayInvoice.Config
  alias ECPayInvoice.Crypto

  @moduledoc """
  This module contains functions related to encoding request payloads
  to the format expected by the ECPay API.
  """

  @doc """
  With a given `payload` as map and a `profile` name as string or atom,
  encodes the given payload to the JSON format expected by the ECPay
  Invoice API, putting the respective fields of the request, such as
  `Revision` key, `MerchantID`, and `Timestamp`, in the correct parts
  of the JSON object.

  Serializes the original `payload` as JSON, URL-encodes it, encrypts
  it using the AES cipher as required by the API, and serializes the
  resulting binary to Base64. For more details regarding this step, see
  `ECPayInvoice.Crypto.encrypt_payload/2`.
  """
  @spec encode(data :: map(), profile :: atom() | binary()) :: binary()
  def encode(data, profile) when is_map(data) do
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
