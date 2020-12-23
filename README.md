# Niko

Connects a Niko Home Control installation to a Zigbee2MQTT installation.
I personally use it to use Aqara motion sensors to turn on lights in my Niko system.

# Run
You can either use the Docker container or run it straight from the console.
For development it's easier to just fill out the `.env` file and go from there.
To load the `.env` file execute `source <(sed 's/^/export /' < .env)` and then run the application with `iex -S mix`.

Initially the library will create a default configuration file which you can use as a starting point.
