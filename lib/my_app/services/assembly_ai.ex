defmodule MyApp.Services.AssemblyAi do
  @moduledoc """
  Provides functionality to convert audio files to text using AssemblyAI's API.

  ## Examples

      # Basic usage
      {:ok, text} = MyApp.Services.AssemblyAi.convert_audio_to_text("/path/to/audio.mp3")

      # Error handling
      case MyApp.Services.AssemblyAi.convert_audio_to_text("invalid_path.mp3") do
        {:ok, text} -> # handle success
        {:error, reason} -> # handle error
      end
  """

  @assembly_ai_url "https://api.assemblyai.com/v2"
  # 3 seconds
  @poll_interval 3000
  @api_key "520238eeb282493380557f2afb277ca6"
  @max_attempts 30

  @doc """
  Converts an audio file to text through AssemblyAI's transcription service.

  ## Parameters
    - audio_file_path: Path to the audio file to transcribe

  ## Returns
    - {:ok, String.t} on successful transcription
    - {:error, String.t} if any step in the process fails

  The process involves three main steps:
  1. Uploading the audio file to AssemblyAI's temporary storage
  2. Starting a transcription job
  3. Polling for completion of the transcription
  """
  def convert_audio_to_text(audio_file_path) do
    with {:ok, upload_url} <- upload_audio(audio_file_path),
         {:ok, transcript_id} <- create_transcription_job(upload_url),
         {:ok, transcript} <- poll_transcription_status(transcript_id) do
      {:ok, transcript}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  # Uploads an audio file to AssemblyAI's temporary storage.

  ## Parameters
  #  - file_path: Local path to the audio file

  ## Returns
  #  - {:ok, upload_url} if successful
  #  - {:error, reason} if file not found or upload fails

  defp upload_audio(file_path) do
    if File.exists?(file_path) do
      headers = [
        {"Authorization", @api_key},
        {"Content-Type", "application/octet-stream"}
      ]

      response =
        Req.post!(
          "#{@assembly_ai_url}/upload",
          headers: headers,
          body: File.read!(file_path)
        )

      case response.status do
        200 -> {:ok, response.body["upload_url"]}
        _ -> {:error, "Failed to upload audio. Status: #{response.status}"}
      end
    else
      {:error, "Audio file not found at #{file_path}"}
    end
  end

  # Starts a new transcription job for the given audio URL.

  ## Parameters
  #  - audio_url: AssemblyAI URL of the uploaded audio file

  ## Returns
  #  - {:ok, transcript_id} if job creation succeeds
  #  - {:error, reason} if API request fails

  # Note: Currently configured for German transcription (language_code: "de")

  defp create_transcription_job(audio_url) do
    headers = [
      {"Authorization", @api_key},
      {"Content-Type", "application/json"}
    ]

    body = %{audio_url: audio_url, language_code: "zh"}

    response =
      Req.post!(
        "#{@assembly_ai_url}/transcript",
        headers: headers,
        json: body
      )

    case response.status do
      200 -> {:ok, response.body["id"]}
      _ -> {:error, "Failed to create transcription job. Status: #{response.status}"}
    end
  end

  # Polls AssemblyAI for transcription completion status.

  # Parameters
  # - transcript_id: AssemblyAI transcription job ID
  # - attempt: Current polling attempt (used internally for recursion)

  # Returns
  # - {:ok, transcribed_text} when completed
  # - {:error, reason} if transcription fails or polling times out

  # Implements exponential backoff with a maximum of #{@max_attempts} attempts

  defp poll_transcription_status(transcript_id, attempt \\ 0) do
    headers = [{"Authorization", @api_key}]

    response =
      Req.get!(
        "#{@assembly_ai_url}/transcript/#{transcript_id}",
        headers: headers
      )

    case response.status do
      200 ->
        case response.body["status"] do
          "completed" ->
            {:ok, response.body["text"]}

          "error" ->
            {:error, "Transcription failed: #{response.body["error"]}"}

          _ ->
            if attempt < @max_attempts do
              :timer.sleep(@poll_interval)
              poll_transcription_status(transcript_id, attempt + 1)
            else
              {:error, "Transcription timed out"}
            end
        end

      _ ->
        {:error, "Failed to fetch transcription status. Status: #{response.status}"}
    end
  end
end
