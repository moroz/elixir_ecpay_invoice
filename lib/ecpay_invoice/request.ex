defmodule ECPayInvoice.Request do
  @callback endpoint() :: String.t()
  @callback to_api_payload(term()) :: map() | list()

  alias ECPayInvoice.Config
  alias ECPayInvoice.Payload
  alias ECPayInvoice.Crypto

  def perform(%module{} = request) do
    endpoint = Config.get_endpoint(module.endpoint())
    payload = module.to_api_payload(request)
    generic_request(endpoint, payload)
  end

  def generic_request(endpoint, payload) when is_binary(endpoint) and is_map(payload) do
    data = Payload.encode(payload)

    post(endpoint, data)
    |> handle_response()
  end

  def post(endpoint, body) do
    request = {to_charlist(endpoint), [], 'application/json', body}
    :httpc.request(:post, request, [], [])
  end

  def handle_response({:ok, {{_, code, _}, headers, body}}) do
    data = Jason.decode!(body)
    %{code: code, headers: headers, body: data, decrypted: decode_payload(data)}
  end

  defp decode_payload(%{"Data" => nil}), do: nil
  defp decode_payload(%{"Data" => string}), do: Crypto.decrypt_base64(string) |> Jason.decode!()
end
