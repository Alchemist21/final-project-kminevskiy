defmodule Youchallenge.EventsTest do
  use Youchallenge.DataCase

  alias Youchallenge.Events

  describe "challenges" do
    alias Youchallenge.Events.Challenge

    @valid_attrs %{address: "some address", finished: true, name: "some name"}
    @update_attrs %{address: "some updated address", finished: false, name: "some updated name"}
    @invalid_attrs %{address: nil, finished: nil, name: nil}

    def challenge_fixture(attrs \\ %{}) do
      {:ok, challenge} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Events.create_challenge()

      challenge
    end

    test "list_challenges/0 returns all challenges" do
      challenge = challenge_fixture()
      assert Events.list_challenges() == [challenge]
    end

    test "get_challenge!/1 returns the challenge with given id" do
      challenge = challenge_fixture()
      assert Events.get_challenge!(challenge.id) == challenge
    end

    test "create_challenge/1 with valid data creates a challenge" do
      assert {:ok, %Challenge{} = challenge} = Events.create_challenge(@valid_attrs)
      assert challenge.address == "some address"
      assert challenge.finished == true
      assert challenge.name == "some name"
    end

    test "create_challenge/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_challenge(@invalid_attrs)
    end

    test "update_challenge/2 with valid data updates the challenge" do
      challenge = challenge_fixture()
      assert {:ok, %Challenge{} = challenge} = Events.update_challenge(challenge, @update_attrs)
      assert challenge.address == "some updated address"
      assert challenge.finished == false
      assert challenge.name == "some updated name"
    end

    test "update_challenge/2 with invalid data returns error changeset" do
      challenge = challenge_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_challenge(challenge, @invalid_attrs)
      assert challenge == Events.get_challenge!(challenge.id)
    end

    test "delete_challenge/1 deletes the challenge" do
      challenge = challenge_fixture()
      assert {:ok, %Challenge{}} = Events.delete_challenge(challenge)
      assert_raise Ecto.NoResultsError, fn -> Events.get_challenge!(challenge.id) end
    end

    test "change_challenge/1 returns a challenge changeset" do
      challenge = challenge_fixture()
      assert %Ecto.Changeset{} = Events.change_challenge(challenge)
    end
  end
end
