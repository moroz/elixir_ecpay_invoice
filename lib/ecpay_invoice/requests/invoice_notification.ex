defmodule ECPayInvoice.InvoiceNotification do
  @type t :: %__MODULE__{
          invoice_no: String.t() | nil,
          email: String.t() | nil,
          phone: String.t() | nil,
          event_type: event_type(),
          notification_recipient: notification_recipient()
        }
  @behaviour ECPayInvoice.Request
  alias ECPayInvoice.InvoiceNotification, as: Notification
  alias ECPayInvoice.Config
  alias ECPayInvoice.Helpers

  @type event_type :: :issued | :voided | :won | :allowance | :allowance_voided
  @type notification_recipient :: :customer | :merchant | :all

  require Logger

  defstruct invoice_no: nil,
            email: nil,
            phone: nil,
            event_type: :issued,
            notification_recipient: :all

  def endpoint, do: "/B2CInvoice/InvoiceNotify"

  def new(attrs \\ %{})

  def new(attrs) do
    struct!(__MODULE__, attrs)
  end

  @spec send_email_issuance_notfication(invoice_no :: binary, email :: binary, profile :: atom()) ::
          {:ok, map()} | {:error, term()}
  def send_email_issuance_notfication(invoice_no, email, profile) do
    payload = %Notification{
      invoice_no: invoice_no,
      email: email
    }

    result = ECPayInvoice.Request.perform(payload, profile)

    case result do
      {:ok, _} ->
        Logger.info("Sent invoice issuance notification for invoice #{invoice_no} to #{email}")

      {:error, reason} ->
        Logger.error(
          "Failed to send invoice issuance notification for invoice #{invoice_no}: #{
            inspect(reason)
          }"
        )
    end

    result
  end

  def new_from_invoice_response(%{"InvoiceNo" => invoice_no}) do
    %Notification{
      invoice_no: invoice_no
    }
  end

  def to_api_payload(%Notification{} = notification, profile \\ :staging) do
    %{
      "MerchantID" => Config.get_merchant_id(profile),
      "InvoiceNo" => notification.invoice_no,
      "InvoiceTag" => normalize_event_type(notification.event_type),
      "NotifyMail" => notification.email,
      "Phone" => notification.phone,
      "Notify" => normalize_notification_channel(notification),
      "Notified" => normalize_notification_recipient(notification.notification_recipient)
    }
    |> Helpers.remove_nils()
  end

  defp normalize_notification_recipient(:customer), do: "C"
  defp normalize_notification_recipient(:merchant), do: "M"
  defp normalize_notification_recipient(:all), do: "A"

  defp normalize_notification_channel(%{phone: nil, email: email}) when is_binary(email), do: "E"
  defp normalize_notification_channel(%{email: nil, phone: phone}) when is_binary(phone), do: "S"

  defp normalize_notification_channel(%{email: email, phone: phone})
       when is_binary(phone) and is_binary(email),
       do: "A"

  defp normalize_event_type(:issued), do: "I"
  defp normalize_event_type(:voided), do: "II"
  defp normalize_event_type(:allowance), do: "A"
  defp normalize_event_type(:allowance_voided), do: "AI"
  defp normalize_event_type(:won), do: "AW"
end
