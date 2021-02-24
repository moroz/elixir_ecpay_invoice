defmodule EcpayInvoice.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecpay_invoice,
      version: "0.0.1-alpha8",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto, :inets, :ssl],
      env: defaults()
    ]
  end

  defp defaults do
    [
      profiles: %{
        staging: %{
          merchant_id: "2000132",
          hash_key: "ejCk326UnaZWKisg",
          hash_iv: "q9jcZX8Ib9LM8wYk",
          development: true
        }
      },
      default_profile: :staging
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.0"}
    ]
  end

  defp package do
    [
      licenses: ["BSD-3"],
      description: """
        Client library for the ECPay Invoice API provided by Green World
        FinTech Service Co. (Taipei, Taiwan, Chinese name: 綠界科技股份有限公司).

        This library is compatible with API revision 3.0.0, which talks to
        the server using JSON payloads and uses AES encryption for verification.
      """,
      links: %{
        "GitHub" => "https://github.com/moroz/elixir_ecpay_invoice"
      }
    ]
  end
end
