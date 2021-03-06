defmodule CtiKaltura.Authorization.Service do
  @moduledoc """
  Contains logic for performing authorization
  """

  alias CtiKaltura.{Repo, User}
  import Comeonin.Argon2, only: [checkpw: 2, dummy_checkpw: 0]

  @spec authorize(email :: binary, password :: binary) :: {:ok}
  def authorize(email, password) do
    user = Repo.get_by(User, email: email)

    cond do
      user && checkpw(password, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        dummy_checkpw()
        {:error, :not_found}
    end
  end

  # TODO substitute to macro. For authomatic preloading before each controller action
  # Macro use cases:
  # `use CtiKaltura.Authorization.LoadUser, only: [:new, :create, :index]`
  # `use CtiKaltura.Authorization.LoadUser, except: [:edit, :update]`
  # `use CtiKaltura.Authorization.LoadUser`
  @spec load_user(conn :: Plug.Conn.t()) :: User.t() | nil
  def load_user(conn) do
    Guardian.Plug.current_resource(conn)
  end
end
