# Wanderer Bot Starter

A minimal Elixir application that polls the Wanderer API once per minute and sends notifications for any new visible systems.

## Features

- **Periodic Polling:** Every 60 seconds the bot polls the Wanderer API for map systems.
- **New System Detection:** Compares current visible systems to previously seen systems and notifies about any new ones.
- **Simple & Extendable:** Minimal codebase designed for developers to easily add their own notification methods.

## Prerequisites

- **Elixir** (>= 1.12)
- **Erlang/OTP** (compatible version)
- [Finch](https://github.com/sneako/finch) (HTTP client)
- [Jason](https://github.com/michalmuskala/jason) (JSON parser)

## Setup

1. **Clone the repository:**

   `git clone https://github.com/guarzo/wanderer_bot_starter.git`  
   `cd wanderer_bot_starter`

2. **Configure Environment Variables:**

   Create a `.env` file or set environment variables in your shell:

   ```bash
   export WANDERER_API_TOKEN=your_api_token_here
   export WANDERER_MAP_SLUG=your_map_slug_here
   ```

3. **Fetch Dependencies:**

   `mix deps.get`

4. **Compile the Project:**

   `mix compile`

## Running the Bot

Run the application in interactive mode:

`iex -S mix`

Or run it without IEx to keep it running:

`mix run --no-halt`

The bot will start polling the Wanderer API and log notifications to the console when new visible systems are detected.

## How It Works

1. **Polling:** The `WandererNotifier.Poller` GenServer makes an HTTP GET request to the endpoint:
   ```
   GET /api/map/systems?slug=<map_slug>
   ```
   using your API token for authorization.

2. **Filtering:** It parses the JSON response and extracts system IDs that are currently visible.

3. **New System Detection:** It compares the current list of system IDs with those seen in previous polls using a `MapSet`. If any new IDs are found, it triggers a notification.

4. **Notification:** Currently, the notification is a simple console log. You can extend the `notify/1` function to integrate with other notification services (email, Slack, Discord, etc.).

## Extending the Bot

- **Custom Notifications:** Modify the `notify/1` function in `lib/wanderer_bot_starter/poller.ex` to change how notifications are delivered.
- **Configuration:** Adjust the polling interval by modifying the delay in `Process.send_after(self(), :poll, 60_000)`.
- **Multiple Maps:** To monitor multiple maps, you can start additional Poller processes with different API tokens and map slugs.

---

Happy coding and extend away!


