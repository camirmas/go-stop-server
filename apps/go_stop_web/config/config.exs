# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :go_stop_web,
  namespace: GoStopWeb,
  ecto_repos: [GoStop.Repo]

# Configures the endpoint
config :go_stop_web, GoStopWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/rjaX4ZiMczLHWjl13ILfE2fE431Pyqa/QrGrT2TojxufrjuIw2bwiisxwwcs0V1",
  render_errors: [view: GoStopWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: GoStopWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Guardian Authentication
config :go_stop_web, GoStopWeb.Guardian,
  issuer: "go_stop_web",
  secret_key: "ReewDCP4r3BgK5nVOQCbLu1+YG/OGkfwIX5Z1wFNy1JiDTZepR5FBXnSRCH3EhxB"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :go_stop_web, :generators,
  context_app: :go_stop

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
