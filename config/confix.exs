# config/onfig.exs
import Config

config :wanderer_notifier,
  api_token: System.get_env("WANDERER_API_TOKEN") || "your_api_token_here",
  map_slug: System.get_env("WANDERER_MAP_SLUG") || "your_map_slug_here"

config :logger, level: :info
c
