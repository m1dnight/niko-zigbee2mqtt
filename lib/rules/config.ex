defmodule NikoConnector.Config do
  require Logger

  def example_config do
    ~s(
      {
        "timeouts": {
            "Motion3": 30,
            "Motion2": 10,
            "Motion1": 5
        },
        "targets": {
            "Motion3": [
                {
                    "server": "niko",
                    "id": "6290409c-4023-4e02-ac38-1e72de378e99"
                }
            ],
            "Motion2": [
                {
                    "server": "niko",
                    "id": "7cb19b84-3c3c-4ecc-b4b2-10b9b282e7d0"
                },
                {
                    "server": "niko",
                    "id": "7bf33749-c992-42b5-81af-1e8ec3a44e97"
                }
            ],
            "Motion1": [
                {
                    "server": "niko",
                    "id": "f759b516-f34b-4fab-899f-40c698a391ba"
                },
                {
                    "server": "zigbee2mqtt",
                    "id": "0x842e14fffe7832d7"
                }
            ]
        }
    }
    )
  end

  def get_config() do
    config_path = System.get_env("CONFIG") || Path.join(File.cwd!(), "config.json")

    if File.exists?(config_path) do
      File.read!(config_path)
      |> Poison.decode!()
    else
      Logger.debug("No config found, creating example config")
      File.write!(config_path, example_config())
      example_config() |> Poison.decode!()
    end
  end

  def sensor_for_device(%{"id" => id}) do
    config = get_config()

    res =
      config["targets"]
      |> Enum.filter(fn {_k, targets} ->
        targets
        |> Enum.map(fn %{"id" => id} -> id end)
        |> Enum.member?(id)
      end)

    case res do
      [{sensor, _targets}] -> sensor
      _ -> nil
    end
  end

  def device_timeout(device = %{"id" => _}) do
    config = get_config()
    sensor = sensor_for_device(device)

    config["timeouts"]
    |> Map.get(sensor, nil)
  end

end
