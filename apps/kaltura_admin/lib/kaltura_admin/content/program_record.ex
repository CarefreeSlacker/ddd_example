defmodule KalturaAdmin.Content.ProgramRecord do
  use Ecto.Schema
  use Observable, :notifier
  import Ecto.Changeset
  alias KalturaAdmin.Content.{Program, ProgramRecordObserver}
  alias KalturaAdmin.Servers.Server
  alias KalturaAdmin.{RecordingStatus, RecordCodec}

  @cast_fields [:status, :codec, :path, :server_id, :program_id]
  @required_fields [:status, :codec, :path, :server_id, :program_id]

  schema "program_records" do
    field(:path, :string)
    field(:status, RecordingStatus)
    field(:codec, RecordCodec)

    belongs_to(:server, Server)
    belongs_to(:program, Program)

    timestamps()
  end

  @doc false
  def changeset(program_record, attrs) do
    program_record
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end

  observations do
    action(:insert, [ProgramRecordObserver])
    action(:update, [ProgramRecordObserver])
    action(:delete, [ProgramRecordObserver])
  end
end
