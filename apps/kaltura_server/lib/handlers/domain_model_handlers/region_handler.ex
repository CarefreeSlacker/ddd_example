defmodule KalturaServer.DomainModelHandlers.RegionHandler do
  @moduledoc false

  require Amnesia
  require Amnesia.Helper
  alias DomainModel.Region

  def handle(action, attrs) when action in [:insert, :update] do
    Amnesia.transaction do
      %Region{}
      |> struct(attrs)
      |> Region.write()
    end
    :ok
  end
end
