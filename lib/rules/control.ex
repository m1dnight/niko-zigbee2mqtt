defmodule NikoConnector.Control do
  require Logger

  def turn_off(%{"server" => "niko", "id" => id}), do: toggle_niko(id, :off)

  def turn_off(%{"server" => "zigbee2mqtt", "id" => id}), do: toggle_zigbee2mqtt(id, :off)

  def turn_on(%{"server" => "niko", "id" => id}), do: toggle_niko(id, :on)

  def turn_on(%{"server" => "zigbee2mqtt", "id" => id}), do: toggle_zigbee2mqtt(id, :on)

  defp toggle_niko(id, state) do
    # Status should be "On" or "Off"
    status = if state == :on, do: "On", else: "Off"
    Logger.info("Turning #{status} #{inspect(id)} in Niko")

    payload = %{
      "Method" => "devices.control",
      "Params" => [
        %{
          "Devices" => [
            %{
              "Properties" => [%{"Status" => status}],
              "Uuid" => id
            }
          ]
        }
      ]
    }

    topic = "hobby/control/devices/cmd"
    Tortoise.publish(NikoConnector.Niko.Handler, topic, Poison.encode!(payload))
  end

  defp toggle_zigbee2mqtt(id, state) do
    # Status should be "ON" or "OFF"
    status = if state == :on, do: "ON", else: "OFF"
    Logger.info("Turning #{status} #{inspect(id)} in Zigbee2mqtt")

    payload = %{"state" => status}

    topic = "zigbee2mqtt/#{id}/set"
    Tortoise.publish(NikoConnector.Zigbee2Mqtt.Handler, topic, Poison.encode!(payload))
  end
end
