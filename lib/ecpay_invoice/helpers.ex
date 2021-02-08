defmodule ECPayInvoice.Helpers do
  def generate_unique_id do
    :crypto.strong_rand_bytes(15)
    |> Base.encode16()
  end

  def remove_nils(map) when is_map(map) do
    compact = for {key, value} <- map, value != nil, do: {key, value}
    Map.new(compact)
  end

  def normalize_boolean("0"), do: "0"
  def normalize_boolean("1"), do: "1"
  def normalize_boolean(0), do: "0"
  def normalize_boolean(1), do: "1"
  def normalize_boolean(false), do: "0"
  def normalize_boolean(true), do: "1"

  @mobile_carrier_regexp ~r/^\/[0-9A-Z+-.]{7}$/
  def validate_mobile_carrier_no(carrier_no) do
    String.match?(carrier_no, @mobile_carrier_regexp)
  end
end
