defmodule CtiKaltura.DomainModelHandlers.ServerGroupHandler do
  @moduledoc false

  alias DomainModel.ServerGroup

  use CtiKaltura.DomainModelHandlers.AbstractHandler,
    table: ServerGroup,
    joined_attributes_and_models: [
      server_ids: "Server",
      region_ids: "Region",
      linear_channel_ids: "LinearChannel"
    ]
end
