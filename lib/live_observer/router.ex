defmodule LiveObserver.Router do
  defmacro live_observer(path, opts \\ []) do
    opts =
      if Macro.quoted_literal?(opts) do
        Macro.prewalk(opts, &expand_alias(&1, __CALLER__))
      else
        opts
      end

    scope =
      quote bind_quoted: binding() do
        scope path, alias: false, as: false do
          {session_name, session_opts, route_opts} =
            LiveObserver.Router.__options__(opts)

          import Phoenix.Router, only: [get: 4]
          import Phoenix.LiveView.Router, only: [live: 4, live_session: 3]

          live_session session_name, session_opts do
            get("/css-:md5", LiveObserver.Assets, :css, as: :live_observer_asset)
            get("/js-:md5", LiveObserver.Assets, :js, as: :live_observer_asset)

            # All helpers are public contracts and cannot be changed
            live("/", LiveObserver.Live.Processes, :processes, route_opts)
            # live("/", LiveObserver.PageLive, :home, route_opts)
            # live("/:page", LiveObserver.PageLive, :page, route_opts)
            # live("/:node/:page", LiveObserver.PageLive, :page, route_opts)
          end
        end
      end

    # TODO: Remove check once we require Phoenix v1.7
    #
    # [MKT] This still seems needed on Phoenix 1.7.14
    if Code.ensure_loaded?(Phoenix.VerifiedRoutes) do
      quote do
        unquote(scope)

        unless Module.get_attribute(__MODULE__, :live_observer_prefix) do
          @live_observer_prefix Phoenix.Router.scoped_path(__MODULE__, path)
                                |> String.replace_suffix("/", "")
          def __live_observer_prefix__, do: @live_observer_prefix
        end
      end
    else
      scope
    end
  end

  defp expand_alias({:__aliases__, _, _} = alias, env),
    do: Macro.expand(alias, %{env | function: {:live_observer, 2}})

  defp expand_alias(other, _env), do: other

  @doc false
  def __options__(options) do
    live_socket_path = Keyword.get(options, :live_socket_path, "/live")

    env_keys =
      case options[:env_keys] do
        nil ->
          nil

        keys when is_list(keys) ->
          keys

        other ->
          raise ArgumentError,
                ":env_keys must be a list of strings, got: " <> inspect(other)
      end

    request_logger_cookie_domain =
      case options[:request_logger_cookie_domain] do
        nil ->
          nil

        domain when is_binary(domain) ->
          domain

        :parent ->
          :parent

        other ->
          raise ArgumentError,
                ":request_logger_cookie_domain must be a binary or :parent atom, got: " <>
                  inspect(other)
      end

    request_logger_flag =
      case options[:request_logger] do
        nil ->
          true

        bool when is_boolean(bool) ->
          bool

        other ->
          raise ArgumentError,
                ":request_logger must be a boolean, got: " <> inspect(other)
      end

    request_logger = {request_logger_flag, request_logger_cookie_domain}

    csp_nonce_assign_key =
      case options[:csp_nonce_assign_key] do
        nil -> nil
        key when is_atom(key) -> %{img: key, style: key, script: key}
        %{} = keys -> Map.take(keys, [:img, :style, :script])
      end

    allow_destructive_actions = options[:allow_destructive_actions] || false

    session_args = [
      env_keys,
      allow_destructive_actions,
      request_logger,
      csp_nonce_assign_key
    ]

    {
      options[:live_session_name] || :live_observer,
      [
        session: {__MODULE__, :__session__, session_args},
        root_layout: {LiveObserver.LayoutView, :dash},
        on_mount: options[:on_mount] || nil
      ],
      [
        private: %{live_socket_path: live_socket_path, csp_nonce_assign_key: csp_nonce_assign_key},
        as: :live_observer
      ]
    }
  end

  @doc false
  def __session__(
        conn,
        _env_keys,
        allow_destructive_actions,
        _request_logger,
        csp_nonce_assign_key
      ) do
    # {pages, requirements} =
    #   [
    #     home: {Phoenix.LiveDashboard.HomePage, %{env_keys: env_keys, home_app: home_app}},
    #     os_mon: {Phoenix.LiveDashboard.OSMonPage, %{}},
    #     memory_allocators: {Phoenix.LiveDashboard.MemoryAllocatorsPage, %{}}
    #   ]
    #   |> Enum.concat(metrics_page(metrics, metrics_history))
    #   |> Enum.concat(request_logger_page(conn, request_logger))
    #   |> Enum.concat(
    #     applications: {Phoenix.LiveDashboard.ApplicationsPage, %{}},
    #     processes: {Phoenix.LiveDashboard.ProcessesPage, %{}},
    #     ports: {Phoenix.LiveDashboard.PortsPage, %{}},
    #     sockets: {Phoenix.LiveDashboard.SocketsPage, %{}},
    #     ets: {Phoenix.LiveDashboard.EtsPage, %{}},
    #     ecto_stats: {Phoenix.LiveDashboard.EctoStatsPage, ecto_session}
    #   )
    #   |> Enum.concat(additional_pages)
    #   |> Enum.map(fn {key, {module, opts}} ->
    #     {session, requirements} = initialize_page(module, opts)
    #     {{key, {module, session}}, requirements}
    #   end)
    #   |> Enum.unzip()

    %{
      # "pages" => pages,
      "allow_destructive_actions" => allow_destructive_actions,
      # "requirements" => requirements |> Enum.concat() |> Enum.uniq(),
      "csp_nonces" => %{
        img: conn.assigns[csp_nonce_assign_key[:img]],
        style: conn.assigns[csp_nonce_assign_key[:style]],
        script: conn.assigns[csp_nonce_assign_key[:script]]
      }
    }
  end
end
