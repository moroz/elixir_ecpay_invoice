defmodule ECPayInvoice.CarrierOptions do
  # TODO: Remove this module if not used
  @type carrier_type :: :print | :green_world | :love_code | :mobile | :natural
  @type love_code :: binary | nil
  @type carrier_number :: binary | nil

  @type t :: %__MODULE__{
          type: carrier_type,
          love_code: love_code,
          number: carrier_number
        }

  defstruct type: :green_world,
            love_code: nil,
            number: nil
end
