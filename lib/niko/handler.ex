defmodule NikoConnector.Niko.Handler do
  use Tortoise.Handler
  require Logger

  ##############################################################################
  # Event Handlers MQTT
  def init(args) do
    {:ok, args}
  end

  def connection(status, state) do
    Logger.info("#{__MODULE__} Connection: #{inspect(status)}")

    # Request a list of all devices.
    topic = "hobby/control/devices/cmd"
    payload = %{Method: "devices.list", Params: [%{"Devices" => [%{Model: "light"}]}]}
    Tortoise.publish(__MODULE__, topic, Poison.encode!(payload))

    {:ok, state}
  end

  def handle_message(["hobby", "control", "devices", "rsp"], payload, state) do
    %{"Params" => [%{"Devices" => devices}]} = Poison.decode!(payload)

    # Print out the discovered devices on the console.
    devices
    |> Enum.map(fn d ->
      Logger.debug("#{__MODULE__} Discovered #{d["Name"]} (#{d["Model"]} #{d["Uuid"]}) ")
    end)

    {:ok, state}
  end

  def handle_message(topic, payload, state) do
    payload = Poison.decode!(payload)
    Logger.debug("#{inspect(self())} Unhandled Message: #{inspect(topic)} #{inspect(payload)}")
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
