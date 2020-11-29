# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
#

# Temporarily using the dev environment because I haven't setup a prod DB yet.
set :environment, 'development'

every 1.day, at: '6:15 am' do
  rake "poll_spotify"
end

every 1.day, at: ['6:00 am', '10:00 am', '2:00 pm', '5:00 pm', '7:30 pm'] do
  rake "augment_playlists"
end