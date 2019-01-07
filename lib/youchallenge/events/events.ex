defmodule Youchallenge.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.{Changeset, Query}, warn: false
  alias Youchallenge.Repo

  alias __MODULE__.Challenge
  alias ContractWrappers.{ChallengerAccounts, ChallengeContract}

  @doc """
  Returns the list of challenges.

  ## Examples

      iex> list_challenges()
      [%Challenge{}, ...]

  """
  def list_challenges() do
    Repo.all(
      from c in Challenge,
        # where: not is_nil(c.address),
        order_by: [desc: c.inserted_at]
    )
  end

  @doc """
  Gets a single challenge.

  Raises `Ecto.NoResultsError` if the Challenge does not exist.

  ## Examples

      iex> get_challenge!(123)
      %Challenge{}

      iex> get_challenge!(456)
      ** (Ecto.NoResultsError)

  """
  def get_challenge!(id) do
    Repo.get!(Challenge, id)
  end

  def deploy_contract(%Challenge{
        challenger: challenger,
        contender: contender,
        days: days,
        hours: hours,
        minutes: minutes,
        description: description
      }) do
    ContractWrappers.Deployer.deploy_challenge_contract(%{
      challenger: challenger,
      contender: contender,
      days: days,
      hours: hours,
      minutes: minutes,
      description: description
    })
  end

  def update_with_tx(%Challenge{} = challenge, tx_hash) when is_binary(tx_hash) do
    new_expiration_date =
      DateTime.utc_now()
      |> DateTime.to_unix()
      |> extend_timestamp_date(challenge.days, challenge.hours, challenge.minutes)
      |> DateTime.from_unix()
      |> elem(1)

    change(challenge, %{tx_hash: tx_hash, accepted: true, expiration_date: new_expiration_date})
    |> Repo.update()
  end

  def get_challenge_with_contender!(id, contender) do
    Repo.one!(
      from c in Challenge,
        where: c.id == ^id,
        where: c.contender == ^contender
    )
  end

  def get_challenge_with_challenger(id, challenger) do
    Repo.one(
      from c in Challenge,
        where: c.id == ^id,
        where: c.challenger == ^challenger
    )
  end

  def challenge_extended?(address) do
    ChallengeContract.extended?(address)
  end

  def force_close_challenge(challenge_address, contender_address) do
    ChallengeContract.flush_balance(challenge_address)
    ChallengerAccounts.update_challenge_status(contender_address, false)
    {:error, :expired_or_failed}
  end

  def complete_challenge(%Challenge{} = challenge) do
    change(challenge, finished: true)
    |> Repo.update()
  end

  def finish_challenge(%Challenge{} = challenge) do
    change(challenge, confirmed: true)
    |> Repo.update()
  end

  def extend_challenge(challenge, days, hours, minutes) do
    adjusted_date =
      ChallengeContract.expiration_date(challenge.address)
      |> DateTime.from_iso8601()
      |> elem(1)
      |> DateTime.to_unix()
      |> extend_timestamp_date(days, hours, minutes)
      |> DateTime.from_unix()
      |> elem(1)

    change(challenge, expiration_date: adjusted_date)
    |> Repo.update()
  end

  defp extend_timestamp_date(timestamp, days, hours, minutes) do
    timestamp + days * 24 * 60 * 60 + hours * 60 * 60 + minutes * 60
  end

  def get_unconfirmed_challenge(id, address) do
    Repo.one!(
      from c in Challenge,
        where: c.id == ^id,
        where: c.contender == ^address
    )
  end

  @doc """
  Creates a challenge.

  ## Examples

      iex> create_challenge(%{field: value})
      {:ok, %Challenge{}}

      iex> create_challenge(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_challenge(attrs \\ %{}) do
    %Challenge{}
    |> Challenge.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a challenge.

  ## Examples

      iex> update_challenge(challenge, %{field: new_value})
      {:ok, %Challenge{}}

      iex> update_challenge(challenge, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_challenge(%Challenge{} = challenge, attrs) do
    challenge
    |> Challenge.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Challenge.

  ## Examples

      iex> delete_challenge(challenge)
      {:ok, %Challenge{}}

      iex> delete_challenge(challenge)
      {:error, %Ecto.Changeset{}}

  """
  def delete_challenge(%Challenge{} = challenge) do
    Repo.delete(challenge)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking challenge changes.

  ## Examples

      iex> change_challenge(challenge)
      %Ecto.Changeset{source: %Challenge{}}

  """
  def change_challenge(%Challenge{} = challenge) do
    Challenge.changeset(challenge, %{})
  end
end
