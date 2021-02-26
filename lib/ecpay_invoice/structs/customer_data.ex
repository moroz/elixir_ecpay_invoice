defmodule ECPayInvoice.CustomerData do
  @type t :: %__MODULE__{
          id: String.t() | nil,
          tax_id: String.t() | nil,
          name: String.t() | nil,
          address: String.t() | nil,
          phone: String.t() | nil,
          email: String.t() | nil,
          carrier_type: carrier_type(),
          carrier_no: String.t() | nil
        }

  @type carrier_type :: nil | :ecpay | :natural | :mobile

  alias ECPayInvoice.CustomerData
  alias ECPayInvoice.Helpers

  defstruct id: nil,
            tax_id: nil,
            name: nil,
            address: nil,
            phone: nil,
            email: nil,
            carrier_type: :ecpay,
            carrier_no: nil

  @spec new(params :: map()) :: t()
  def new(params \\ %{}) do
    params = Map.update!(params, :carrier_type, &parse_carrier_type/1)
    struct!(__MODULE__, params)
  end

  def to_api_payload(%CustomerData{} = data) do
    %{
      "CustomerID" => data.id,
      "CustomerIdentitfier" => data.tax_id,
      "CustomerAddr" => data.address,
      "CustomerPhone" => data.phone,
      "CustomerName" => data.name,
      "CustomerEmail" => data.email,
      "CarrierNum" => normalize_carrier_no(data),
      "CarrierType" => normalize_carier_type(data)
    }
    |> Helpers.remove_nils()
  end

  @legal_carrier_types ~w(ecpay natural mobile)a

  def parse_carrier_type(nil), do: nil

  def parse_carrier_type(type) when type in @legal_carrier_types do
    type
  end

  def parse_carrier_type(type) when is_binary(type) do
    as_atom = type |> Macro.underscore() |> String.to_existing_atom()

    case as_atom in @legal_carrier_types do
      true ->
        as_atom

      _ ->
        raise ArgumentError, "Invalid value for carrier_type: #{type}"
    end
  end

  defp normalize_carier_type(%{tax_id: present}) when is_binary(present) do
    ""
  end

  defp normalize_carier_type(:ecpay), do: "1"
  defp normalize_carier_type(:natural), do: "2"
  defp normalize_carier_type(:mobile), do: "3"

  defp normalize_carier_type(%{carrier_type: type}), do: normalize_carier_type(type)

  defp normalize_carrier_no(%{tax_id: present}) when is_binary(present) do
    ""
  end

  defp normalize_carrier_no(%{carrier_type: :ecpay}), do: ""
  defp normalize_carrier_no(%{carrier_type: nil}), do: ""
  defp normalize_carrier_no(%{carrier_no: carrier_no}), do: carrier_no
end
