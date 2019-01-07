defmodule YouchallengeWeb.ChallengeControllerTest do
  use YouchallengeWeb.ConnCase

  alias Youchallenge.Events
  alias Youchallenge.Events.Challenge

  @create_attrs %{
    address: "some address",
    finished: true,
    name: "some name"
  }
  @update_attrs %{
    address: "some updated address",
    finished: false,
    name: "some updated name"
  }
  @invalid_attrs %{address: nil, finished: nil, name: nil}

  def fixture(:challenge) do
    {:ok, challenge} = Events.create_challenge(@create_attrs)
    challenge
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all challenges", %{conn: conn} do
      conn = get(conn, Routes.challenge_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create challenge" do
    test "renders challenge when data is valid", %{conn: conn} do
      conn = post(conn, Routes.challenge_path(conn, :create), challenge: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.challenge_path(conn, :show, id))

      assert %{
               "id" => id,
               "address" => "some address",
               "finished" => true,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.challenge_path(conn, :create), challenge: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update challenge" do
    setup [:create_challenge]

    test "renders challenge when data is valid", %{conn: conn, challenge: %Challenge{id: id} = challenge} do
      conn = put(conn, Routes.challenge_path(conn, :update, challenge), challenge: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.challenge_path(conn, :show, id))

      assert %{
               "id" => id,
               "address" => "some updated address",
               "finished" => false,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, challenge: challenge} do
      conn = put(conn, Routes.challenge_path(conn, :update, challenge), challenge: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete challenge" do
    setup [:create_challenge]

    test "deletes chosen challenge", %{conn: conn, challenge: challenge} do
      conn = delete(conn, Routes.challenge_path(conn, :delete, challenge))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.challenge_path(conn, :show, challenge))
      end
    end
  end

  defp create_challenge(_) do
    challenge = fixture(:challenge)
    {:ok, challenge: challenge}
  end
end
