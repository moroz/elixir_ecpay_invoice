defmodule ECPayInvoice.B2CInvoice do
  @type t :: %__MODULE__{
          print: boolean(),
          donate: boolean(),
          items: [ECPayInvoice.InvoiceItem.t()],
          order_id: String.t() | nil,
          customer_data: ECPayInvoice.CustomerData.t() | nil
        }
  @behaviour ECPayInvoice.Request

  defstruct print: false,
            donate: false,
            items: [],
            order_id: nil,
            customer_data: nil

  alias ECPayInvoice.InvoiceItem
  alias ECPayInvoice.B2CInvoice
  alias ECPayInvoice.Config
  alias ECPayInvoice.Helpers
  alias ECPayInvoice.CustomerData
  alias ECPayInvoice.Request
  alias ECPayInvoice.InvoiceNotification

  def endpoint, do: "/B2CInvoice/Issue"

  def to_api_payload(%B2CInvoice{} = invoice, profile \\ :staging) do
    customer_data = CustomerData.to_api_payload(invoice.customer_data)

    Map.merge(customer_data, %{
      "MerchantId" => Config.get_merchant_id(profile),
      "RelateNumber" => invoice.order_id || Helpers.generate_unique_id(),
      "Print" => Helpers.normalize_boolean(invoice.print),
      "Donation" => Helpers.normalize_boolean(invoice.donate),
      "Items" => InvoiceItem.to_api_payload(invoice.items),
      "SalesAmount" => InvoiceItem.sum(invoice.items),
      "TaxType" => "1",
      "InvType" => "07"
    })
  end

  @doc """
  Issues invoice, sends notification if the requests succeeded, and
  returns the response tuple from the original invoice issuance request.
  """
  @spec issue_and_notify(data :: t(), profile :: atom()) :: {:ok, map()} | {:error, term()}
  def issue_and_notify(%__MODULE__{} = data, profile) do
    email = data.customer_data.email

    with {:ok, %{"InvoiceNo" => invoice_no}} = response <- Request.perform(data, profile) do
      InvoiceNotification.send_email_issuance_notfication(invoice_no, email, profile)
      response
    end
  end

  @spec new(data :: map()) :: t()
  def new(data \\ %{}) do
    customer_data = CustomerData.new(Map.get(data, :customer_data, %{}))
    params = Map.put(data, :customer_data, customer_data)
    struct!(__MODULE__, params)
  end

  @spec add_item(invoice :: t(), item :: map() | InvoiceItem) :: t()
  def add_item(%B2CInvoice{} = invoice, %InvoiceItem{} = item) do
    Map.update!(invoice, :items, fn items -> items ++ [item] end)
  end

  def add_item(%B2CInvoice{} = invoice, %{} = item) do
    add_item(invoice, InvoiceItem.new(item))
  end
end
