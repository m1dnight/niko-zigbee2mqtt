defmodule NikoConnector.Supervisor do
  use Supervisor

  def start_link(_opts \\ []) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    niko_host = System.get_env("NIKO_IP") || raise "NIKO_IP not set!"
    {niko_port, _} = System.get_env("NIKO_PORT") |> Integer.parse() || raise "NIKO_PORT not set!"
    niko_password = System.get_env("NIKO_PASSWORD") || raise "NIKO_PASSWORD not set!"
    niko_username = System.get_env("NIKO_USERNAME") || raise "NIKO_USERNAME not set!"

    zigbee_host = System.get_env("ZIGBEE_IP") || raise "ZIGBEE_IP not set!"

    {zigbee_port, _} =
      System.get_env("ZIGBEE_PORT") |> Integer.parse() || raise "ZIGBEE_PORT not set!"

    children = [
      # Connection to local zigbee2mqtt instance.
      Tortoise.Connection.child_spec(
        name: :zigbee2mqtt,
        client_id: NikoConnector.Zigbee2Mqtt.Handler,
        handler: {NikoConnector.Zigbee2Mqtt.Handler, []},
        server: {Tortoise.Transport.Tcp, host: zigbee_host, port: zigbee_port},
        subscriptions: ["zigbee2mqtt/bridge/devices"]
      ),
      # Connection to the local Niko Home Control instance.
      Tortoise.Connection.child_spec(
        name: :niko,
        client_id: NikoConnector.Niko.Handler,
        password: niko_password,
        user_name: niko_username,
        handler: {NikoConnector.Niko.Handler, []},
        server: {Tortoise.Transport.SSL, verify: :verify_none, host: niko_host, port: niko_port},
        subscriptions: ["#"]
      )
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
