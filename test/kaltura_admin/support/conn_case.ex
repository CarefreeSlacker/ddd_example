defmodule CtiKaltura.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias CtiKaltura.Authorization.Guardian, as: GuardImpl
      alias CtiKaltura.{Factory, Repo, User}
      alias Guardian.Plug, as: GPlug
      alias Plug.Conn

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import CtiKalturaWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint CtiKaltura.Endpoint

      @spec authorize(Conn.t(), User.t()) :: Conn.t()
      def authorize(conn, user) do
        GPlug.sign_in(conn, GuardImpl, user)
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(CtiKaltura.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(CtiKaltura.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
