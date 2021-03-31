defmodule ECPayInvoice.B2CInvoiceTest do
  use ExUnit.Case

  alias ECPayInvoice.CustomerData

  @valid_types ~w(ecpay natural mobile love_code)a

  describe "CustomerData.parse_carrier_type/1" do
    test "returns correct carrier type as atom when called with valid carrier type as atom" do
      for type <- @valid_types do
        actual = CustomerData.parse_carrier_type(type)
        assert actual == type
      end
    end
  end
end
