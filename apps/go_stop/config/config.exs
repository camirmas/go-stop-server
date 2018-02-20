use Mix.Config

config :go_stop, ecto_repos: [GoStop.Repo]

import_config "#{Mix.env()}.exs"
