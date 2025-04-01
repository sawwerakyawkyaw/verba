defmodule MyAppWeb.AudioLive do
  use MyAppWeb, :live_view

  alias MyApp.Services.ConversationService

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(:responses, [])
      |> push_event("init_audio_hooks", %{})
    }
  end

  @impl true
  def handle_event("start_role_play", %{"scenario" => scenario}, socket) do
    scenario_atom = String.to_atom(scenario)

    case ConversationService.converse(scenario_atom, []) do
      {:ok, response_map} ->
        updated_response = [response_map | socket.assigns.responses]
        {:noreply,
          socket
          |> assign(:responses, updated_response)
          |> push_event("start_animation", %{})
        }

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Conversation failed: #{reason}")}
    end
  end

  @impl true
  def handle_event("audio_ended", _, socket) do
    {:noreply, push_event(socket, "stop_animation", %{})}
  end
end
