defmodule Youchallenge.Events.Challenge do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "challenges" do
    field :description, :string
    field :address, :string
    field :days, :integer
    field :hours, :integer
    field :minutes, :integer
    field :tx_hash, :string
    field :expired, :boolean
    field :accepted, :boolean
    field :finished, :boolean
    field :challenger, :string
    field :contender, :string
    field :expiration_date, :utc_datetime
    field :confirmed, :boolean

    timestamps()
  end

  @doc false
  def changeset(challenge, attrs) do
    challenge
    |> cast(attrs, [
      :description,
      :days,
      :hours,
      :minutes,
      :tx_hash,
      :challenger,
      :contender,
      :expiration_date,
      :finished,
      :expired,
      :accepted
    ])
    |> validate_required([:description, :days, :hours, :minutes, :challenger, :contender])
    |> validate_length(:description, min: 4)
    |> validate_positive_date(:days)
    |> normalize_expiration_date(attrs)
  end

  defp normalize_expiration_date(changeset, %{
         "days" => days,
         "hours" => hours,
         "minutes" => minutes
       }) do
    expiration_date =
      DateTime.utc_now()
      |> DateTime.to_unix()
      |> extend_timestamp_date(days, hours, minutes)
      |> DateTime.from_unix()
      |> elem(1)

    change(changeset, expiration_date: expiration_date)
  end

  defp extend_timestamp_date(timestamp, days, hours, minutes) do
    timestamp + String.to_integer(days) * 24 * 60 * 60 + String.to_integer(hours) * 60 * 60 +
      String.to_integer(minutes) * 60
  end

  defp validate_positive_date(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, value ->
      case value > 0 or get_field(changeset, :minutes) > 0 or get_field(changeset, :hours) > 0 do
        true -> []
        false -> [{field, options[:message] || "Date params should be positive."}]
      end
    end)
  end
end
