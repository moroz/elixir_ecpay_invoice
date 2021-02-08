defmodule ECPayInvoice.B2CInvoice do
  @type number_category :: :regular | :special
  @type t :: %__MODULE__{
          print: boolean(),
          donate: boolean(),
          items: [ECPayInvoice.InvoiceItem.t()],
          number_category: number_category(),
          id: String.t() | nil,
          customer_data: ECPayInvoice.CustomerData.t() | nil
        }
  @behaviour ECPayInvoice.Request

  defstruct print: false,
            donate: false,
            items: [],
            number_category: :regular,
            id: nil,
            customer_data: nil

  alias ECPayInvoice.InvoiceItem
  alias ECPayInvoice.B2CInvoice
  alias ECPayInvoice.Config
  alias ECPayInvoice.Helpers

  def endpoint, do: "/B2CInvoice/Issue"

  def to_api_payload(%B2CInvoice{} = invoice) do
    %{
      "MerchantId" => Config.get_merchant_id(),
      "RelateNumber" => invoice.id || Helpers.generate_unique_id()
    }
  end

  @spec new(data :: map()) :: t()
  def new(data \\ %{}) do
    struct!(__MODULE__, data)
  end

  @spec add_item(invoice :: t(), item :: map() | InvoiceItem) :: t()
  def add_item(%B2CInvoice{} = invoice, %InvoiceItem{} = item) do
    Map.update!(invoice, :items, fn items -> items ++ [item] end)
  end

  def add_item(%B2CInvoice{} = invoice, %{} = item) do
    add_item(invoice, InvoiceItem.new(item))
  end
end
