defmodule YouchallengeWeb.ChallengeController do
  use YouchallengeWeb, :controller

  alias Youchallenge.Events
  alias Youchallenge.Events.Challenge
  alias ContractWrappers.ChallengeContract

  action_fallback YouchallengeWeb.FallbackController

  def index(conn, _params) do
    challenges = Events.list_challenges()
    render(conn, "index.json", challenges: challenges)
  end

  def create(conn, %{"challenge" => challenge_params}) do
    with {:ok, %Challenge{} = challenge} <- Events.create_challenge(challenge_params) do
      conn |> render("show.json", challenge: challenge)
    end
  end

  def accept(conn, %{"id" => id, "contender" => contender}) do
    with challenge <- Events.get_unconfirmed_challenge(id, contender),
         tx_hash <- Events.deploy_contract(challenge),
         {:ok, updated_challenge} <- Events.update_with_tx(challenge, tx_hash) do
      render(conn, "show.json", challenge: updated_challenge)
    end
  end

  def show(conn, %{"id" => id}) do
    challenge = Events.get_challenge!(id)
    render(conn, "show.json", challenge: challenge)
  end

  def complete(conn, %{"id" => id, "contender" => contender}) do
    {:ok, challenge} =
      Events.get_challenge_with_contender!(id, contender)
      |> Events.complete_challenge()

    render(conn, "show.json", challenge: challenge)
  end

  def finish(conn, %{"id" => id, "challenger" => challenger}) do
    {:ok, challenge} =
      Events.get_challenge_with_challenger(id, challenger)
      |> Events.finish_challenge()

    ChallengeContract.complete(challenge.address)
    render(conn, "show.json", challenge: challenge)
  end
end
