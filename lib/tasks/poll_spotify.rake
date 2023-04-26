task poll_spotify: [:environment] do
  require 'spotify_poller'

  begin
    poller = SpotifyPoller.new
    poller.run!
  rescue => e
    Rails.logger.fatal e.full_message
    # TODO: in theory we shouldn't have to explicitly log the exception,
    # but running into some issues with the process silently failing without
    # exceptions getting logged in the host service (Render)
    raise e
  end
end
