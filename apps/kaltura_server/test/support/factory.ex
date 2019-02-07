defmodule KalturaServer.Factory do
  @moduledoc """
  Implementation factory pattern for building domain model table records
  """

  alias KalturaServer.DomainModelFactories.{
    Region,
    Server,
    ServerGroup,
    Subnet,
    TvStream
  }

  Faker.start()

  def insert(table_name, attrs \\ %{})

  def insert(:region, attrs) do
    Region.insert(attrs)
  end

  def insert(:server, attrs) do
    Server.insert(attrs)
  end

  def insert(:server_group, attrs) do
    ServerGroup.insert(attrs)
  end

  def insert(:subnet, attrs) do
    Subnet.insert(attrs)
  end

  def insert(:tv_stream, attrs) do
    TvStream.insert(attrs)
  end

  def insert(model_name, attrs) do
    raise "Unknown model #{inspect(model_name)}, attrs: #{inspect(attrs)}"
  end
end