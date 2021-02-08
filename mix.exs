defmodule EcpayInvoice.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecpay_invoice,
      version: "0.0.1-alpha3",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      defaults: defaults()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto, :inets, :ssl]
    ]
  end

  defp defaults do
    [
      profiles: %{
        "staging" => %{
          merchant_id: "2000132",
          hash_key: "ejCk326UnaZWKisg",
          hash_iv: "q9jcZX8Ib9LM8wYk",
          development: true
        }
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:jason, "~> 1.0"}
    ]
  end

  defp package do
    [
      licenses: ["BSD-3"],
      description: "An attempt at a client implementation for ECPay invoice API.",
      links: %{}
    ]
  end
end
