defmodule CtiKaltura.ServerGroupFactory do
  @moduledoc false
  alias CtiKaltura.Repo
  alias CtiKaltura.Servers.ServerGroup

  Faker.start()

  def default_attrs,
    do: %{
      name: Faker.Lorem.word(),
      description: Faker.Lorem.sentence(),
      status: "ACTIVE"
    }

  def build(attrs) do
    %ServerGroup{}
    |> ServerGroup.changeset(prepare_attrs(attrs))
  end

  defp prepare_attrs(attrs) do
    default_attrs()
    |> Map.merge(attrs)
  end

  def insert(attrs) do
    attrs
    |> build()
    |> Repo.insert()
  end

  def insert_and_notify(attrs) do
    attrs
    |> build()
    |> Repo.insert_and_notify()
  end
end
