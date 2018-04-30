defmodule GoStopWeb.Router do
  use GoStopWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Bartender.Plug, GoStopWeb.Guardian
  end

  scope "/api" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: GoStopWeb.Schema

    forward "/", Absinthe.Plug,
      schema: GoStopWeb.Schema
  end
end
