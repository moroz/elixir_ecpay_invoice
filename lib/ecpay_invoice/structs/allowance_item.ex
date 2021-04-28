defmodule ECPayInvoice.AllowanceItem do
  @type t :: %__MODULE__{
          name: String.t() | nil,
          count: integer(),
          unit: String.t(),
          unit_price: integer()
        }

  alias ECPayInvoice.InvoiceItem

  defstruct name: nil, count: 1, unit: "式", unit_price: nil

  @spec new(params :: map() | t()) :: t()
  def new(%InvoiceItem{} = item), do: item
  def new(%{} = map), do: struct!(__MODULE__, map)

  def parse_list(list) when is_list(list) do
    Enum.map(list, &new/1)
  end

  def to_api_payload(%InvoiceItem{} = item) do
    %{
      "ItemName" => item.name,
      "ItemCount" => item.count,
      "ItemWord" => item.unit,
      "ItemPrice" => item.unit_price,
      "ItemTaxType" => "1",
      "ItemAmount" => item.count * item.unit_price
    }
  end

  def to_api_payload(list) when is_list(list) do
    Enum.with_index(list)
    |> Enum.map(fn {item, index} ->
      item
      |> to_api_payload()
      |> Map.put("ItemSeq", index)
    end)
  end

  def sum(list) when is_list(list) do
    for %{unit_price: unit_price, count: count} <- list, reduce: 0 do
      sum ->
        sum + count * unit_price
    end
  end
end
