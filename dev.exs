#######################################
# Development Server for LiveObserver
#
# Usage:
#
# $ iex -S mix dev [flags]
#######################################
Mix.ensure_application!(:os_mon)
Logger.configure(level: :debug)

# argv = System.argv()
#
# {opts, _, _} =
#   OptionParser.parse(argv, strict: [mysql: :boolean, postgres: :boolean, sqlite: :boolean])
#
# %{mysql: mysql?, postgres: postgres?, sqlite: sqlite?} =
#   Map.merge(%{mysql: false, postgres: false, sqlite: false}, Map.new(opts))

# Configures the endpoint
Application.put_env(:phoenix_live_observer, DemoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Hu4qQN3iKzTV4fJxhorPQlA/osH9fAMtbtjVS58PFgfw3ja5Z18Q/WSNR9wP4OfW",
  live_view: [signing_salt: "hMegieSe"],
  http: [port: System.get_env("PORT") || 4000],
  debug_errors: true,
  check_origin: false,
  pubsub_server: Demo.PubSub,
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ],
  live_reload: [
    patterns: [
      ~r"dist/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"assets/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/.*(ex)$"
    ]
  ]
)

defmodule DemoWeb.PageController do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, :index) do
    content(conn, """
    <h2>LiveObserver Dev</h2>
    <a href="/observer">Open Observer</a>
    """)
  end

  def call(conn, :hello) do
    name = Map.get(conn.params, "name", "friend")
    content(conn, "<p>Hello, #{name}!</p>")
  end

  def call(conn, :get) do
    json(conn, %{
      args: conn.params,
      headers: Map.new(conn.req_headers),
      url: Phoenix.Controller.current_url(conn)
    })
  end

  defp content(conn, content) do
    conn
    |> put_resp_header("content-type", "text/html")
    |> send_resp(200, "<!doctype html><html><body>#{content}</body></html>")
  end

  defp json(conn, data) do
    body = Phoenix.json_library().encode_to_iodata!(data, pretty: true)

    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json; charset=utf-8")
    |> Plug.Conn.send_resp(200, body)
  end
end

defmodule DemoWeb.Router do
  use Phoenix.Router
  import LiveObserver.Router

  pipeline :browser do
    plug(:fetch_session)
    plug(:protect_from_forgery)
    plug(:put_csp)
  end

  scope "/" do
    pipe_through(:browser)
    get("/", DemoWeb.PageController, :index)
    get("/get", DemoWeb.PageController, :get)
    get("/hello", DemoWeb.PageController, :hello)
    get("/hello/:name", DemoWeb.PageController, :hello)

    live_observer("/observer",
      env_keys: ["USER", "ROOTDIR"],
      # metrics: DemoWeb.Telemetry,
      # metrics_history: {DemoWeb.History, :data, []},
      allow_destructive_actions: true,
      # home_app: {"Erlang's stdlib", :stdlib},
      # additional_pages: [
      #   components: DemoWeb.GraphShowcasePage
      # ],
      csp_nonce_assign_key: %{
        img: :img_csp_nonce,
        style: :style_csp_nonce,
        script: :script_csp_nonce
      }
      # ecto_psql_extras_options: [
      #   long_running_queries: [threshold: "200 milliseconds"]
      # ],
      # ecto_mysql_extras_options: [
      #   long_running_queries: [threshold: 200]
      # ]
    )
  end

  def put_csp(conn, _opts) do
    [img_nonce, style_nonce, script_nonce] =
      for _i <- 1..3, do: 16 |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)

    conn
    |> assign(:img_csp_nonce, img_nonce)
    |> assign(:style_csp_nonce, style_nonce)
    |> assign(:script_csp_nonce, script_nonce)

    # |> put_resp_header(
    #   "content-security-policy",
    #   "default-src; script-src 'nonce-#{script_nonce}'; style-src-elem 'nonce-#{style_nonce}'; " <>
    #     "img-src 'nonce-#{img_nonce}' data: ; font-src data: ; connect-src 'self'; frame-src 'self' ;"
    # )
  end
end

defmodule DemoWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :phoenix_live_observer

  @session_options [
    store: :cookie,
    key: "_live_view_key",
    signing_salt: "/VEDsdfsffMnp5",
    same_site: "Lax"
  ]

  socket("/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]])
  socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)

  plug(Phoenix.LiveReloader)
  plug(Phoenix.CodeReloader)

  # plug Phoenix.LiveDashboard.RequestLogger,
  #   param_key: "request_logger",
  #   cookie_key: "request_logger"

  plug(Plug.Session, @session_options)

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])
  plug(DemoWeb.Router)
end

Application.ensure_all_started(:os_mon)
Application.put_env(:phoenix, :serve_endpoints, true)

Task.async(fn ->
  children = []
  # children = if postgres?, do: [Demo.Postgres | children], else: children
  # children = if mysql?, do: [Demo.MyXQL | children], else: children
  # children = if sqlite?, do: [Demo.SQLite | children], else: children

  children =
    children ++
      [
        {Phoenix.PubSub, [name: Demo.PubSub, adapter: Phoenix.PubSub.PG2]},
        DemoWeb.Endpoint
      ]

  {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
  Process.sleep(:infinity)
end)
|> Task.await(:infinity)
