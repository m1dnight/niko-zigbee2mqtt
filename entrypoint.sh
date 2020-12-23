#!/bin/bash
# docker entrypoint script.
bin="/app/bin/niko_connector"

# Setup the database.
# start the elixir application
exec "$bin" "start" 