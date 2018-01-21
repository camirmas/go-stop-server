defmodule GoStop.Application do
  @moduledoc """
  The GoStop Application Service.

  The go_stop system business domain lives in this application.

  Exposes API to clients such as the `GoStopWeb` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      supervisor(GoStop.Repo, []),
    ], strategy: :one_for_one, name: GoStop.Supervisor)
  end
end
