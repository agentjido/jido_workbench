defmodule AgentJidoWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  The components in this module use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn how to
  customize the generated components in this module.

  Icons are provided by [heroicons](https://heroicons.com), using the
  [heroicons_elixir](https://github.com/mveytsman/heroicons_elixir) project.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  use Gettext, backend: AgentJidoWeb.Gettext
  import AgentJidoWeb.Icon

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        Are you sure?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>

  JS commands may be passed to the `:on_cancel` and `on_confirm` attributes
  for the caller to react to each button press, for example:

      <.modal id="confirm" on_confirm={JS.push("delete")} on_cancel={JS.navigate(~p"/posts")}>
        Are you sure you?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>
  """
  attr(:id, :string, required: true)
  attr(:show, :boolean, default: false)
  attr(:on_cancel, JS, default: %JS{})
  attr(:on_confirm, JS, default: %JS{})

  slot(:inner_block, required: true)
  slot(:title)
  slot(:subtitle)
  slot(:confirm)
  slot(:cancel)

  def phx_modal(assigns) do
    ~H"""
    <div id={@id} phx-mounted={@show && show_modal(@id)} phx-remove={hide_modal(@id)} class="relative z-[100] hidden">
      <div id={"#{@id}-bg"} class="fixed inset-0 transition-opacity bg-background/80" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex items-center justify-center min-h-full">
          <div class="w-full max-w-3xl p-4 sm:p-6 lg:py-8">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-mounted={@show && show_modal(@id)}
              phx-window-keydown={hide_modal(@on_cancel, @id)}
              phx-key="escape"
              phx-click-away={hide_modal(@on_cancel, @id)}
              class="relative hidden transition bg-card shadow-lg rounded-2xl p-14 shadow-foreground/5 ring-1 ring-border"
            >
              <div class="absolute top-6 right-5">
                <phx_button
                  phx-click={hide_modal(@on_cancel, @id)}
                  type="button"
                  class="flex-none p-3 -m-3 opacity-20 hover:opacity-40"
                  aria-label={gettext("close")}
                >
                  <.icon name="hero-x-mark-solid" class="w-5 h-5 stroke-current" />
                </phx_button>
              </div>
              <div id={"#{@id}-content"}>
                <header :if={@title != []}>
                  <h1 id={"#{@id}-title"} class="text-lg font-semibold leading-8 text-foreground">
                    {render_slot(@title)}
                  </h1>
                  <p :if={@subtitle != []} id={"#{@id}-description"} class="mt-2 text-sm leading-6 text-muted-foreground">
                    {render_slot(@subtitle)}
                  </p>
                </header>
                {render_slot(@inner_block)}
                <div :if={@confirm != [] or @cancel != []} class="flex items-center gap-5 mb-4 ml-6">
                  <.phx_button :for={confirm <- @confirm} id={"#{@id}-confirm"} phx-click={@on_confirm} phx-disable-with class="px-3 py-2">
                    {render_slot(confirm)}
                  </.phx_button>
                  <.link
                    :for={cancel <- @cancel}
                    phx-click={hide_modal(@on_cancel, @id)}
                    class="text-sm font-semibold leading-6 text-foreground hover:text-muted-foreground"
                  >
                    {render_slot(cancel)}
                  </.link>
                </div>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr(:id, :string, default: "flash", doc: "the optional id of flash container")
  attr(:flash, :map, default: %{}, doc: "the map of flash messages to display")
  attr(:title, :string, default: nil)
  attr(:kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup")
  attr(:autoshow, :boolean, default: true, doc: "whether to auto show the flash on mount")
  attr(:close, :boolean, default: true, doc: "whether the flash can be closed")
  attr(:rest, :global, doc: "the arbitrary HTML attributes to add to the flash container")

  slot(:inner_block, doc: "the optional inner block that renders the flash message")

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-mounted={@autoshow && show("##{@id}")}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "fixed hidden bottom-10 right-10 w-80 sm:w-96 z-50 rounded-lg p-3 shadow-md shadow-foreground/5 ring-1",
        @kind == :info &&
          "bg-accent-green/15 text-foreground ring-accent-green/30 fill-accent-green",
        @kind == :error &&
          "bg-destructive/15 text-foreground ring-destructive/30 fill-destructive"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-[0.8125rem] font-semibold leading-6">
        <.icon :if={@kind == :info} name="hero-information-circle" mini class="w-4 h-4" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle" mini class="w-4 h-4" />
        {@title}
      </p>
      <p class="mt-2 text-[0.8125rem] leading-5">{msg}</p>
      <button :if={@close} type="button" class="absolute p-2 group top-2 right-1" aria-label={gettext("close")}>
        <.icon name="hero-x-mark-solid" class="w-5 h-5 stroke-current opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr(:flash, :map, required: true, doc: "the map of flash messages")

  def flash_group(assigns) do
    ~H"""
    <.flash kind={:info} title="Success!" flash={@flash} />
    <.flash kind={:error} title="Error!" flash={@flash} />
    <.flash
      id="disconnected"
      kind={:error}
      title="We can't find the internet"
      close={false}
      autoshow={false}
      phx-disconnected={show("#disconnected")}
      phx-connected={hide("#disconnected")}
    >
      Attempting to reconnect <.icon name="hero-arrow-path" class="inline w-3 h-3 ml-1 animate-spin" />
    </.flash>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr(:for, :any, required: true, doc: "the datastructure for the form")
  attr(:as, :any, default: nil, doc: "the server side parameter to collect all input under")

  attr(:rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target),
    doc: "the arbitrary HTML attributes to apply to the form tag"
  )

  slot(:inner_block, required: true)
  slot(:actions, doc: "the slot for form actions, such as a submit button")

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="mt-10 space-y-8 bg-card">
        {render_slot(@inner_block, f)}
        <div :for={action <- @actions} class="flex items-center justify-between gap-6 mt-2">
          {render_slot(action, f)}
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr(:type, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(disabled form name value))

  slot(:inner_block, required: true)

  def phx_button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-primary hover:bg-primary/90 py-2 px-3",
        "text-sm font-semibold leading-6 text-primary-foreground active:text-primary-foreground/80",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc """
  Renders a compact helpful/not-helpful feedback prompt with thumbs up/down icons.

  Thumbs up auto-submits as "helpful". Thumbs down opens a modal for
  optional written feedback before submitting.
  """
  attr(:id, :string, required: true)
  attr(:title, :string, default: "Was this helpful?")
  attr(:value, :string, default: nil)
  attr(:note, :string, default: "")
  attr(:submitted, :boolean, default: false)
  attr(:select_event, :string, required: true)
  attr(:submit_event, :string, required: true)
  attr(:target, :any, default: nil)
  attr(:as, :atom, default: :feedback)
  attr(:form_id, :string, default: nil)
  attr(:thanks_text, :string, default: "Thanks for the feedback.")
  attr(:note_placeholder, :string, default: "What could be improved?")
  attr(:container_class, :string, default: nil)

  def feedback_prompt(assigns) do
    assigns =
      assigns
      |> assign(:form_id, assigns.form_id || "#{assigns.id}-form")
      |> assign(:value, normalize_feedback_value(assigns.value))
      |> assign(:note, assigns.note || "")
      |> assign(:modal_id, "#{assigns.id}-modal")

    ~H"""
    <div id={@id} class={["text-xs", @container_class]}>
      <div class="flex items-center gap-3">
        <span class="text-xs text-muted-foreground">
          <%= if @submitted do %>
            {@thanks_text}
          <% else %>
            {@title}
          <% end %>
        </span>
        <div class="flex items-center gap-1.5">
          <button
            type="button"
            phx-click={@select_event}
            phx-target={@target}
            phx-value-value="helpful"
            disabled={@submitted}
            title="Helpful"
            class={[
              "rounded p-1 transition-colors",
              @value == "helpful" && "text-accent-green",
              @value != "helpful" && !@submitted && "text-muted-foreground/60 hover:text-foreground",
              @value != "helpful" && @submitted && "text-muted-foreground/30"
            ]}
          >
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-5 h-5">
              <path d="M1 8.25a1.25 1.25 0 1 1 2.5 0v7.5a1.25 1.25 0 1 1-2.5 0v-7.5ZM5.5 6.854V16.5a.5.5 0 0 0 .404.491l.096.009h5.25a1.75 1.75 0 0 0 1.696-1.32l1.803-7.212a.75.75 0 0 0-.728-.918H10.25a.75.75 0 0 1-.75-.75V3.587a1.337 1.337 0 0 0-2.39-.829L5.5 6.854Z" />
            </svg>
          </button>
          <button
            type="button"
            phx-click={show_modal(@modal_id)}
            disabled={@submitted}
            title="Not helpful"
            class={[
              "rounded p-1 transition-colors",
              @value == "not_helpful" && "text-accent-green",
              @value != "not_helpful" && !@submitted && "text-muted-foreground/60 hover:text-foreground",
              @value != "not_helpful" && @submitted && "text-muted-foreground/30"
            ]}
          >
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-5 h-5 rotate-180">
              <path d="M1 8.25a1.25 1.25 0 1 1 2.5 0v7.5a1.25 1.25 0 1 1-2.5 0v-7.5ZM5.5 6.854V16.5a.5.5 0 0 0 .404.491l.096.009h5.25a1.75 1.75 0 0 0 1.696-1.32l1.803-7.212a.75.75 0 0 0-.728-.918H10.25a.75.75 0 0 1-.75-.75V3.587a1.337 1.337 0 0 0-2.39-.829L5.5 6.854Z" />
            </svg>
          </button>
        </div>
      </div>
    </div>

    <%!-- Negative feedback modal --%>
    <div id={@modal_id} phx-remove={hide_modal(@modal_id)} class="relative z-[100] hidden">
      <div id={"#{@modal_id}-bg"} class="fixed inset-0 bg-background/80 transition-opacity" aria-hidden="true" />
      <div class="fixed inset-0 overflow-y-auto" role="dialog" aria-modal="true">
        <div class="flex min-h-full items-center justify-center p-4">
          <.focus_wrap
            id={"#{@modal_id}-container"}
            phx-window-keydown={hide_modal(@modal_id)}
            phx-key="escape"
            phx-click-away={hide_modal(@modal_id)}
            class="relative hidden w-full max-w-sm rounded-lg border border-border bg-card p-6 shadow-lg"
          >
            <button
              type="button"
              phx-click={hide_modal(@modal_id)}
              class="absolute top-3 right-3 text-muted-foreground hover:text-foreground transition-colors"
              aria-label="Close"
            >
              <.icon name="hero-x-mark-solid" class="w-4 h-4" />
            </button>
            <p class="mb-3 text-sm font-semibold text-foreground">What could be improved?</p>
            <.form
              id={@form_id}
              for={%{}}
              as={@as}
              phx-submit={JS.push(@submit_event) |> hide_modal(@modal_id)}
              phx-target={@target}
              class="space-y-3"
            >
              <input type="hidden" name={"#{Atom.to_string(@as)}[value]"} value="not_helpful" />
              <textarea
                id={"#{@modal_id}-input"}
                name={"#{Atom.to_string(@as)}[note]"}
                rows="3"
                maxlength="500"
                placeholder={@note_placeholder}
                class="w-full resize-y rounded border border-border bg-background px-3 py-2 text-xs text-foreground placeholder:text-muted-foreground focus:border-primary focus:ring-0"
              >{@note}</textarea>
              <div class="flex justify-end gap-2">
                <button
                  type="button"
                  phx-click={hide_modal(@modal_id)}
                  class="rounded-md px-3 py-1.5 text-xs font-medium text-muted-foreground hover:text-foreground transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  class="rounded-md border border-border bg-background px-3 py-1.5 text-xs font-semibold text-foreground hover:border-primary/50 transition-colors"
                >
                  Submit
                </button>
              </div>
            </.form>
          </.focus_wrap>
        </div>
      </div>
    </div>
    """
  end

  defp normalize_feedback_value(value) when value in ["helpful", "not_helpful"], do: value
  defp normalize_feedback_value(_value), do: nil

  @doc """
  Renders an input with label and error messages.

  A `%Phoenix.HTML.Form{}` and field name may be passed to the input
  to build input names and error messages, or all the attributes and
  errors may be passed explicitly.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr(:id, :any, default: nil)
  attr(:name, :any)
  attr(:label, :string, default: nil)
  attr(:value, :any)

  attr(:type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)
  )

  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form, for example: @form[:email]")

  attr(:errors, :list, default: [])
  attr(:checked, :boolean, doc: "the checked flag for checkbox inputs")
  attr(:prompt, :string, default: nil, doc: "the prompt for select inputs")
  attr(:options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2")
  attr(:multiple, :boolean, default: false, doc: "the multiple flag for select inputs")
  attr(:rest, :global, include: ~w(autocomplete cols disabled form max maxlength min minlength
                                   pattern placeholder readonly required rows size step))
  slot(:inner_block)

  def phx_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> phx_input()
  end

  def phx_input(%{type: "checkbox", value: value} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn -> Phoenix.HTML.Form.normalize_value("checkbox", value) end)

    ~H"""
    <div>
      <label class="flex items-center gap-4 text-sm leading-6 text-muted-foreground">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id || @name}
          name={@name}
          value="true"
          checked={@checked}
          class="rounded border-border text-primary focus:ring-primary"
          {@rest}
        />
        {@label}
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def phx_input(%{type: "select"} = assigns) do
    ~H"""
    <div>
      <.phx_label for={@id}>{@label}</.phx_label>
      <select
        id={@id}
        name={@name}
        class="block w-full px-3 py-2 mt-1 bg-card border border-border rounded-md shadow-sm focus:outline-none focus:ring-primary focus:border-primary sm:text-sm text-foreground"
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value="">{@prompt}</option>
        {Phoenix.HTML.Form.options_for_select(@options, @value)}
      </select>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def phx_input(%{type: "textarea"} = assigns) do
    ~H"""
    <div>
      <.phx_label for={@id}>{@label}</.phx_label>
      <textarea
        id={@id || @name}
        name={@name}
        class={[
          "mt-2 block min-h-[6rem] w-full rounded-lg border-border py-[7px] px-[11px]",
          "text-foreground focus:border-primary focus:outline-none focus:ring-4 focus:ring-primary/5 sm:text-sm sm:leading-6",
          "bg-card",
          @errors != [] && "border-destructive focus:border-destructive focus:ring-destructive/10"
        ]}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def phx_input(assigns) do
    ~H"""
    <div>
      <.phx_label for={@id}>{@label}</.phx_label>
      <input
        type={@type}
        name={@name}
        id={@id || @name}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "mt-2 block w-full rounded-lg border-border py-[7px] px-[11px]",
          "text-foreground focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
          "bg-card focus:border-primary focus:ring-primary/5",
          @errors != [] && "border-destructive focus:border-destructive focus:ring-destructive/10"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  @doc """
  Renders a label.
  """
  attr(:for, :string, default: nil)
  slot(:inner_block, required: true)

  def phx_label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6 text-foreground">
      {render_slot(@inner_block)}
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot(:inner_block, required: true)

  def error(assigns) do
    ~H"""
    <p class="flex gap-3 mt-3 text-sm leading-6 text-destructive">
      <.icon name="hero-exclamation-circle-mini" class="mt-0.5 h-5 w-5 flex-none fill-destructive" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr(:class, :string, default: nil)

  slot(:inner_block, required: true)
  slot(:subtitle)
  slot(:actions)

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-foreground">
          {render_slot(@inner_block)}
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-muted-foreground">
          {render_slot(@subtitle)}
        </p>
      </div>
      <div class="flex-none">{render_slot(@actions)}</div>
    </header>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr(:id, :string, required: true)
  attr(:rows, :list, required: true)
  attr(:row_id, :any, default: nil, doc: "the function for generating the row id")
  attr(:row_click, :any, default: nil, doc: "the function for handling phx-click on each row")

  attr(:row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"
  )

  slot :col, required: true do
    attr(:label, :string)
  end

  slot(:action, doc: "the slot for showing user actions in the last table column")

  def phx_table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="px-4 overflow-y-auto sm:overflow-visible sm:px-0">
      <table class="mt-11 w-[40rem] sm:w-full">
        <thead class="text-left text-[0.8125rem] leading-6 text-muted-foreground">
          <tr>
            <th :for={col <- @col} class="p-0 pb-4 pr-6 font-normal">{col[:label]}</th>
            <th class="relative p-0 pb-4"><span class="sr-only">{gettext("Actions")}</span></th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
          class="relative text-sm leading-6 border-t divide-y divide-border border-border text-foreground"
        >
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)} class="group hover:bg-elevated/60">
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={["relative p-0", @row_click && "hover:cursor-pointer"]}
            >
              <div class="block py-4 pr-6">
                <span class="absolute right-0 -inset-y-px -left-4 group-hover:bg-elevated/60 sm:rounded-l-xl" />
                <span class={["relative", i == 0 && "font-semibold text-foreground"]}>
                  {render_slot(col, @row_item.(row))}
                </span>
              </div>
            </td>
            <td :if={@action != []} class="relative p-0 w-14">
              <div class="relative py-4 text-sm font-medium text-right whitespace-nowrap">
                <span class="absolute left-0 -inset-y-px -right-4 group-hover:bg-elevated/60 sm:rounded-r-xl" />
                <span :for={action <- @action} class="relative ml-4 font-semibold leading-6 text-foreground hover:text-primary">
                  {render_slot(action, @row_item.(row))}
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr(:title, :string, required: true)
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-border">
        <div :for={item <- @item} class="flex gap-4 py-4 sm:gap-8">
          <dt class="w-1/4 flex-none text-[0.8125rem] leading-6 text-muted-foreground">{item.title}</dt>
          <dd class="text-sm leading-6 text-foreground">{render_slot(item)}</dd>
        </div>
      </dl>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr(:navigate, :any, required: true)
  slot(:inner_block, required: true)

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link navigate={@navigate} class="text-sm font-semibold leading-6 text-foreground hover:text-primary">
        <.icon name="hero-arrow-left-solid" class="inline w-3 h-3 stroke-current" />
        {render_slot(@inner_block)}
      </.link>
    </div>
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300", "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200", "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
    |> JS.focus(to: "##{id}-input")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(AgentJidoWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(AgentJidoWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
