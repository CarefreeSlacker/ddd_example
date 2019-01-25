defmodule KalturaServer.DomainModelFactories.Region do
  @moduledoc false

  use KalturaServer.DomainModelFactories.AbstractFactory, table: DomainModel.Region

  def default_region_attrs do
    %{
      id: next_table_id(),
      name: Faker.Lorem.word(),
      status: :active,
      subnet_ids: [],
      server_group_ids: []
    }
  end

  def insert(attrs) do
    Amnesia.transaction(fn ->
      DomainModel.Region.__struct__()
      |> struct(prepare_attrs(attrs))
      |> DomainModel.Region.write()
    end)
  end

  defp prepare_attrs(attrs) do
    Map.merge(default_region_attrs(), attrs)
  end
end
