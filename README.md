# Listen List 🎸🎧

[listenlist.app](https://listenist.app)

An app for discovering new music from [reddit.com/r/indieheads](https://reddit.com/r/indieheads)

Built with Elixir, Phoenix and PostgreSQL

## Development

Install required dependencies for Phoenix first, via [this guide](https://hexdocs.pm/phoenix/installation.html)

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