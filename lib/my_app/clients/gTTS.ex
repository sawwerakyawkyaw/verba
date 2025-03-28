defmodule MyApp.Clients.GTTS do
  @api_url "https://texttospeech.googleapis.com/v1/text:synthesize"
  @audio_dir "audio"

  @doc """
  Synthesizes speech from the given text using Google's Text-to-Speech API.

  ## Parameters
    - text: The text to convert to speech
    - voice: The voice to use for synthesis (default: "en-US-Wavenet-D")
    - audio_format: The format of the output audio file (default: "MP3")

  ## Returns
    - {:ok, file_path} on success where file_path is the path to the saved audio file
    - {:error, reason} if the synthesis fails
  """
  def synthesize_speech(text, voice \\ "en-US-Wavenet-D", audio_format \\ "MP3") do
    request_body = %{
      "input" => %{"text" => text},
      "voice" => %{"languageCode" => "en-US", "name" => voice},
      "audioConfig" => %{"audioEncoding" => audio_format}
    }

    with {:ok, token} <- get_access_token() do
      headers = [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/json"}
      ]

      Req.post(@api_url, json: request_body, headers: headers)
      |> handle_response()
    end
  end

  defp get_access_token do
    # Remove the custom name parameter
    case Goth.fetch(MyApp.Goth) do
      {:ok, %Goth.Token{token: token}} -> {:ok, token}
      error -> {:error, "Failed to fetch access token: #{inspect(error)}"}
    end
  end

  defp handle_response(
         {:ok, %Req.Response{status: 200, body: %{"audioContent" => audio_content}}}
       ) do
    save_audio_file(audio_content)
  end

  defp handle_response({:ok, %Req.Response{status: status, body: body}}) do
    {:error, "API request failed with status #{status}: #{inspect(body)}"}
  end

  defp handle_response({:error, reason}) do
    {:error, "Request failed: #{inspect(reason)}"}
  end

  defp save_audio_file(audio_content) do
    # Ensure the directory exists
    File.mkdir_p!(@audio_dir)
    file_path = Path.join(@audio_dir, "#{System.system_time(:millisecond)}.mp3")

    case File.write(file_path, Base.decode64!(audio_content)) do
      :ok ->
        IO.puts("Audio file saved: #{file_path}")
        {:ok, file_path}

      {:error, reason} ->
        {:error, "Failed to save file: #{inspect(reason)}"}
    end
  end
end
