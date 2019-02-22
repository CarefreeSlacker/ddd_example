defmodule KalturaAdmin.ServerGroupView do
  use KalturaAdminWeb, :view

  alias KalturaAdmin.{Area, Content, Servers}

  def regions do
    Area.list_regions()
    |> Enum.map(fn %{id: id, name: name} -> {name, id} end)
  end

  def selected_regions(nil), do: []

  def selected_regions(server_group_id) do
    Area.region_ids_for_server_group(server_group_id)
  end

  def linear_channels do
    Content.list_linear_channels()
    |> Enum.map(fn %{id: id, name: name} -> {name, id} end)
  end

  def selected_linear_channels(nil), do: []

  def selected_linear_channels(server_group_id) do
    Servers.linear_channel_ids_for_server_group(server_group_id)
  end

  def servers do
    Servers.list_servers()
    |> Enum.map(fn %{id: id, domain_name: name} -> {name, id} end)
  end

  def selected_servers(nil), do: []

  def selected_servers(server_group_id) do
    Servers.server_ids_for_server_group(server_group_id)
  end

  def decorate_collection(servers, name_field \\ :name) do
    servers
    |> Enum.map(fn %{^name_field => name} -> name end)
    |> Enum.join(", ")
  end
end
