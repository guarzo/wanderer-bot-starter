# lib/wanderer_bot_starter/poller.ex
defmodule WandererBotStarter.Poller do
  moduledoc """
  A GenServer that polls the Wanderer API every minute and notifies on new visible systems.
  """
  use GenServer
  require Logger

  @api_url "https://wanderer.example.com/api/map/systems"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    token = Keyword.fetch!(opts, :api_token)
    slug  = Keyword.fetch!(opts, :map_slug)
    state = %{token: token, slug: slug, seen_ids: MapSet.new()}
    send(self(), :poll)
    {:ok, state}
  end

  @impl true
  def handle_info(:poll, %{token: token, slug: slug, seen_ids: seen} = state) do
    url = "#{@api_url}?slug=#{slug}"
    headers = [
      {"Authorization", "Bearer #{token}"},
      {"Accept", "application/json"}
    ]

    request = Finch.build(:get, url, headers)
    case Finch.request(request, WandererFinch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => systems}} ->
            current_ids = MapSet.new(for s <- systems, do: s["id"])
            new_ids = MapSet.difference(current_ids, seen)
            for system <- systems, system["id"] in new_ids do
              notify(system)
            end
            new_state = %{state | seen_ids: MapSet.union(seen, current_ids)}
            :ok = Logger.info("Poll complete. Seen systems count: #{MapSet.size(new_state.seen_ids)}")
            state = new_state

          {:error, err} ->
            Logger.error("JSON decode error: #{inspect(err)}")
        end

      {:ok, %Finch.Response{status: status}} ->
        Logger.error("Unexpected status code: #{status}")

      {:error, reason} ->
        Logger.error("HTTP request error: #{inspect(reason)}")
    end

    Process.send_after(self(), :poll, 60_000)
    {:noreply, state}
  end

  defp notify(system) do
    Logger.info("New system visible: #{system["name"]} (ID: #{system["id"]})")
    # Extend this function to send notifications (e.g., email, Slack, etc.)
  end
end

