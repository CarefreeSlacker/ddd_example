defmodule CtiKaltura.RequestProcessing.VodResponser do
  @moduledoc """
  Contains logic for processing VOD request.
  """

  use CtiKaltura.KalturaLogger, metadata: [domain: :request]

  import Plug.Conn
  alias CtiKaltura.ClosestEdgeServerService
  alias CtiKaltura.Util.ServerUtil

  @spec make_response(Plug.Conn.t()) :: {Plug.Conn.t(), integer, binary}
  def make_response(%Plug.Conn{} = conn) do
    {conn, %{}}
    |> put_path_params()
    |> put_server_domain_data()
    |> vod_response()
  end

  def make_response(conn) do
    {conn, 400, "Request invalid"}
  end

  defp put_path_params({%Plug.Conn{assigns: %{vod_path: vod_path}} = conn, data}) do
    {conn, Map.put(data, :vod_path, vod_path)}
  end

  defp put_server_domain_data({%Plug.Conn{assigns: %{ip_address: ip_address}} = conn, data}) do
    case ClosestEdgeServerService.perform(ip_address) do
      %{domain_name: domain_name, port: port} ->
        {conn, Map.merge(data, %{domain_name: domain_name, port: port})}

      _ ->
        {conn, data}
    end
  end

  defp put_server_domain_data({conn, data}), do: {conn, data}

  defp vod_response({conn, %{domain_name: _, port: _, vod_path: _} = data}) do
    {
      put_resp_header(conn, "Location", make_live_redirect_path(data)),
      302,
      ""
    }
  end

  defp vod_response({%Plug.Conn{assigns: assigns, request_path: request_path} = conn, data}) do
    log_error(
      "Can't process request.\nConn assigns: #{inspect(assigns)}\nData: #{inspect(data)}\nRequest path: #{
        request_path
      }"
    )

    {conn, 404, "Server not found"}
  end

  # Make redirect for VOD content over HTTP ONLY !!! (NOT HTTPS. Requirements by 2DAY)
  defp make_live_redirect_path(%{
         domain_name: domain_name,
         vod_path: vod_path
       }) do
    ServerUtil.prepare_url(domain_name, 80, "/vod/#{vod_path}")
  end
end
