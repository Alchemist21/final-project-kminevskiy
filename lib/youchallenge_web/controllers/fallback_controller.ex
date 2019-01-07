defmodule YouchallengeWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use YouchallengeWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(YouchallengeWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(YouchallengeWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "Login error."})
  end

  def call(conn, {:error, :conflict}) do
    conn
    |> put_status(:conflict)
    |> json(%{error: "Contender is already working on a challenge. Please try again later."})
  end

  def call(conn, {:message, :confirming_challenger}) do
    conn
    |> put_status(:accepted)
    |> json(%{message: "Contender is being confirmed. Please try again in a bit."})
  end

  def call(conn, {:error, :expired_or_failed}) do
    conn
    |> put_status(:conflict)
    |> json(%{error: "Challenge has expired or already completed."})
  end

  def call(conn, {:error, :already_extended}) do
    conn
    |> put_status(:conflict)
    |> json(%{error: "Challenge has been already extended."})
  end

  def call(conn, {:message, :completed}) do
    conn
    |> put_status(:ok)
    |> json(%{message: "Challenge has been successfully completed."})
  end
end
