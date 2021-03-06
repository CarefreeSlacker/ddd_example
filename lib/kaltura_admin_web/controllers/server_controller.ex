defmodule CtiKaltura.ServerController do
  use CtiKalturaWeb, :controller

  alias CtiKaltura.{ErrorHelpers, Servers}
  alias CtiKaltura.Servers.Server

  def index(conn, _params) do
    servers = Servers.list_servers([:server_groups])
    render(conn, "index.html", servers: servers, current_user: load_user(conn))
  end

  def new(conn, _params) do
    changeset = Servers.change_server(%Server{})
    render(conn, "new.html", changeset: changeset, current_user: load_user(conn), server_id: nil)
  end

  def create(conn, %{"server" => server_params}) do
    case Servers.create_server(server_params) do
      {:ok, server} ->
        conn
        |> put_flash(:info, "Server created successfully.")
        |> redirect(to: server_path(conn, :show, server))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "new.html",
          changeset: changeset,
          current_user: load_user(conn),
          server_id: nil
        )
    end
  end

  def show(conn, %{"id" => id}) do
    server = Servers.get_server!(id, [:server_groups])

    render(conn, "show.html", server: server, current_user: load_user(conn))
  end

  def edit(conn, %{"id" => id}) do
    server = Servers.get_server!(id, [:server_groups])

    changeset = Servers.change_server(server)

    render(
      conn,
      "edit.html",
      server: server,
      changeset: changeset,
      current_user: load_user(conn),
      server_id: id
    )
  end

  def update(conn, %{"id" => id, "server" => server_params}) do
    server = Servers.get_server!(id)

    case Servers.update_server(server, server_params) do
      {:ok, server} ->
        conn
        |> put_flash(:info, "Server updated successfully.")
        |> redirect(to: server_path(conn, :show, server))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "edit.html",
          server: server,
          changeset: changeset,
          current_user: load_user(conn),
          server_id: id
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    server = Servers.get_server!(id)

    case Servers.delete_server(server) do
      {:ok, _server} ->
        conn
        |> put_flash(:info, "Server deleted successfully.")
        |> redirect(to: server_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, ErrorHelpers.prepare_error_message(changeset))
        |> redirect(to: server_path(conn, :index))
    end
  end
end
