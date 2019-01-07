defmodule Youchallenge.Validator do
  use GenServer

  import Ecto.{Changeset, Query}
  alias Youchallenge.Repo
  alias Youchallenge.Events.Challenge
  alias ContractWrappers.{ChallengeContract, Deployer}

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    Process.send(self(), :validate, [:noconnect])
    {:ok, state}
  end

  @impl true
  def handle_info(:validate, state) do
    case Repo.all(without_address()) do
      [] -> nil
      records -> confirm_addresses(records)
    end

    case Repo.all(not_expired_challenges()) do
      [] -> nil
      records -> expire_stale(records)
    end

    reschedule()
    {:noreply, state}
  end

  defp without_address() do
    from c in Challenge,
      where: not is_nil(c.tx_hash) and is_nil(c.address)
  end

  defp confirm_addresses(records) do
    records
    |> Enum.each(&verify_and_confirm/1)
  end

  defp verify_and_confirm(%Challenge{} = challenge) do
    case Deployer.transaction_receipt(challenge.tx_hash) do
      {:ok, _, address} ->
        change(challenge, %{
          address: address,
          expiration_date: set_expiration_date(challenge)
        })
        |> Repo.update()

      {:ok, nil} ->
        nil
    end
  end

  defp set_expiration_date(challenge) do
    %{days: days, hours: hours, minutes: minutes} = challenge

    DateTime.utc_now()
    |> DateTime.to_unix()
    |> extend_timestamp_date(days, hours, minutes)
    |> DateTime.from_unix()
    |> elem(1)
  end

  defp extend_timestamp_date(timestamp, days, hours, minutes) do
    case is_binary(days) do
      true ->
        timestamp + String.to_integer(days) * 24 * 60 * 60 + String.to_integer(hours) * 60 * 60 +
          String.to_integer(minutes) * 60

      _ ->
        timestamp + days * 24 * 60 * 60 + hours * 60 * 60 + minutes * 60
    end
  end

  defp not_expired_challenges() do
    from c in Challenge,
      where: c.finished == false,
      where: not is_nil(c.tx_hash) and not is_nil(c.address)
  end

  defp expire_stale(records) do
    records
    |> Enum.each(&verify_and_expire/1)
  end

  defp verify_and_expire(record) do
    expired = ChallengeContract.expired?(record.address)
    completed = ChallengeContract.completed?(record.address)

    case expired && !completed do
      true ->
        ChallengeContract.flush_balance(record.address)

        change(record, expired: true)
        |> Repo.update()

      _ ->
        nil
    end
  end

  defp reschedule() do
    Process.send_after(self(), :validate, 10000)
  end
end
