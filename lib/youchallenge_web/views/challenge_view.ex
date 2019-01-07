defmodule YouchallengeWeb.ChallengeView do
  use YouchallengeWeb, :view
  alias YouchallengeWeb.ChallengeView

  def render("index.json", %{challenges: challenges}) do
    %{data: render_many(challenges, ChallengeView, "challenge.json")}
  end

  def render("show.json", %{challenge: challenge}) do
    %{data: render_one(challenge, ChallengeView, "challenge.json")}
  end

  def render("challenge.json", %{challenge: challenge}) do
    %{
      id: challenge.id,
      description: challenge.description,
      address: challenge.address,
      expirationDate: challenge.expiration_date,
      days: challenge.days,
      hours: challenge.hours,
      minutes: challenge.minutes,
      accepted: challenge.accepted,
      expired: challenge.expired,
      finished: challenge.finished,
      confirmed: challenge.confirmed,
      challenger: challenge.challenger,
      contender: challenge.contender
    }
  end
end
