defmodule ECPayInvoice.B2CAllowance do
  @type t :: %__MODULE__{
          invoice_no: String.t() | nil,
          invoice_date: DateTime | nil,
          # allowance_notify: NotificationCategory # TODO
          customer_name: String.t() | nil,
          notify_mail: String.t() | nil,
          notify_phone: String.t() | nil,
          allowance_amount: :integer | nil,
          items: [ECPayInvoice.AllowanceItem.t()]
        }
  @behaviour ECPayInvoice.Request

  defstruct merchant_id: nil,
            invoice_no: nil,
            invoice_date: nil,
            customer_name: nil,
            notify_mail: nil,
            notify_phone: nil,
            allowance_amount: nil,
            items: []

  alias ECPayInvoice.AllowanceItem
  alias ECPayInvoice.B2CAllowance
  alias ECPayInvoice.Config
  alias ECPayInvoice.Helpers
  alias ECPayInvoice.Request
  alias ECPayInvoice.InvoiceNotification

  require Logger

  def endpoint, do: "/B2CInvoice/Allowance"

  def to_api_payload(%B2CAllowance{} = allowance, profile \\ :staging) do
    %{
      "MerchantId" => Config.get_merchant_id(profile),
      "InvoiceNo" => allowance.invoice_no || Helpers.generate_unique_id(),
      "InvoiceDate" => allowance.invoice_date |> Date.to_iso8601(),
      # TODO implement other methods for AllowanceNotify
      "AllowanceNotify" => :E,
      "CustomerName" => allowance.customer_name,
      "NotifyMail" => allowance.notify_mail,
      "NotifyPhone" => allowance.notify_phone,
      "AllowanceAmount" => AllowanceItem.sum(allowance.items),
      "Items" => AllowanceItem.to_api_payload(allowance.items)
    }
  end

  @doc """
  Issues allowance, sends notification if the requests succeeded, and
  returns the response tuple from the original invoice issuance request.
  """
  @spec issue_and_notify(data :: t(), profile :: atom()) :: {:ok, map()} | {:error, term()}
  def issue_and_notify(%__MODULE__{} = data, profile) do
    email = data.notify_mail

    with {:ok, %{"InvoiceNo" => invoice_no}} = response <- Request.perform(data, profile) do
      Logger.info("Issued allowance #{invoice_no}")
      InvoiceNotification.send_email_issuance_notfication(invoice_no, email, profile)
      response
    end
  end

  @spec new(data :: map()) :: t()
  def new(data \\ %{}) do
    items = AllowanceItem.parse_list(Map.get(data, :items, []))
    params = data |> Map.put(:items, items)
    struct!(__MODULE__, params)
  end

  @spec add_item(allowance :: t(), item :: map() | AllowanceItem) :: t()
  def add_item(%B2CAllowance{} = allowance, %AllowanceItem{} = item) do
    Map.update!(allowance, :items, fn items -> items ++ [item] end)
  end

  def add_item(%B2CAllowance{} = allowance, %{} = item) do
    add_item(allowance, AllowanceItem.new(item))
  end
end
