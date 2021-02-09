defmodule ECPayInvoice.Request do
  @callback endpoint() :: String.t()
  @callback to_api_payload(struct :: term(), profile :: atom | String.t()) :: map() | list()
  require Logger

  @headers [
    {"Accept", "application/json, text/plain, */*"},
    {"Content-Type", "application/json"}
  ]

  alias ECPayInvoice.Config
  alias ECPayInvoice.Payload
  alias ECPayInvoice.Crypto

  def perform(%module{} = request, profile \\ :staging) do
    endpoint = Config.get_endpoint(module.endpoint(), profile)
    payload = module.to_api_payload(request, profile)
    generic_request(endpoint, payload, profile)
  end

  def generic_request(endpoint, payload, profile \\ :staging)
      when is_binary(endpoint) and is_map(payload) do
    data = Payload.encode(payload, profile)

    post(endpoint, data)
    |> handle_response(profile)
  end

  def post(endpoint, body) do
    HTTPoison.post!(endpoint, body, @headers)
  end

  def handle_response(response, profile \\ :staging)

  def handle_response(%HTTPoison.Response{status_code: 200, body: body}, profile) do
    data = Jason.decode!(body)

    case decode_payload(data, profile) do
      %{"RtnCode" => 1} = payload ->
        {:ok, payload}

      other ->
        {:error, other}
    end
  end

  def handle_response(%HTTPoison.Response{status_code: 500, body: body}, _profile) do
    {:error, :internal_server_error, body}
  end

  defp decode_payload(%{"Data" => nil}, _profile), do: nil

  defp decode_payload(%{"Data" => string}, profile),
    do: Crypto.decrypt_base64(string, profile) |> Jason.decode!()
end
