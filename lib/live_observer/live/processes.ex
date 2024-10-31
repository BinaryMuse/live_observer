defmodule LiveObserver.PageNotFound do
  @moduledoc false
  defexception [:message, plug_status: 404]
end

defmodule LiveObserver.Live.Processes do
  @moduledoc false
  use LiveObserver.Web, :live_view

  import LiveObserver.Helpers
  # alias Phoenix.LiveView.Socket
  # alias LiveObserver.PageBuilder
  # alias __MODULE__

  @derive {Inspect, only: []}
  @default_refresh 15
  @refresh_options [1, 2, 5, 15, 30]
  defstruct links: [],
            nodes: [],
            dashboard_mount_path: nil,
            refresher?: true,
            refresh: @default_refresh,
            refresh_options: for(i <- @refresh_options, do: {"#{i}s", i}),
            timer: nil

  @impl true
  def mount(_params, _sesssion, socket) do
    processes = get_processes()
    if connected?(socket), do: Process.send_after(self(), :refresh, 5000)
    {:ok, assign(socket, processes: processes)}
  end

  @impl true
  def handle_info(:refresh, socket) do
    processes = get_processes()
    if connected?(socket), do: Process.send_after(self(), :refresh, 5000)
    {:noreply, assign(socket, processes: processes)}
  end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}

  def classes_for_status(status) do
    case status do
      :waiting -> "bg-teal-100 text-teal-800"
      :running -> "bg-green-100 text-green-800"
      _ -> "bg-white text-black"
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <!-- Table Section -->
    <div class="px-4 sm:px-6 lg:px-8 mx-auto">
      <!-- Card -->
      <div class="flex flex-col">
        <div class="-m-1.5 overflow-x-auto">
          <div class="p-1.5 min-w-full inline-block align-middle">
            <div class="bg-white border border-gray-200 rounded-xl shadow-sm overflow-hidden">
              <!-- Header -->
              <div class="px-6 py-4 grid gap-3 md:flex md:justify-between md:items-center border-b border-gray-200">
                <div>
                  <h2 class="text-xl font-semibold text-gray-800">
                    Processes
                  </h2>
                  <p class="text-sm text-gray-600">
                    List, inspect, and manage processes
                  </p>
                </div>
              </div>
              <!-- End Header -->

              <!-- Table -->
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th scope="col" class="px-6 py-3 text-start">
                      <div class="flex items-center gap-x-2">
                        <span class="text-xs font-semibold uppercase tracking-wide text-gray-800">
                          Processs ID
                        </span>
                        <div class="hs-tooltip">
                          <div class="hs-tooltip-toggle">
                            <svg
                              class="shrink-0 size-4 text-gray-500"
                              xmlns="http://www.w3.org/2000/svg"
                              width="24"
                              height="24"
                              viewBox="0 0 24 24"
                              fill="none"
                              stroke="currentColor"
                              stroke-width="2"
                              stroke-linecap="round"
                              stroke-linejoin="round"
                            >
                              <circle cx="12" cy="12" r="10" /><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3" /><path d="M12 17h.01" />
                            </svg>
                            <span
                              class="hs-tooltip-content hs-tooltip-shown:opacity-100 hs-tooltip-shown:visible opacity-0 transition-opacity inline-block absolute invisible z-10 py-1 px-2 bg-gray-900 text-xs font-medium text-white rounded shadow-sm"
                              role="tooltip"
                            >
                              Internal BEAM process identifier
                            </span>
                          </div>
                        </div>
                      </div>
                    </th>

                    <th scope="col" class="px-6 py-3 text-start">
                      <div class="flex items-center gap-x-2">
                        <span class="text-xs font-semibold uppercase tracking-wide text-gray-800">
                          Name
                        </span>
                      </div>
                    </th>

                    <th scope="col" class="px-6 py-3 text-start">
                      <div class="flex items-center gap-x-2">
                        <span class="text-xs font-semibold uppercase tracking-wide text-gray-800">
                          Status
                        </span>
                      </div>
                    </th>

                    <th scope="col" class="px-6 py-3 text-start">
                      <div class="flex items-center gap-x-2">
                        <span class="text-xs font-semibold uppercase tracking-wide text-gray-800">
                          Group Leader
                        </span>
                      </div>
                    </th>

                    <th scope="col" class="px-6 py-3 text-start">
                      <div class="flex items-center gap-x-2">
                        <span class="text-xs font-semibold uppercase tracking-wide text-gray-800">
                          Heap Size
                        </span>
                      </div>
                    </th>

                    <th scope="col" class="px-6 py-3 text-end"></th>
                  </tr>
                </thead>

                <tbody class="divide-y divide-gray-200">
                  <%= for {proc, info} <- @processes do %>
                    <tr class="bg-white hover:bg-gray-50">
                      <td class="size-px whitespace-nowrap">
                        <button
                          type="button"
                          class="block"
                          aria-haspopup="dialog"
                          aria-expanded="false"
                          aria-controls="hs-ai-invoice-modal"
                          data-hs-overlay="#hs-ai-invoice-modal"
                        >
                          <span class="block px-6 py-2">
                            <span class="font-mono text-sm text-blue-600">
                              <%= Kernel.inspect(proc) %>
                            </span>
                          </span>
                        </button>
                      </td>
                      <td class="size-px whitespace-nowrap">
                        <button
                          type="button"
                          class="block"
                          aria-haspopup="dialog"
                          aria-expanded="false"
                          aria-controls="hs-ai-invoice-modal"
                          data-hs-overlay="#hs-ai-invoice-modal"
                        >
                          <span class="block px-6 py-2">
                            <span class="text-sm text-gray-600"><%= info[:registered_name] %></span>
                          </span>
                        </button>
                      </td>
                      <td class="size-px whitespace-nowrap">
                        <button
                          type="button"
                          class="block"
                          aria-haspopup="dialog"
                          aria-expanded="false"
                          aria-controls="hs-ai-invoice-modal"
                          data-hs-overlay="#hs-ai-invoice-modal"
                        >
                          <span class="block px-6 py-2">
                            <span class={"py-1 px-1.5 inline-flex items-center gap-x-1 text-xs font-medium #{classes_for_status(info[:status])} rounded-full"}>
                              <svg
                                class="size-2.5"
                                xmlns="http://www.w3.org/2000/svg"
                                width="16"
                                height="16"
                                fill="currentColor"
                                viewBox="0 0 16 16"
                              >
                                <path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zm-3.97-3.03a.75.75 0 0 0-1.08.022L7.477 9.417 5.384 7.323a.75.75 0 0 0-1.06 1.06L6.97 11.03a.75.75 0 0 0 1.079-.02l3.992-4.99a.75.75 0 0 0-.01-1.05z" />
                              </svg>
                              <%= info[:status] %>
                            </span>
                          </span>
                        </button>
                      </td>
                      <td class="size-px whitespace-nowrap">
                        <button
                          type="button"
                          class="block"
                          aria-haspopup="dialog"
                          aria-expanded="false"
                          aria-controls="hs-ai-invoice-modal"
                          data-hs-overlay="#hs-ai-invoice-modal"
                        >
                          <span class="block px-6 py-2">
                            <span class="text-sm text-gray-600">
                              <%= Kernel.inspect(info[:group_leader]) %>
                            </span>
                          </span>
                        </button>
                      </td>
                      <td class="size-px whitespace-nowrap">
                        <button
                          type="button"
                          class="block"
                          aria-haspopup="dialog"
                          aria-expanded="false"
                          aria-controls="hs-ai-invoice-modal"
                          data-hs-overlay="#hs-ai-invoice-modal"
                        >
                          <span class="block px-6 py-2">
                            <span
                              id={"heap-size-#{pid_to_str(proc)}"}
                              class="text-sm text-gray-600"
                              phx-hook="PidMemory"
                              phx-update="ignore"
                              data-new-heap-size={info[:mod_total_heap_size]}
                            >
                              <%= info[:mod_total_heap_size] %>
                            </span>
                            <span class="text-sm text-gray-600">
                              <%= info[:mod_heap_size_units] %>
                            </span>

                            <%!-- <span>(<%= info[:total_heap_size] %>)</span> --%>
                          </span>
                        </button>
                      </td>
                      <td class="size-px whitespace-nowrap">
                        <button
                          type="button"
                          class="block"
                          aria-haspopup="dialog"
                          aria-expanded="false"
                          aria-controls="hs-ai-invoice-modal"
                          data-hs-overlay="#hs-ai-invoice-modal"
                        >
                          <span class="px-6 py-1.5">
                            <span class="py-1 px-2 inline-flex justify-center items-center gap-2 rounded-lg border font-medium bg-white text-gray-700 shadow-sm align-middle hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-white focus:ring-blue-600 transition-all text-sm">
                              <svg
                                class="shrink-0 size-4"
                                xmlns="http://www.w3.org/2000/svg"
                                width="16"
                                height="16"
                                fill="currentColor"
                                viewBox="0 0 16 16"
                              >
                                <path d="M1.92.506a.5.5 0 0 1 .434.14L3 1.293l.646-.647a.5.5 0 0 1 .708 0L5 1.293l.646-.647a.5.5 0 0 1 .708 0L7 1.293l.646-.647a.5.5 0 0 1 .708 0L9 1.293l.646-.647a.5.5 0 0 1 .708 0l.646.647.646-.647a.5.5 0 0 1 .708 0l.646.647.646-.647a.5.5 0 0 1 .801.13l.5 1A.5.5 0 0 1 15 2v12a.5.5 0 0 1-.053.224l-.5 1a.5.5 0 0 1-.8.13L13 14.707l-.646.647a.5.5 0 0 1-.708 0L11 14.707l-.646.647a.5.5 0 0 1-.708 0L9 14.707l-.646.647a.5.5 0 0 1-.708 0L7 14.707l-.646.647a.5.5 0 0 1-.708 0L5 14.707l-.646.647a.5.5 0 0 1-.708 0L3 14.707l-.646.647a.5.5 0 0 1-.801-.13l-.5-1A.5.5 0 0 1 1 14V2a.5.5 0 0 1 .053-.224l.5-1a.5.5 0 0 1 .367-.27zm.217 1.338L2 2.118v11.764l.137.274.51-.51a.5.5 0 0 1 .707 0l.646.647.646-.646a.5.5 0 0 1 .708 0l.646.646.646-.646a.5.5 0 0 1 .708 0l.646.646.646-.646a.5.5 0 0 1 .708 0l.646.646.646-.646a.5.5 0 0 1 .708 0l.646.646.646-.646a.5.5 0 0 1 .708 0l.509.509.137-.274V2.118l-.137-.274-.51.51a.5.5 0 0 1-.707 0L12 1.707l-.646.647a.5.5 0 0 1-.708 0L10 1.707l-.646.647a.5.5 0 0 1-.708 0L8 1.707l-.646.647a.5.5 0 0 1-.708 0L6 1.707l-.646.647a.5.5 0 0 1-.708 0L4 1.707l-.646.647a.5.5 0 0 1-.708 0l-.509-.51z" />
                                <path d="M3 4.5a.5.5 0 0 1 .5-.5h6a.5.5 0 1 1 0 1h-6a.5.5 0 0 1-.5-.5zm0 2a.5.5 0 0 1 .5-.5h6a.5.5 0 1 1 0 1h-6a.5.5 0 0 1-.5-.5zm0 2a.5.5 0 0 1 .5-.5h6a.5.5 0 1 1 0 1h-6a.5.5 0 0 1-.5-.5zm0 2a.5.5 0 0 1 .5-.5h6a.5.5 0 0 1 0 1h-6a.5.5 0 0 1-.5-.5zm8-6a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 0 1h-1a.5.5 0 0 1-.5-.5zm0 2a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 0 1h-1a.5.5 0 0 1-.5-.5zm0 2a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 0 1h-1a.5.5 0 0 1-.5-.5zm0 2a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 0 1h-1a.5.5 0 0 1-.5-.5z" />
                              </svg>
                              View
                            </span>
                          </span>
                        </button>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
              <!-- End Table -->

              <!-- Footer -->
              <div class="px-6 py-4 grid gap-3 md:flex md:justify-between md:items-center border-t border-gray-200">
                <div>
                  <p class="text-sm text-gray-600">
                    <span class="font-semibold text-gray-800"><%= Enum.count(@processes) %></span>
                    results
                  </p>
                </div>

                <div>
                  <div class="inline-flex gap-x-2">
                    <button
                      type="button"
                      class="py-2 px-3 inline-flex items-center gap-x-2 text-sm font-medium rounded-lg border border-gray-200 bg-white text-gray-800 shadow-sm hover:bg-gray-50 focus:outline-none focus:bg-gray-50 disabled:opacity-50 disabled:pointer-events-none"
                    >
                      <svg
                        class="size-3"
                        width="16"
                        height="16"
                        viewBox="0 0 16 15"
                        fill="none"
                        xmlns="http://www.w3.org/2000/svg"
                      >
                        <path
                          d="M10.506 1.64001L4.85953 7.28646C4.66427 7.48172 4.66427 7.79831 4.85953 7.99357L10.506 13.64"
                          stroke="currentColor"
                          stroke-width="2"
                          stroke-linecap="round"
                        />
                      </svg>
                      Prev
                    </button>

                    <button
                      type="button"
                      class="py-2 px-3 inline-flex items-center gap-x-2 text-sm font-medium rounded-lg border border-gray-200 bg-white text-gray-800 shadow-sm hover:bg-gray-50 focus:outline-none focus:bg-gray-50 disabled:opacity-50 disabled:pointer-events-none"
                    >
                      Next
                      <svg
                        class="size-3"
                        width="16"
                        height="16"
                        viewBox="0 0 16 16"
                        fill="none"
                        xmlns="http://www.w3.org/2000/svg"
                      >
                        <path
                          d="M4.50598 2L10.1524 7.64645C10.3477 7.84171 10.3477 8.15829 10.1524 8.35355L4.50598 14"
                          stroke="currentColor"
                          stroke-width="2"
                          stroke-linecap="round"
                        />
                      </svg>
                    </button>
                  </div>
                </div>
              </div>
              <!-- End Footer -->
            </div>
          </div>
        </div>
      </div>
      <!-- End Card -->
    </div>
    <!-- End Table Section -->

    <!-- Modal -->
    <div
      id="hs-ai-invoice-modal"
      class="hs-overlay hidden size-full fixed top-0 start-0 z-[80] overflow-x-hidden overflow-y-auto pointer-events-none"
      role="dialog"
      tabindex="-1"
      aria-labelledby="hs-ai-invoice-modal-label"
    >
      <div class="hs-overlay-open:mt-7 hs-overlay-open:opacity-100 hs-overlay-open:duration-500 mt-0 opacity-0 ease-out transition-all sm:max-w-lg sm:w-full m-3 sm:mx-auto">
        <div class="relative flex flex-col bg-white shadow-lg rounded-xl pointer-events-auto">
          <div class="relative overflow-hidden min-h-32 bg-gray-900 text-center rounded-t-xl">
            <!-- Close Button -->
            <div class="absolute top-2 end-2">
              <button
                type="button"
                class="flex justify-center items-center size-7 text-sm font-semibold rounded-full border border-transparent text-white/70 hover:bg-white/10 focus:outline-none focus:bg-white/10 disabled:opacity-50 disabled:pointer-events-none"
                aria-label="Close"
                data-hs-overlay="#hs-ai-invoice-modal"
              >
                <span class="sr-only">Close</span>
                <svg
                  class="shrink-0 size-4"
                  xmlns="http://www.w3.org/2000/svg"
                  width="24"
                  height="24"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                >
                  <path d="M18 6 6 18" /><path d="m6 6 12 12" />
                </svg>
              </button>
            </div>
            <!-- End Close Button -->

            <!-- SVG Background Element -->
            <figure class="absolute inset-x-0 bottom-0">
              <svg
                preserveAspectRatio="none"
                xmlns="http://www.w3.org/2000/svg"
                x="0px"
                y="0px"
                viewBox="0 0 1920 100.1"
              >
                <path
                  fill="currentColor"
                  class="fill-white"
                  d="M0,0c0,0,934.4,93.4,1920,0v100.1H0L0,0z"
                >
                </path>
              </svg>
            </figure>
            <!-- End SVG Background Element -->
          </div>

          <div class="relative z-10 -mt-12">
            <!-- Icon -->
            <span class="mx-auto flex justify-center items-center size-[62px] rounded-full border border-gray-200 bg-white text-gray-700 shadow-sm">
              <svg
                class="size-6"
                xmlns="http://www.w3.org/2000/svg"
                width="16"
                height="16"
                fill="currentColor"
                viewBox="0 0 16 16"
              >
                <path d="M1.92.506a.5.5 0 0 1 .434.14L3 1.293l.646-.647a.5.5 0 0 1 .708 0L5 1.293l.646-.647a.5.5 0 0 1 .708 0L7 1.293l.646-.647a.5.5 0 0 1 .708 0L9 1.293l.646-.647a.5.5 0 0 1 .708 0l.646.647.646-.647a.5.5 0 0 1 .708 0l.646.647.646-.647a.5.5 0 0 1 .801.13l.5 1A.5.5 0 0 1 15 2v12a.5.5 0 0 1-.053.224l-.5 1a.5.5 0 0 1-.8.13L13 14.707l-.646.647a.5.5 0 0 1-.708 0L11 14.707l-.646.647a.5.5 0 0 1-.708 0L9 14.707l-.646.647a.5.5 0 0 1-.708 0L7 14.707l-.646.647a.5.5 0 0 1-.708 0L5 14.707l-.646.647a.5.5 0 0 1-.708 0L3 14.707l-.646.647a.5.5 0 0 1-.801-.13l-.5-1A.5.5 0 0 1 1 14V2a.5.5 0 0 1 .053-.224l.5-1a.5.5 0 0 1 .367-.27zm.217 1.338L2 2.118v11.764l.137.274.51-.51a.5.5 0 0 1 .707 0l.646.647.646-.646a.5.5 0 0 1 .708 0l.646.646.646-.646a.5.5 0 0 1 .708 0l.646.646.646-.646a.5.5 0 0 1 .708 0l.646.646.646-.646a.5.5 0 0 1 .708 0l.646.646.646-.646a.5.5 0 0 1 .708 0l.509.509.137-.274V2.118l-.137-.274-.51.51a.5.5 0 0 1-.707 0L12 1.707l-.646.647a.5.5 0 0 1-.708 0L10 1.707l-.646.647a.5.5 0 0 1-.708 0L8 1.707l-.646.647a.5.5 0 0 1-.708 0L6 1.707l-.646.647a.5.5 0 0 1-.708 0L4 1.707l-.646.647a.5.5 0 0 1-.708 0l-.509-.51z" />
                <path d="M3 4.5a.5.5 0 0 1 .5-.5h6a.5.5 0 1 1 0 1h-6a.5.5 0 0 1-.5-.5zm0 2a.5.5 0 0 1 .5-.5h6a.5.5 0 1 1 0 1h-6a.5.5 0 0 1-.5-.5zm0 2a.5.5 0 0 1 .5-.5h6a.5.5 0 1 1 0 1h-6a.5.5 0 0 1-.5-.5zm0 2a.5.5 0 0 1 .5-.5h6a.5.5 0 0 1 0 1h-6a.5.5 0 0 1-.5-.5zm8-6a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 0 1h-1a.5.5 0 0 1-.5-.5zm0 2a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 0 1h-1a.5.5 0 0 1-.5-.5zm0 2a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 0 1h-1a.5.5 0 0 1-.5-.5zm0 2a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 0 1h-1a.5.5 0 0 1-.5-.5z" />
              </svg>
            </span>
            <!-- End Icon -->
          </div>
          <!-- Body -->
          <div class="p-4 sm:p-7 overflow-y-auto">
            <div class="text-center">
              <h3 id="hs-ai-invoice-modal-label" class="text-lg font-semibold text-gray-800">
                Process Info
              </h3>
              <p class="text-sm text-gray-500">
                #PID&lt;0.123.4&gt;
              </p>
            </div>
            <!-- Grid -->
            <div class="mt-5 sm:mt-10 grid grid-cols-2 sm:grid-cols-3 gap-5">
              <div>
                <span class="block text-xs uppercase text-gray-500">Group Leader</span>
                <span class="block text-sm font-medium text-gray-800">#PID&lt;0.50.0&gt;</span>
              </div>
              <!-- End Col -->
              <div>
                <span class="block text-xs uppercase text-gray-500">Queue Length</span>
                <span class="block text-sm font-medium text-gray-800">2</span>
              </div>
              <!-- End Col -->
              <div>
                <span class="block text-xs uppercase text-gray-500">Heap Size</span>
                <div class="flex items-center gap-x-2">
                  <span class="block text-sm font-medium text-gray-800">5067</span>
                </div>
              </div>
              <!-- End Col -->
            </div>
            <!-- End Grid -->
            <div class="mt-5 sm:mt-10">
              <h4 class="text-xs font-semibold uppercase text-gray-800">Summary</h4>

              <ul class="mt-3 flex flex-col">
                <li class="inline-flex items-center gap-x-2 py-3 px-4 text-sm border text-gray-800 -mt-px first:rounded-t-lg first:mt-0 last:rounded-b-lg">
                  <div class="flex items-center justify-between w-full">
                    <span>Payment to Front</span>
                    <span>$264.00</span>
                  </div>
                </li>
                <li class="inline-flex items-center gap-x-2 py-3 px-4 text-sm border text-gray-800 -mt-px first:rounded-t-lg first:mt-0 last:rounded-b-lg">
                  <div class="flex items-center justify-between w-full">
                    <span>Tax fee</span>
                    <span>$52.8</span>
                  </div>
                </li>
                <li class="inline-flex items-center gap-x-2 py-3 px-4 text-sm font-semibold bg-gray-50 border text-gray-800 -mt-px first:rounded-t-lg first:mt-0 last:rounded-b-lg">
                  <div class="flex items-center justify-between w-full">
                    <span>Amount paid</span>
                    <span>$316.8</span>
                  </div>
                </li>
              </ul>
            </div>
            <!-- Button -->
            <div class="mt-5 flex justify-end gap-x-2">
              <a
                class="py-2 px-3 inline-flex items-center gap-x-2 text-sm font-medium rounded-lg border border-gray-200 bg-white text-gray-800 shadow-sm hover:bg-gray-50 disabled:opacity-50 disabled:pointer-events-none focus:outline-none focus:bg-gray-50"
                href="#"
              >
                <svg
                  class="shrink-0 size-4"
                  xmlns="http://www.w3.org/2000/svg"
                  width="24"
                  height="24"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                >
                  <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" /><polyline points="7 10 12 15 17 10" /><line
                    x1="12"
                    x2="12"
                    y1="15"
                    y2="3"
                  />
                </svg>
                Invoice PDF
              </a>
              <a
                class="py-2 px-3 inline-flex items-center gap-x-2 text-sm font-medium rounded-lg border border-transparent bg-blue-600 text-white hover:bg-blue-700 focus:outline-none focus:bg-blue-700 disabled:opacity-50 disabled:pointer-events-none"
                href="#"
              >
                <svg
                  class="shrink-0 size-4"
                  xmlns="http://www.w3.org/2000/svg"
                  width="24"
                  height="24"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                >
                  <polyline points="6 9 6 2 18 2 18 9" /><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2" /><rect
                    width="12"
                    height="8"
                    x="6"
                    y="14"
                  />
                </svg>
                Print
              </a>
            </div>
            <!-- End Buttons -->
            <div class="mt-5 sm:mt-10">
              <p class="text-sm text-gray-500">
                If you have any questions, please contact us at
                <a
                  class="inline-flex items-center gap-x-1.5 text-blue-600 decoration-2 hover:underline focus:outline-none focus:underline font-medium"
                  href="#"
                >
                  example@site.com
                </a>
                or call at
                <a
                  class="inline-flex items-center gap-x-1.5 text-blue-600 decoration-2 hover:underline focus:outline-none focus:underline font-medium"
                  href="tel:+1898345492"
                >
                  +1 898-34-5492
                </a>
              </p>
            </div>
          </div>
          <!-- End Body -->
        </div>
      </div>
    </div>
    <!-- End Modal -->
    """
  end

  # Maybe one day we'll be running the BEAM on a very, very powerful computer
  @units ["B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB"]

  defp get_processes do
    Process.list()
    |> Enum.map(fn pid ->
      info = Process.info(pid, [:registered_name, :total_heap_size, :status, :group_leader])

      {amount, unit} = to_best_unit(info[:total_heap_size], 0)

      info =
        info
        |> Keyword.put(:mod_total_heap_size, amount)
        |> Keyword.put(:mod_heap_size_units, Enum.at(@units, unit))

      {pid, info}
    end)
  end

  # If displaying the value in bytes, don't show decimal places.
  defp to_best_unit(amount, unit) when amount < 1024 and is_integer(amount), do: {amount, unit}

  # If displaying in float, the value started off greater than 1024 and can safely be rounded.
  defp to_best_unit(amount, unit) when amount < 1024 and is_float(amount),
    do: {Float.round(amount, 2), unit}

  defp to_best_unit(amount, unit), do: to_best_unit(amount / 1024, unit + 1)

  def pid_to_str(pid) when is_pid(pid) do
    pid
    |> :erlang.pid_to_list()
    |> List.to_string()
    |> String.trim_leading("<")
    |> String.trim_trailing(">")
  end

  def str_to_pid(str) when is_binary(str) do
    "<#{str}>"
    |> String.to_charlist()
    |> :erlang.list_to_pid()
  end
end
