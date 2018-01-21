defmodule GoStopWeb.Router do
  use GoStopWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", GoStopWeb do
    pipe_through :api
  end
end
