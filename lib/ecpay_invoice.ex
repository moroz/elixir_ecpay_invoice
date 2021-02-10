defmodule ECPayInvoice do
  @moduledoc """
  Client library for the ECPay Invoice API provided by Green World
  FinTech Service Co. (Taipei, Taiwan, Chinese name: 綠界科技股份有限公司).

  This library is compatible with API revision 3.0.0, which talks to
  the server using JSON payloads and uses AES encryption for verification.
  This library depends on HTTPoison and Jason.

  In order to use this library in production, you need to configure your API
  credentials in your configuration files (`config/prod.secret.exs`,
  `config/runtime.exs` etc.) by setting the `profiles` and `default_profile`
  keys for the `:ecpay_invoice` OTP application:

  ```elixir
  use Mix.Config

  config :ecpay_invoice, :profiles, %{
    production: %{
      development: false,
      merchant_id: "1420420",
      hash_iv: "CHANGE_ME",
      hash_key: "CHANGE_ME"
    }
  }

  config :ecpay_invoice, :default_profile, :production
  ```

  If you have multiple ECPay accounts, for instance, if your application
  serves multiple branches, you can set multiple configuration profiles
  and pass the profile name when performing the actual requests.
  Please note that the profile name can be either a string or an atom
  when performing requests (which is useful if you need to determine the
  profile name dynamically) but needs to be passed as atom in your runtime
  configuration.
  """
end
