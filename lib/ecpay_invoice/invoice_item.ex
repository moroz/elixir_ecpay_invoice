defmodule ECPayInvoice.InvoiceItem do
  @type t :: %__MODULE__{
          name: String.t() | nil,
          count: integer(),
          unit: String.t(),
          unit_price: integer()
        }

  alias ECPayInvoice.InvoiceItem

  defstruct name: nil, count: 1, unit: "個", unit_price: nil

  @spec new(params :: map() | t()) :: t()
  def new(%InvoiceItem{} = item), do: item
  def new(%{} = map), do: struct!(map)
end
