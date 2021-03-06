defmodule CtiKaltura.Area.Region do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias CtiKaltura.{Area, Repo}
  alias CtiKaltura.Area.{RegionServerGroup, Subnet}
  alias CtiKaltura.Observers.{CrudActionsLogger, DomainModelNotifier, DomainModelObserver}
  alias CtiKaltura.Servers.ServerGroup
  use DomainModelNotifier, observers: [CrudActionsLogger, DomainModelObserver]

  @cast_fields [:name, :description, :status]
  @required_fields [:name, :status]

  schema "regions" do
    field(:description, :string)
    field(:name, :string)
    field(:status, :string)

    has_many(
      :region_server_groups,
      RegionServerGroup,
      foreign_key: :region_id,
      on_replace: :delete
    )

    many_to_many(:server_groups, ServerGroup, join_through: RegionServerGroup)

    has_many(:subnets, Subnet, foreign_key: :region_id)

    timestamps()
  end

  @doc false
  def changeset(%{id: id} = region, attrs) do
    region
    |> Repo.preload(:region_server_groups)
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_name()
    |> cast_server_groups(id, attrs)
  end

  defp validate_name(changeset) do
    changeset
    |> unique_constraint(:name)
  end

  defp cast_server_groups(changeset, id, %{server_group_ids: sg_ids}) do
    perform_casting_server_groups(changeset, id, sg_ids)
  end

  defp cast_server_groups(changeset, id, %{"server_group_ids" => sg_ids}) do
    perform_casting_server_groups(changeset, id, sg_ids)
  end

  defp cast_server_groups(changeset, _id, _attrs), do: changeset

  defp perform_casting_server_groups(changeset, id, sg_ids) do
    changeset
    |> cast(%{region_server_groups: Area.make_request_server_group_params(id, sg_ids)}, [])
    |> cast_assoc(:region_server_groups, with: &RegionServerGroup.region_association_changeset/2)
  end
end
