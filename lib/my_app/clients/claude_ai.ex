defmodule MyApp.Clients.ClaudeAi do
  @api_url "https://api.anthropic.com/v1/messages"
  @api_key System.get_env("ANTHROPIC_API_KEY")

  def chat_completion(user_input) do
    case Req.post(@api_url,
      json: %{
        model: "claude-3-7-sonnet-20250219",
        max_tokens: 1024,
        messages: [%{role: "user", content: user_input}]
      },
      headers: [
        {"x-api-key", @api_key},
        {"anthropic-version", "2023-06-01"},
        {"content-type", "application/json"}
      ]
    ) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        # Extract the text from the response
        case get_text_from_response(body) do
          {:ok, text} -> {:ok, text}
          {:error, reason} -> {:error, "Failed to extract text: #{reason}"}
        end

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "API request failed with status #{status}: #{inspect(body)}"}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end

  # Private helper function to extract text from the response body
  defp get_text_from_response(body) when is_map(body) do
    try do
      # Assuming Claude's API returns content in a 'content' array with text
      # Adjust this based on the actual API response structure
      case body do
        %{"content" => [%{"text" => text} | _]} when is_binary(text) ->
          {:ok, text}

        _ ->
          {:error, "Unexpected response format"}
      end
    rescue
      e -> {:error, "Error parsing response: #{inspect(e)}"}
    end
  end

  defp get_text_from_response(_), do: {:error, "Invalid response format"}
end
