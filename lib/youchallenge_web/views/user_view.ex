defmodule YouchallengeWeb.UserView do
  use YouchallengeWeb, :view
  alias YouchallengeWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user_with_level.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      address: user.address,
      email: user.email
    }
  end

  def render("challenge_user.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      address: user.address,
      failed_challenges: user.failed_count,
      completed_challenges: user.completed_count,
      challenger_level: user.level,
      active_challenges: user.active_count,
      allowed_challenges: user.allowed_count
    }
  end

  def render("user_with_level.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      address: user.address,
      challenger_level: user.level
    }
  end

  def render("jwt.json", %{jwt: jwt}) do
    %{jwt: jwt}
  end
end
