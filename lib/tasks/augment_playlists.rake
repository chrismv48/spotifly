task :augment_playlists => [:environment] do
  PlaylistAugmenter.augment_all!
end
