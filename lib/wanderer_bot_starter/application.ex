# lib/wanderer_bot_starter/application.ex
defmodule WandererBotStarter.Application do
  @moduledoc """
  The WandererBotStarter Application.
  """
  use Application

  def start(_type, _args) do
    children = [
      # Start Finch HTTP client
      {Finch, name: WandererFinch},
      # Start the Poller
      {WandererNotifier.Poller, 
       api_token: Application.fetch_env!(:wanderer_notifier, :api_token),
       map_slug:  Application.fetch_env!(:wanderer_notifier, :map_slug)}
    ]

    opts = [strategy: :one_for_one, name: WandererNotifier.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

