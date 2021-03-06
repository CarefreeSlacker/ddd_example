defmodule CtiKaltura.Protocols.NotifyServerAttrsTest do
  use CtiKaltura.DataCase

  alias CtiKaltura.Protocols.NotifyServerAttrs

  describe "#get" do
    test "For Program schema" do
      {:ok, program} = Factory.insert(:program)
      result = NotifyServerAttrs.get(program)
      assert map_has_keys?(result, [:id, :name, :linear_channel_id, :epg_id, :program_record_ids])
    end

    test "For ProgramRecord schema" do
      {:ok, program_record} = Factory.insert(:program_record)
      result = NotifyServerAttrs.get(program_record)

      assert map_has_keys?(result, [
               :id,
               :program_id,
               :server_id,
               :status,
               :protocol,
               :encryption,
               :path,
               :epg_id,
               :prefix
             ])
    end

    test "For Region schema" do
      {:ok, region} = Factory.insert(:region)
      result = NotifyServerAttrs.get(region)
      assert map_has_keys?(result, [:id, :name, :status, :subnet_ids, :server_group_ids])
    end

    test "For Server schema" do
      {:ok, server} = Factory.insert(:server)
      result = NotifyServerAttrs.get(server)

      assert map_has_keys?(result, [
               :id,
               :type,
               :domain_name,
               :ip,
               :port,
               :status,
               :availability,
               :weight,
               :prefix,
               :healthcheck_enabled,
               :healthcheck_path,
               :server_group_ids,
               :program_record_ids
             ])
    end

    test "For ServerGroup schema" do
      {:ok, server_group} = Factory.insert(:server_group)
      result = NotifyServerAttrs.get(server_group)

      assert map_has_keys?(result, [
               :id,
               :name,
               :status,
               :server_ids,
               :region_ids,
               :linear_channel_ids
             ])
    end

    test "For Subnet schema" do
      {:ok, subnet} = Factory.insert(:subnet)
      result = NotifyServerAttrs.get(subnet)
      assert map_has_keys?(result, [:id, :region_id, :cidr, :name])
    end

    test "For LinearChannel schema" do
      {:ok, linear_channel} = Factory.insert(:linear_channel)
      result = NotifyServerAttrs.get(linear_channel)

      assert map_has_keys?(result, [
               :id,
               :epg_id,
               :name,
               :code_name,
               :server_group_id,
               :program_ids,
               :tv_stream_ids
             ])
    end
  end

  defp map_has_keys?(map, keys) do
    Enum.sort(Map.keys(map)) == Enum.sort(keys)
  end
end
