defmodule ECPayInvoice.Helpers do
  def generate_unique_id do
    :crypto.strong_rand_bytes(15)
    |> Base.encode16()
  end
end
