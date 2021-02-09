require Logger
email = System.get_env("EMAIL", "user@example.com")

ECPayInvoice.B2CInvoice.new(%{customer_data: %{email: email}})
|> ECPayInvoice.B2CInvoice.add_item(%{name: "我是一隻小小小鳥", unit_price: 2137, count: 2})
|> ECPayInvoice.Request.perform()
|> case do
  {:ok, payload} ->
    Logger.info("Invoice issued with the number #{payload["InvoiceNo"]}")

    notification =
      ECPayInvoice.InvoiceNotification.new_from_invoice_response(payload)
      |> Map.put(:email, email)
      |> ECPayInvoice.Request.perform()
      |> case do
        {:ok, _} ->
          Logger.info("Sent invoice issuance notification")

        _ ->
          Logger.error("Failed to send invoice issuance notification")
      end

  {:error, payload} ->
    Logger.error("Failed to issue invoice. Payload: #{inspect(payload)}")
end
