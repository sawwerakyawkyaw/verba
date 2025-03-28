defmodule MyApp.Services.TranslationService do
  @doc false
  @spec translate_to_english(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def translate_to_english(chinese_text) do
    prompt = "You are a Chinese to English translator. Translate the following Chinese text to English. Only respond with the English translation, nothing else.\n\n#{chinese_text}"

    case MyApp.Clients.ClaudeAi.chat_completion(prompt) do
      {:ok, translation} -> {:ok, translation}
      {:error, reason} -> {:error, "Translation failed: #{reason}"}
    end
  end
end
