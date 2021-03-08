defmodule ECPayInvoice.VerifyBarcode do
  @behaviour ECPayInvoice.Request

  alias ECPayInvoice.VerifyBarcode
  alias ECPayInvoice.Config
  alias ECPayInvoice.Request

  @type t :: %__MODULE__{
          barcode: binary | nil
        }

  defstruct barcode: nil

  def new(barcode) when is_binary(barcode) do
    %__MODULE__{
      barcode: barcode
    }
  end

  def new(map) when is_map(map) do
    struct!(__MODULE__, map)
  end

  def endpoint, do: "/B2CInvoice/CheckBarcode"

  def to_api_payload(%VerifyBarcode{} = request, profile \\ :staging) do
    %{
      "MerchantId" => Config.get_merchant_id(profile),
      "BarCode" => request.barcode
    }
  end

  @type error_reason :: :invalid_code | :maintenance | :unknown
  @spec verify_barcode(barcode :: binary, profile :: atom) :: :ok | {:error, error_reason}
  def verify_barcode(barcode, profile \\ :staging) when is_binary(barcode) do
    barcode
    |> new()
    |> Request.perform(profile)
    |> parse_response()
  end

  def parse_response({:ok, %{"IsExist" => "Y"}}), do: :ok
  def parse_response({:ok, _}), do: {:error, :invalid_code}
  def parse_response({:error, %{"RtnCode" => 100_000_100}}), do: {:error, :maintenance}
  def parse_response(_), do: {:error, :unknown}
end
