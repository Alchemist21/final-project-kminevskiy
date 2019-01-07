defmodule YouchallengeWeb.Router do
  use YouchallengeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug
  end

  scope "/api/v1", YouchallengeWeb do
    pipe_through :api

    resources "/challenges", ChallengeController, except: [:edit, :delete]
    post "/challenges/:id/accept", ChallengeController, :accept
    put "/challenges/:id/complete", ChallengeController, :complete
    put "/challenges/:id/finish", ChallengeController, :finish
  end
end
