defmodule Rules.Lights do
  defmodule Rules.Lights.State do
    defstruct next_check: nil
  end

  @moduledoc """
  MAnages events that are supposed to trigger lights.
  """
  use GenServer
  require Logger
  alias NikoConnector.{Config, Control}

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts \\ %{}) do
    PubSub.subscribe(self(), :motion)
    {:ok, %{next_check: nil, on: %{}}}
  end

  ##############################################################################
  # Callbacks

  def handle_info(:check, state) do
    # Calculate which devices need to be turned off.
    # [%{"id" => "0x842e14fffe7832d7", "server" => "zigbee2mqtt"}]
    to_turn_off =
      state.on
      |> Enum.filter(fn {device, on_since} ->
        on_for = DateTime.diff(now(), on_since)
        off_after = Config.device_timeout(device)
        on_for >= off_after
      end)
      |> Enum.map(fn {device, _} -> device end)

    # Turn off the devices.
    to_turn_off
    |> Enum.map(&Control.turn_off/1)

    # Remove the devices from the state as on.
    # %{%{"id" => "..", "server" => ".."} => ~U[2021-02-23 14:08:45.507193Z]}
    still_on =
      state.on
      |> Enum.filter(fn {k, _v} -> not Enum.member?(to_turn_off, k) end)
      |> Enum.into(%{})

    # If we turned device on, check to turn them off in a minute.
    if Enum.count(still_on) > 0 do
      Process.send_after(self(), :check, 30 * 1000)
    end

    # Remember remaining devices.
    new_state = %{state | on: still_on}

    {:noreply, new_state}
  end

  def handle_info(%{device: sensor, payload: _p = %{"occupancy" => true}}, state) do
    Logger.info("#{sensor} detected occupancy.")
    # Calculate which devices to turn on. Example:
    # [%{"id" => "0x842e14fffe7832d7", "server" => "zigbee2mqtt"}]
    targets =
      Config.get_config()
      |> Map.get("targets")
      |> Map.get(sensor, [])

    # Filter out devices that are already on.
    to_turn_on = Enum.filter(targets, &(not Map.has_key?(state.on, &1)))

    # Find the devices that need to be updated (i.e., they are on, but there is still movement).
    already_on = Enum.filter(targets, &(Map.has_key?(state.on, &1)))

    # Turn on the devices.
    to_turn_on
    |> Enum.map(&Control.turn_on/1)

    # Mark devices as turned on just now.
    turned_on =
      to_turn_on
      |> Enum.map(&{&1, now()})
      |> Enum.into(state.on)

    # All the devices that were on need to have an updated timestamp.
    updated =
      already_on
      |> Enum.map(fn d -> Logger.info "Pushing off-time for #{inspect d}" ; d end)
      |> Enum.map(&{&1, now()})
      |> Enum.into(turned_on)

    # If we turned device on, check to turn them off in a minute.
    if Enum.count(to_turn_on) > 0 do
      Logger.debug "Scheduling check after motion detection."
      Process.send_after(self(), :check, 30 * 1000)
    end

    # Store the devices we turned on.
    new_state = %{state | on: updated}

    {:noreply, new_state}
  end

  def handle_info(_m, state) do
    # Logger.debug("Info #{inspect(m)} with state #{inspect(state)}")
    {:noreply, state}
  end

  ##############################################################################
  # Callbacks

  defp now() do
    DateTime.now!("Etc/UTC")
  end
end
