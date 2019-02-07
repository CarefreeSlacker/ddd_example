defmodule KalturaServer.RequestProcessing.DataReader do
  @moduledoc """
  Read data from the request and pass it to `assigns` attribute of the Plug connection.
  """

  import Plug.Conn

  @request_type_regex "(catchup|live)\/"
  @codec_regex "(hls|mpd|mpd_wv|mpd_pr)\/"
  @resource_regex "(\\w+)$"
  @path_data_regex Regex.compile!("#{@request_type_regex}#{@codec_regex}#{@resource_regex}")

  def init(options) do
    options
  end

  def call(%Plug.Conn{remote_ip: remote_ip} = conn, _opts) do
    conn
    |> assign_request_data()
    |> assign(:ip_address, string_ip_address(remote_ip))
  end

  defp assign_request_data(%Plug.Conn{request_path: "/btv/" <> rest_path} = conn) do
    case Regex.run(@path_data_regex, rest_path) do
      [_whole_path, _type, protocol, resource_id] ->
        conn
        |> assign(:protocol, protocol)
        |> assign(:resource_id, resource_id)

      _result ->
        conn
    end
  end

  defp assign_request_data(%Plug.Conn{request_path: "/vod/" <> vod_path} = conn) do
    conn
    |> assign(:vod_path, vod_path)
  end

  defp assign_request_data(%Plug.Conn{request_path: _} = conn) do
    conn
  end

  defp string_ip_address(ip_address) do
    ip_address
    |> Tuple.to_list()
    |> Enum.map(&to_string/1)
    |> Enum.join(".")
  end
end
