defmodule CtiKaltura.ProgramRecordFactory do
  @moduledoc false
  alias CtiKaltura.{Repo, Factory}
  alias CtiKaltura.Content.ProgramRecord

  Faker.start()

  def default_attrs,
    do: %{
      path: "#{Faker.Lorem.word()}#{:rand.uniform(10000)}#{:rand.uniform(10000)}",
      status: "PLANNED",
      protocol: "HLS",
      encryption: "NONE"
    }

  def build(attrs) do
    %ProgramRecord{}
    |> ProgramRecord.changeset(prepare_attrs(attrs))
  end

  defp prepare_attrs(attrs) do
    default_attrs()
    |> Map.merge(attrs)
    |> (fn
          %{server_id: _id} = attrs_map ->
            attrs_map

          attrs_map ->
            {:ok, %{id: server_id}} = Factory.insert(:server)
            Map.put(attrs_map, :server_id, server_id)
        end).()
    |> (fn
          %{program_id: _id} = attrs_map ->
            attrs_map

          attrs_map ->
            {:ok, %{id: program_id}} = Factory.insert(:program)
            Map.put(attrs_map, :program_id, program_id)
        end).()
  end

  def insert(attrs) do
    attrs
    |> build()
    |> Repo.insert()
  end
end