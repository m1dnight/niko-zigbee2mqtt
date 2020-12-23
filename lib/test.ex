defmodule Test do
  def test() do
    payload = %{
      "Method" => "devices.control",
      "Params" => [
        %{
          "Devices" => [
            %{
              "Properties" => [%{"Status" => "On"}],
              "Uuid" => "f759b516-f34b-4fab-899f-40c698a391ba"
            }
          ]
        }
      ]
    }

    topic = "hobby/control/devices/cmd"
    Tortoise.publish(NikoConnector.Niko.Handler, topic, Poison.encode!(payload))
  end
end
