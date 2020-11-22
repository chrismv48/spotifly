# spotifly
Dynamic playlists for Spotify

## Components
- Spotify Client - responsible for interacting with the Spotify API.
- Spotify Playlist - class that wraps the playlist model and provides methods for interacting with the playlist
- Spotify Poller - Basically a while loop that polls the Spotify API and reacts to when a playlist is being played.
- Poll Spotify - Rake task that calls the Spotify Poller
- Augment Playlist - Rake task that uses playlist play history to augment the playlist (basically deleting tracks you don't like and adding new tracks for you to try.)
 