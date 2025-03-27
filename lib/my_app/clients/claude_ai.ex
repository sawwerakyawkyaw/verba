defmodule MyApp.Clients.CaludeAi do
  @api_url "https://api.anthropic.com/v1/messages"
  @api_key System.get_env("ANTHROPIC_API_KEY")

  def chat_completion(user_input) do
    Req.post(@api_url,
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
    )
  end
end
