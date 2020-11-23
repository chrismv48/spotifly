# typed: strict
# == Schema Information
#
# Table name: playlists
#
#  id          :string           not null, primary key
#  deleted_at  :datetime
#  description :string
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'test_helper'

class PlaylistTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
