defmodule KalturaAdminWeb.SubnetControllerTest do
  use KalturaAdminWeb.ConnCase

  alias KalturaAdmin.Area

  @create_attrs %{cidr: "some cidr", name: "some name"}
  @update_attrs %{cidr: "some updated cidr", name: "some updated name"}
  @invalid_attrs %{cidr: nil, name: nil}

  def fixture(:subnet) do
    {:ok, subnet} = Area.create_subnet(@create_attrs)
    subnet
  end

  describe "index" do
    test "lists all subnetss", %{conn: conn} do
      conn = get(conn, Routes.subnet_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Subnetss"
    end
  end

  describe "new subnet" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.subnet_path(conn, :new))
      assert html_response(conn, 200) =~ "New Subnet"
    end
  end

  describe "create subnet" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.subnet_path(conn, :create), subnet: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.subnet_path(conn, :show, id)

      conn = get(conn, Routes.subnet_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Subnet"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.subnet_path(conn, :create), subnet: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Subnet"
    end
  end

  describe "edit subnet" do
    setup [:create_subnet]

    test "renders form for editing chosen subnet", %{conn: conn, subnet: subnet} do
      conn = get(conn, Routes.subnet_path(conn, :edit, subnet))
      assert html_response(conn, 200) =~ "Edit Subnet"
    end
  end

  describe "update subnet" do
    setup [:create_subnet]

    test "redirects when data is valid", %{conn: conn, subnet: subnet} do
      conn = put(conn, Routes.subnet_path(conn, :update, subnet), subnet: @update_attrs)
      assert redirected_to(conn) == Routes.subnet_path(conn, :show, subnet)

      conn = get(conn, Routes.subnet_path(conn, :show, subnet))
      assert html_response(conn, 200) =~ "some updated cidr"
    end

    test "renders errors when data is invalid", %{conn: conn, subnet: subnet} do
      conn = put(conn, Routes.subnet_path(conn, :update, subnet), subnet: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Subnet"
    end
  end

  describe "delete subnet" do
    setup [:create_subnet]

    test "deletes chosen subnet", %{conn: conn, subnet: subnet} do
      conn = delete(conn, Routes.subnet_path(conn, :delete, subnet))
      assert redirected_to(conn) == Routes.subnet_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, Routes.subnet_path(conn, :show, subnet))
      end)
    end
  end

  defp create_subnet(_) do
    subnet = fixture(:subnet)
    {:ok, subnet: subnet}
  end
end