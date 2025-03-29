defmodule MyApp.Services.TranslationService do
  @moduledoc """
  Service module for handling translations between Chinese and English using Claude AI.
  """

  @doc """
  Translates Chinese text to English using Claude AI.

  ## Parameters
    - chinese_text: String containing Chinese text to be translated

  ## Returns
    - `{:ok, translation}` - Successfully translated text
    - `{:error, reason}` - Error message if translation fails

  ## Examples
      iex> TranslationService.translate_to_english("你好")
      {:ok, "Hello"}

      iex> TranslationService.translate_to_english("")
      {:error, "Translation failed: empty input"}
  """
  @spec translate_to_english(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def translate_to_english(chinese_text) do
    prompt =
      "You are a Chinese to English translator. Translate the following Chinese text to English. Only respond with the English translation, nothing else.\n\n#{chinese_text}"

    case MyApp.Clients.ClaudeAi.chat_completion(prompt) do
      {:ok, translation} -> {:ok, translation}
      {:error, reason} -> {:error, "Translation failed: #{reason}"}
    end
  end
end
