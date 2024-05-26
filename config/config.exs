# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :listen_list,
  ecto_repos: [ListenList.Repo],
  generators: [timestamp_type: :utc_datetime_usec]

# Configures the endpoint
config :listen_list, ListenListWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ListenListWeb.ErrorHTML, json: ListenListWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ListenList.PubSub,
  live_view: [signing_salt: "nCTahuQZ"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :listen_list, ListenList.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  listen_list: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  listen_list: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :file, :module, :function, :line]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :listen_list, ListenList.Scheduler,
  # Don't run the job if it's already running
  overlap: false,
  jobs: [
    send_weekly_releases_email: [
      # Send weekly email every Saturday at 19:10 UTC
      # We send at 10 minutes past so we don't run at the same time as the import job
      schedule: "10 19 * * 6",
      task: {ListenList.Jobs.WeeklyEmailJob, :run, []}
    ],
    import_releases_friday_to_saturday: [
      # Import every 30 minutes on Thursdays, Fridays, and Saturdays
      # Most new music is released late Thursday / early Friday UTC time.
      # We also want to keep the data fresh on Saturday.
      schedule: "*/30 * * * 4-6",
      task: {ListenList.Jobs.ImportReleasesJob, :run, []}
    ],
    import_releases_rest_of_week: [
      # The rest of the week, we import every 2 hours
      # There's not many new releases, but we keep the reddit data fairly fresh
      schedule: "0 */2 * * 0-3",
      task: {ListenList.Jobs.ImportReleasesJob, :run, []}
    ]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
