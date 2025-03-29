defmodule MyApp.Services.ConversationService do
  @moduledoc """
  A service for managing conversations with text generation, audio conversion, and translation.

  Features:
  - Scenario-based conversation handling
  - Text generation using Claude AI
  - Audio generation using Google Text-to-Speech
  - Translation to English using AssemblyAI transcription

  ## Example Usage
      {:ok, result} = ConversationService.converse(:restaurant, [])
      # => {:ok, %{text: "您好！请问您现在要点餐吗？", translation: "Hello! Ready to order now?", audio_file_path: "/path/to/audio.mp3"}}
  """

  alias MyApp.Clients.{ClaudeAi, GTTS}
  alias MyApp.Scenarios.ScenarioFactory
  # Type definitions for Dialyzer
  @type message :: %{String.t() => String.t()}
  # Add more scenarios as atoms here
  @type scenario :: :restaurant
  @type state :: :start | :continue
  @type result ::
          {:ok, %{text: String.t(), translation: String.t(), audio_file_path: String.t()}}
          | {:error, String.t()}

  @doc """
  Handles a conversation based on a scenario and message history.

  ## Parameters
  - scenario: Atom identifying the conversation scenario (e.g., :restaurant)
  - messages: List of maps with :role and :content keys representing prior messages
  """
  @spec converse(scenario, [message]) :: result
  def converse(scenario, messages) do
    with {:ok, text} <- conversation_text(scenario, messages),
         {:ok, audio_file_path} <- GTTS.synthesize_speech(text, "cmn-CN-Wavenet-C"),
         {:ok, translation} <- MyApp.Services.TranslationService.translate_to_english(text) do
      {:ok, %{text: text, translation: translation, audio_file_path: audio_file_path}}
    else
      {:error, reason} -> {:error, "Conversation failed: #{reason}"}
    end
  end

  @doc false
  @spec conversation_text(scenario, [message]) :: {:ok, String.t()} | {:error, String.t()}
  defp conversation_text(scenario, messages) do
    # Get the scenario module from the factory
    scenario_module = ScenarioFactory.get_module(scenario)

    # Determine if conversation is new
    is_conversation_new = Enum.empty?(messages)
    state = if is_conversation_new, do: :start, else: :continue

    # Get system prompt from the scenario module
    system_prompt = scenario_module.get_system_prompt(state)
    system_message = %{"role" => "system", "content" => system_prompt}

    # Build message list
    default_user_message =
      if is_conversation_new, do: nil, else: %{"role" => "user", "content" => "Hallo!"}

    conversation_messages =
      case {is_conversation_new, messages} do
        # For :start, no user message needed
        {true, _} -> [system_message]
        {false, []} -> [system_message, default_user_message]
        {false, msgs} -> [system_message | msgs]
      end

    # Format messages as a single string for ClaudeAi
    user_input =
      conversation_messages
      |> Enum.map(fn msg -> "#{msg["role"]}: #{msg["content"]}" end)
      |> Enum.join("\n")

    # Generate response using ClaudeAi
    case ClaudeAi.chat_completion(user_input) do
      {:ok, text} -> {:ok, text}
      {:error, reason} -> {:error, "Text generation failed: #{reason}"}
    end
  end
end
