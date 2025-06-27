defmodule CommentThreadWeb.HomeLive do
  use CommentThreadWeb, :live_view
  alias CommentThread.{Repo, Message}

  def mount(_params, _session, socket) do
    messages = Repo.all(Message) |> Enum.reverse()

    socket =
      socket
      |> assign(:messages, messages)
      |> assign(:form, to_form(%{"content" => ""}))
      |> assign(:editing_message, nil)
      |> assign(:edit_form, nil)

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

  def handle_event("delete_message", %{"id" => id}, socket) do
    message = Repo.get!(Message, id)
    Repo.delete!(message)

    messages = Repo.all(Message) |> Enum.reverse()

    socket = assign(socket, :messages, messages)
    {:noreply, socket}
  end

  def handle_event("edit_message", %{"id" => id}, socket) do
    message = Repo.get!(Message, id)
    edit_form = to_form(Message.changeset(message, %{}))

    socket =
      socket
      |> assign(:editing_message, String.to_integer(id))
      |> assign(:edit_form, edit_form)

      {:noreply, socket}
  end

  def handle_event("cancel_edit", _params, socket) do
    socket =
      socket
      |> assign(:editing_message, nil)
      |> assign(:edit_form, nil)

      {:noreply, socket}
  end

    def handle_event("update_message", %{"id" => id, "content" => content}, socket) do
    message = Repo.get!(Message, id)

    case Message.changeset(message, %{content: content}) |> Repo.update() do
      {:ok, _updated_message} ->
        messages = Repo.all(Message) |> Enum.reverse()

        socket =
          socket
          |> assign(:messages, messages)
          |> assign(:editing_message, nil)
          |> assign(:edit_form, nil)

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto p-6">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">Sitio para escribir</h1>

      <div class="bg-white shadow-md rounded-lg p-6 mb-6">
        <h2 class="text-xl font-semibold mb-4">Ingresa lo que gustes debajo...</h2>

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
          <p class="text-gray-500 italic">No hay mensajes aún.</p>
        <% else %>
          <div class="space-y-3">
            <%= for message <- @messages do %>
              <div class="bg-white p-4 rounded-md shadow-sm border-l-4 border-blue-500">

            <%= if @editing_message == message.id do %>
            <.form for={@edit_form}phx-submit="update_message" class="space-y-3">

            <input type="hidden" name="id" value={message.id} />
            <input
              type="text"
              name="content"
              value={message.content}
              class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />

            <div class="flex gap-2">
            <button
              type="submit"
              class="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 transition-colors">
              Actualizar
            </button>
            <button
              type="button"
              phx-click="cancel_edit"
              class="px-4 py-2 bg-gray-300 text-gray-800 rounded-md hover:bg-gray-400 transition-colors">
              Cancelar
            </button>
            </div>
              </.form>
            <%else %>

            <div class="flex justify-between items-start">
              <div class="flex-1">
                <p class="text-gray-800"><%= message.content %></p>
                <p class="text-sm text-gray-500 mt-2">
                  <%= Calendar.strftime(message.inserted_at, "%d/%m/%Y %H:%M") %>
                </p>
              </div>
              <div class="flex gap-2">
                <button
                  phx-click="edit_message"
                  phx-value-id={message.id}
                  class="px-3 py-1 bg-yellow-500 text-white rounded-md hover:bg-yellow-600 transition-colors">
                  Editar
                </button>
                <button
                  phx-click="delete_message"
                  phx-value-id={message.id}
                  data-confirm="¿Estás seguro de que quieres eliminar este mensaje?"
                  class="px-3 py-1 bg-red-500 text-white rounded-md hover:bg-red-600 transition-colors">
                  Eliminar
                </button>
              </div>
              </div>
            <% end %>
          </div>
          <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
