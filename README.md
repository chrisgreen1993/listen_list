# Listen List 🎸🎧

[listenlist.app](https://listenist.app)

An app for discovering new music from [reddit.com/r/indieheads](https://reddit.com/r/indieheads)

Built with Elixir, Phoenix and PostgreSQL

## Development

### Using devbox

Install [devbox](https://www.jetify.com/devbox)

```
git clone https://github.com/chrisgreen1993/listen_list.git
cd listen_list

# Install elixir, postgres etc
devbox install
# enter the devbox
devbox shell

# Set your env vars in .env.dev
cp .env.template .env.dev
source .env.dev

# Install deps, setup DB etc
mix setup

# Run the server (localhost:4000)
mix phx.server

# Run tests
mix test

# Import latest data from api
mix import_releases_from_api

# import all historical data from arctic shift dump file
# https://arctic-shift.photon-reddit.com/download-tool 
# (r/indieheads - submissions only)
mix import_releases_from_file [filepath]
```

### Manual

Follow [this guide](https://hexdocs.pm/phoenix/installation.html) to install dependencies

```
git clone https://github.com/chrisgreen1993/listen_list.git
cd listen_list

# Set your env vars in .env.dev
cp .env.template .env.dev
source .env.dev

# Install deps, setup DB etc
mix setup

# Run the server (localhost:4000)
mix phx.server

# Run tests
mix test

# Import latest data from api
mix import_releases_from_api

# import all historical data from arctic shift dump file
# https://arctic-shift.photon-reddit.com/download-tool 
# (r/indieheads - submissions only)
mix import_releases_from_file [filepath]
```