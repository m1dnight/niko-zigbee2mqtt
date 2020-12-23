defmodule NikoConnector.Zigbee2Mqtt.Handler do
  use Tortoise.Handler
  require Logger

  ##############################################################################
  # Event Handlers MQTT

  def init(args) do
    {:ok, args}
  end

  def connection(status, state) do
    Logger.info("#{__MODULE__} Connection: #{inspect(status)}")
    {:ok, state}
  end

  def handle_message(["zigbee2mqtt", "bridge", "devices"], payload, state) do
    {:ok, devices} = Poison.decode(payload)

    # Subscribe to all Motion devices devices that have a friendly name in the form of Motion\d+
    next_actions =
      devices
      |> Enum.flat_map(fn d ->
        name = d["friendly_name"]

        if String.starts_with?(name, "Motion") do
          topic = Enum.join(["zigbee2mqtt", name], "/")
          [{:subscribe, topic, qos: 0, timeout: 5000}]
        else
          []
        end
      end)

    {:ok, state, next_actions}
  end

  def handle_message(["zigbee2mqtt", id = "Motion" <> rest], payload, state) do
    payload = Poison.decode!(payload)
    Logger.debug("#{__MODULE__} Motion#{rest} #{inspect(payload)}")

    # Publish event for application.
    PubSub.publish(:motion, %{:device => id, :payload => payload})

    {:ok, state}
  end

  def handle_message(topic, payload, state) do
    Logger.debug("#{__MODULE__} Unhandled Message: #{inspect(topic)} #{inspect(payload)}")
    {:ok, state}
  end

  def subscription(status, topic_filter, state) do
    Logger.info("#{__MODULE__} Subscription: #{inspect(status)} #{inspect(topic_filter)}")
    {:ok, state}
  end

  def terminate(reason, _state) do
    Logger.info("#{__MODULE__} Terminate: #{inspect(reason)}")
    :ok
  end
end
