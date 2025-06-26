defmodule CommentThreadWeb.HomeLive do
  use CommentThreadWeb, :live_view
  alias CommentThread.{Repo, Message}

  def mount(_params, _session, socket) do
    messages = Repo.all(Message) |> Enum.reverse()

    socket =
      socket
      |> assign(:messages, messages)
      |> assign(:form, to_form(%{"content" => ""}))

    {:ok, socket}
  end

  def handle_event("save_message", %{"content" => content}, socket) do
    case content do
      "" ->
        {:noreply, socket}
      _ ->
        %Message{}
        |> Message.changeset(%{content: content})
        |> Repo.insert()

        messages = Repo.all(Message) |> Enum.reverse()

        socket =
          socket
          |> assign(:messages, messages)
          |> assign(:form, to_form(%{"content" => ""}))

        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto p-6">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">Sitio para escribir</h1>

      <div class="bg-white shadow-md rounded-lg p-6 mb-6">
        <h2 class="text-xl font-semibold mb-4">Ingreso algo debajo...</h2>

        <.form
          for={@form}
          phx-submit="save_message"
          class="flex gap-3"
        >
          <input
            type="text"
            name="content"
            value={@form.data["content"]}
            placeholder="Me falta la tarea de Mr. Bootstrap..."
            class="flex-1 px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            autocomplete="off"
          />
          <button
            type="submit"
            class="px-6 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 transition-colors"
          >
            Guardar
          </button>
        </.form>
      </div>

      <div class="bg-gray-50 rounded-lg p-6">
        <h2 class="text-xl font-semibold mb-4">Mensajes guardados:</h2>

        <%= if Enum.empty?(@messages) do %>
          <p class="text-gray-500 italic">No hay mensajes aún. ¡Escribe el primero!</p>
        <% else %>
          <div class="space-y-3">
            <%= for message <- @messages do %>
              <div class="bg-white p-4 rounded-md shadow-sm border-l-4 border-blue-500">
                <p class="text-gray-800"><%= message.content %></p>
                <p class="text-sm text-gray-500 mt-2">
                  <%= Calendar.strftime(message.inserted_at, "%d/%m/%Y %H:%M") %>
                </p>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
