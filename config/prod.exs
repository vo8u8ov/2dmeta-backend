import Config

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Backend.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
# ここから下を追加 👇
config :backend, BackendWeb.Endpoint,
  url: [host: "meta-2d.gigalixirapp.com", port: 443],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true
