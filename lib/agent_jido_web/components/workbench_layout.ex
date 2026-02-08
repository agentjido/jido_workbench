defmodule AgentJidoWeb.WorkbenchLayout do
  @moduledoc false
  use AgentJidoWeb, :live_component
  use PetalComponents
  alias AgentJidoWeb.{MenuItems, Menu}
  alias AgentJido.GithubStarsTracker

  # Add helper function for determining show_layout
  def show_layout(params, session) do
    cond do
      is_map(params) && Map.has_key?(params, "show_layout") -> params["show_layout"]
      is_map(session) && Map.has_key?(session, "show_layout") -> session["show_layout"]
      true -> true
    end
  end

  attr(:current_page, :atom)
  attr(:show_menu, :boolean, default: true)
  attr(:show_layout, :boolean, default: true)
  slot(:inner_block)

  def workbench_layout(assigns) do
    ~H"""
    <%= if @show_layout do %>
      <div class="h-screen flex flex-col">
        <div class="fixed top-0 left-0 right-0 z-50">
          <.nav_bar />
        </div>
        <div class="flex flex-1 mt-16">
          <%= if @show_menu do %>
            <aside class="w-64 overflow-y-auto bg-secondary-50 dark:bg-secondary-950 flex-shrink-0 border-r border-secondary-800 dark:border-secondary-800">
              <div class="py-4">
                <Menu.vertical_menu current_page={@current_page} menu_items={MenuItems.menu_items()} />
              </div>
            </aside>
          <% end %>

          <main class={[
            "flex-1",
            "bg-secondary-50 dark:bg-secondary-950",
            "overflow-y-auto w-full"
          ]}>
            {render_slot(@inner_block)}
          </main>
        </div>
        <footer class="bg-secondary-50 dark:bg-secondary-950 text-secondary-600 dark:text-secondary-400 text-sm py-4 px-6 border-t border-secondary-200 dark:border-secondary-800">
          <div class="flex justify-between items-center">
            <div>
              © {DateTime.utc_now().year} - eBoss.ai - All rights reserved.
            </div>
            <div class="flex gap-4">
              <a
                href="https://hexdocs.pm/jido"
                class="text-secondary-600 dark:text-secondary-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors duration-200"
              >
                Documentation
              </a>
              <a
                href="https://github.com/agentjido/jido"
                class="text-secondary-600 dark:text-secondary-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors duration-200"
              >
                GitHub
              </a>
              <a
                href="https://x.com/agentjido"
                class="text-secondary-600 dark:text-secondary-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors duration-200"
              >
                Twitter
              </a>
            </div>
          </div>
        </footer>
      </div>
    <% else %>
      {render_slot(@inner_block)}
    <% end %>
    """
  end

  def nav_bar(assigns) do
    {stars, _} = GithubStarsTracker.get_stars()
    assigns = assign(assigns, :stars, stars)

    ~H"""
    <nav class="sticky top-0 z-50 flex items-center justify-between w-full h-16 bg-secondary-50 dark:bg-secondary-950 border-b border-secondary-200 dark:border-secondary-800">
      <div class="flex flex-wrap ml-3 sm:flex-nowrap sm:ml-4">
        <a class="inline-flex hover:opacity-90" href="/">
          <div class="font-display text-5xl text-primary-600 dark:text-primary-600 tracking-wide font-bold transition-colors duration-200">
            AGENT JIDO
          </div>
        </a>
      </div>

      <div class="flex justify-end gap-3 pr-4">
        <a
          class="inline-flex items-center gap-2 p-2 text-secondary-600 dark:text-secondary-400 rounded hover:text-primary-600 dark:hover:text-primary-400 transition-colors duration-200 group"
          href={~p"/docs"}
        >
          <.icon
            name="hero-book-open"
            solid
            class="w-5 h-5 m-0.5 mr-2 text-secondary-600 dark:text-secondary-400 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors duration-200"
          />
          <span class="hidden font-semibold sm:block text-secondary-600 dark:text-secondary-400 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors duration-200">
            Docs
          </span>
        </a>
        <a
          class="inline-flex items-center gap-2 p-2 text-secondary-600 dark:text-secondary-400 rounded hover:text-primary-600 dark:hover:text-primary-400 transition-colors duration-200 group"
          href={~p"/cookbook"}
        >
          <.icon
            name="hero-beaker"
            solid
            class="w-5 h-5 m-0.5 mr-2 text-secondary-600 dark:text-secondary-400 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors duration-200"
          />
          <span class="hidden font-semibold sm:block text-secondary-600 dark:text-secondary-400 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors duration-200">
            Cookbook
          </span>
        </a>
        <a
          class="inline-flex items-center gap-2 p-2 text-secondary-600 dark:text-secondary-400 rounded hover:text-primary-600 dark:hover:text-primary-400 transition-colors duration-200 group"
          href={~p"/catalog"}
        >
          <.icon
            name="hero-folder"
            solid
            class="w-5 h-5 m-0.5 mr-2 text-secondary-600 dark:text-secondary-400 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors duration-200"
          />
          <span class="hidden font-semibold sm:block text-secondary-600 dark:text-secondary-400 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors duration-200">
            Catalog
          </span>
        </a>
        <a
          class="inline-flex items-center gap-2 p-2 text-secondary-600 dark:text-secondary-400 rounded hover:text-primary-600 dark:hover:text-primary-400 transition-colors duration-200 group"
          href={~p"/blog"}
        >
          <.icon
            name="hero-document-text"
            solid
            class="w-5 h-5 m-0.5 mr-2 text-secondary-600 dark:text-secondary-400 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors duration-200"
          />
          <span class="hidden font-semibold sm:block text-secondary-600 dark:text-secondary-400 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors duration-200">
            Blog
          </span>
        </a>
        <a
          target="_blank"
          class="inline-flex items-center gap-2 p-2 text-secondary-600 dark:text-secondary-400 rounded hover:text-primary-600 dark:hover:text-primary-400 transition-colors duration-200 group"
          href="https://github.com/agentjido/jido"
        >
          <svg
            class="w-5 h-5 fill-secondary-600 dark:fill-secondary-400 group-hover:fill-primary-600 dark:group-hover:fill-primary-400 transition-colors duration-200"
            xmlns="http://www.w3.org/2000/svg"
            data-name="Layer 1"
            viewBox="0 0 24 24"
          >
            <path d="M12,2.2467A10.00042,10.00042,0,0,0,8.83752,21.73419c.5.08752.6875-.21247.6875-.475,0-.23749-.01251-1.025-.01251-1.86249C7,19.85919,6.35,18.78423,6.15,18.22173A3.636,3.636,0,0,0,5.125,16.8092c-.35-.1875-.85-.65-.01251-.66248A2.00117,2.00117,0,0,1,6.65,17.17169a2.13742,2.13742,0,0,0,2.91248.825A2.10376,2.10376,0,0,1,10.2,16.65923c-2.225-.25-4.55-1.11254-4.55-4.9375a3.89187,3.89187,0,0,1,1.025-2.6875,3.59373,3.59373,0,0,1,.1-2.65s.83747-.26251,2.75,1.025a9.42747,9.42747,0,0,1,5,0c1.91248-1.3,2.75-1.025,2.75-1.025a3.59323,3.59323,0,0,1,.1,2.65,3.869,3.869,0,0,1,1.025,2.6875c0,3.83747-2.33752,4.6875-4.5625,4.9375a2.36814,2.36814,0,0,1,.675,1.85c0,1.33752-.01251,2.41248-.01251,2.75,0,.26251.1875.575.6875.475A10.0053,10.0053,0,0,0,12,2.2467Z" />
          </svg>
          <span class="hidden font-semibold sm:block text-secondary-600 dark:text-secondary-400 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors duration-200">
            {@stars || 0}
          </span>
          <.icon
            name="hero-star-solid"
            class="w-4 h-4 inline text-secondary-600 dark:text-secondary-400 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors duration-200"
          />
        </a>
        <a
          target="_blank"
          class="inline-flex items-center gap-2 p-2 text-secondary-600 dark:text-secondary-400 rounded hover:text-primary-600 dark:hover:text-primary-400 transition-colors duration-200 group"
          href={~p"/discord"}
        >
          <svg
            class="w-5 h-5 fill-secondary-600 dark:fill-secondary-400 group-hover:fill-primary-600 dark:group-hover:fill-primary-400 transition-colors duration-200"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 127.14 96.36"
          >
            <path d="M107.7,8.07A105.15,105.15,0,0,0,81.47,0a72.06,72.06,0,0,0-3.36,6.83A97.68,97.68,0,0,0,49,6.83,72.37,72.37,0,0,0,45.64,0,105.89,105.89,0,0,0,19.39,8.09C2.79,32.65-1.71,56.6.54,80.21h0A105.73,105.73,0,0,0,32.71,96.36,77.11,77.11,0,0,0,39.6,85.25a68.42,68.42,0,0,1-10.85-5.18c.91-.66,1.8-1.34,2.66-2a75.57,75.57,0,0,0,64.32,0c.87.71,1.76,1.39,2.66,2a68.68,68.68,0,0,1-10.87,5.19,77,77,0,0,0,6.89,11.1A105.25,105.25,0,0,0,126.6,80.22c1.24-23.28-3.67-47.57-18.9-72.15ZM42.45,65.69C36.18,65.69,31,60,31,53s5-12.74,11.43-12.74S54,46,53.89,53,48.84,65.69,42.45,65.69Zm42.24,0C78.41,65.69,73.25,60,73.25,53s5.18-12.74,11.44-12.74S96.23,46,96.12,53,91.08,65.69,84.69,65.69Z" />
          </svg>
        </a>
        <a
          target="_blank"
          class="inline-flex items-center gap-2 p-2 text-secondary-600 dark:text-secondary-400 rounded hover:text-primary-600 dark:hover:text-primary-400 transition-colors duration-200 group"
          href="https://x.com/agentjido"
        >
          <svg
            class="w-5 h-5 fill-secondary-600 dark:fill-secondary-400 group-hover:fill-primary-600 dark:group-hover:fill-primary-400 transition-colors duration-200"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
          >
            <path d="M14.095479,10.316482L22.286354,1h-1.940718l-7.115352,8.087682L7.551414,1H1l8.589488,12.231093L1,23h1.940717  l7.509372-8.542861L16.448587,23H23L14.095479,10.316482z M11.436522,13.338465l-0.871624-1.218704l-6.924311-9.68815h2.981339  l5.58978,7.82155l0.867949,1.218704l7.26506,10.166271h-2.981339L11.436522,13.338465z" />
          </svg>
        </a>
        <.color_scheme_switch />
      </div>
    </nav>
    """
  end
end
