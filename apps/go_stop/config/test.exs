use Mix.Config

# Configure your database
config :go_stop, GoStop.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "go_stop_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
