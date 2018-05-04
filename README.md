# GoStop [![Build Status](https://travis-ci.org/camirmas/go-stop-server.svg?branch=master)](https://travis-ci.org/camirmas/go-stop-server)

:white_circle: Server implementation of the board game Go

[Client App](https://github.com/ianwessen/go-stop-client)

[Live GraphiQL Server](https://go-stop.live/api/graphiql)

### Getting Started

```
git clone git@github.com:camirmas/go-stop-server.git
cd go-stop-server

# get dependencies
mix deps.get

# set up DB
cd apps/go_stop
mix ecto.setup

# run server
cd ../apps/go_stop_web
mix phx.server

# visit http://localhost:4000/api/graphiql
```
