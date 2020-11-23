# typed: strict
# == Schema Information
#
# Table name: spotify_user_tokens
#
#  id            :bigint           not null, primary key
#  access_token  :string
#  expires_at    :datetime
#  oauth_code    :string
#  refresh_token :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :integer
#
require 'test_helper'

class SpotifyUserTokenTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
