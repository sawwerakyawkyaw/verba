# Verba - Language Learning Role Play App

Verba is a Phoenix LiveView application designed to help users practice language skills through interactive role-playing scenarios. The app features audio recording, playback, and scenario-based conversations.

## Features

- Interactive role-playing scenarios (Restaurant, Supermarket, Train Station)
- Real-time audio recording and playback
- Audio visualization with animated waves
- Language translation toggle (CN/EN)
- Responsive UI with Tailwind CSS

## Setup

1. Install Elixir and Phoenix:

   ```
   brew install elixir
   mix archive.install hex phx_new
   ```

2. Clone the repository:

   ```
   git clone https://github.com/yourusername/verba.git
   cd verba
   ```

3. Install dependencies:

   ```
   mix setup
   ```

4. Start the Phoenix server:

   ```
   mix phx.server
   ```

5. Visit [`localhost:4000`](http://localhost:4000) in your browser.

## Usage

1. Select a scenario (Restaurant, Supermarket, or Train Station)
2. Click "Start Role Play" to begin
3. Use the microphone button to record your voice
4. Toggle between original and translated text using the language button
5. Audio responses will play automatically with visual feedback

## Project Structure

Key directories:

- `lib/my_app_web/live/` - Contains LiveView modules
- `assets/` - Frontend assets and styling
- `audio/` - Stores generated audio files
- `lib/my_app/scenarios/` - Scenario-specific logic

## Deployment

For production deployment, please refer to the [Phoenix deployment guide](https://hexdocs.pm/phoenix/deployment.html).

## Learn More

- [Phoenix Framework](https://www.phoenixframework.org/)
- [LiveView Documentation](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html)
- [Tailwind CSS](https://tailwindcss.com/)
