defmodule MyAppWeb.AudioLive do
  use MyAppWeb, :live_view

  alias MyApp.Services.ConversationService

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       responses: [],
       show_translation: false,
       show_original: true
     )}
  end

  @impl true
  def handle_event("show_original", _, socket) do
    {:noreply, assign(socket, :show_original, true)}
  end

  @impl true
  def handle_event("show_translated", _, socket) do
    {:noreply, assign(socket, :show_original, false)}
  end

  @impl true
  def handle_event("start_role_play", %{"scenario" => scenario}, socket) do
    scenario_atom = String.to_atom(scenario)

    case ConversationService.converse(scenario_atom, []) do
      {:ok, response_map} ->
        updated_response = [response_map | socket.assigns.responses]
        {:noreply, assign(socket, :responses, updated_response)}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Conversation failed: #{reason}")}
    end
  end

  @impl true
  def handle_event("toggle_translation", _, socket) do
    {:noreply, assign(socket, :show_translation, !socket.assigns.show_translation)}
  end

  @impl true
  def handle_event("audio_ended", _, socket) do
    {:noreply, push_event(socket, "stop_animation", %{})}
  end
end
