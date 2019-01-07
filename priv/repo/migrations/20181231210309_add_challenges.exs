defmodule Youchallenge.Repo.Migrations.AddChallenges do
  use Ecto.Migration

  def change do
    create table(:challenges, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :text
      add :address, :string
      add :challenger, :string
      add :contender, :string
      add :tx_hash, :string
      add :days, :integer
      add :hours, :integer
      add :minutes, :integer
      add :expiration_date, :utc_datetime
      add :expired, :boolean, default: false
      add :accepted, :boolean, default: false
      add :finished, :boolean, default: false
      add :confirmed, :boolean, default: false

      timestamps()
    end

    create index(:challenges, [:challenger])
    create index(:challenges, [:contender])
  end
end
