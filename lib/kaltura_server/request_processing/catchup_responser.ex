defmodule CtiKaltura.RequestProcessing.CatchupResponser do
  @moduledoc """
  Contains logic for processing CATCHUP request.
  """

  use CtiKaltura.KalturaLogger, metadata: [domain: :request]

  import Plug.Conn
  alias CtiKaltura.ClosestEdgeServerService
  alias CtiKaltura.DomainModelContext, as: Context
  alias CtiKaltura.RequestProcessing.RequestHelper
  alias CtiKaltura.Util.ServerUtil

  @spec make_response(Plug.Conn.t()) :: {Plug.Conn.t(), integer, binary}
  def make_response(%Plug.Conn{} = conn) do
    {conn, %{}}
    |> put_resource_params()
    |> put_server_domain_data()
    |> catchup_response()
  end

  def make_response(conn) do
    {conn, 400, "Request invalid"}
  end

  def put_resource_params(
        {%Plug.Conn{assigns: %{resource_id: epg_id, protocol: protocol, encryption: encryption}} =
           conn, data}
      ) do
    epg_id
    |> Context.find_program_records(protocol)
    |> RequestHelper.obtain_entity_by_encryption(RequestHelper.normalize_encryption(encryption))
    |> case do
      nil ->
        {conn, data}

      program_record ->
        {conn,
         data
         |> Map.merge(%{
           record_path: program_record.path,
           dvr_server_prefix: program_record.prefix
         })}
    end
  end

  def put_server_domain_data({
        %Plug.Conn{assigns: %{ip_address: ip_address}} = conn,
        data
      }) do
    case ClosestEdgeServerService.perform(ip_address) do
      %{domain_name: domain_name, port: port} ->
        {conn, Map.merge(data, %{domain_name: domain_name, port: port})}

      _ ->
        {conn, data}
    end
  end

  defp catchup_response(
         {conn, %{domain_name: _, port: _, dvr_server_prefix: _, record_path: _} = data}
       ) do
    {
      put_resp_header(conn, "Location", make_catchup_redirect_path(data)),
      302,
      ""
    }
  end

  defp catchup_response({%Plug.Conn{assigns: assigns, request_path: request_path} = conn, data}) do
    log_error(
      "Can't process request.\nConn assigns: #{inspect(assigns)}\nData: #{inspect(data)}\nRequest path: #{
        request_path
      }"
    )

    {conn, 404, "Server not found"}
  end

  defp make_catchup_redirect_path(%{
         domain_name: domain_name,
         port: port,
         dvr_server_prefix: prefix,
         record_path: record_path
       }) do
    ServerUtil.prepare_url(domain_name, port, "/dvr/#{prefix}/#{record_path}")
  end
end
