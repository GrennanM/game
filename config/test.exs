import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :game, GameWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "6UAJTXosn+St0WcleImDBuZ/AB7EWdfr/fCtiTAJMer632k9hY1ki3eFYoS5M8kE",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
