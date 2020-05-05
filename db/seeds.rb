# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

playlist = Playlist.create(
  {
    id: '1234',
    name: 'Foo',
    description: '!dynamic'
  }
)

tracks = Track.create([
                        {
                          id: '567',
                          name: 'Track I love',
                          duration_ms: 1000,
                        },
                        {
                          id: '765',
                          name: 'Track I hate',
                          duration_ms: 1000,
                        }
                      ])

playlist.tracks = tracks

plays = Play.create([
                      {
                        track_id: '567',
                        progress_ms: 1000
                      },
                      {
                        track_id: '765',
                        progress_ms: 5
                      }
                    ]
)
