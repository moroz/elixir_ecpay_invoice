defmodule EcpayInvoice.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecpay_invoice,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.0"},
      {:pkcs7, "~> 1.0"}
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
