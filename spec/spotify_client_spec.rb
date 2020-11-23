# typed: false
require 'rails_helper'
require 'spotify_client'

describe SpotifyClient do
  before do
    stub_request(:any, /.*/)
  end

  after do
    # Do nothing
  end

  describe '#initialize' do
    context 'user token data already exists for user id' do

      let!(:user_token_data) { SpotifyUserToken.create(user_id: described_class::DEFAULT_USER_ID, access_token: '123') }

      it 'finds the user token data for the user id' do
        spotify_client = described_class.new(user_id: described_class::DEFAULT_USER_ID)
        expect(spotify_client.user_token_data.id_previously_changed?).to be(false)
      end

      context 'access token is present' do

        let!(:user_token_data) { SpotifyUserToken.create(user_id: described_class::DEFAULT_USER_ID, access_token: '123') }

        it 'initializes without calling get_access_token!' do
          spotify_client = described_class.new(user_id: described_class::DEFAULT_USER_ID)
          expect(spotify_client).not_to receive(:get_access_token!)
        end
      end

      context 'access token is not present' do

        let!(:user_token_data) { SpotifyUserToken.create(user_id: described_class::DEFAULT_USER_ID) }

        context 'oauth_code is present' do
          before do
            user_token_data.oauth_code = '1234'
            user_token_data.save!
          end
          it 'calls get_access_token!' do
            SpotifyClient.any_instance.stub(:get_access_token!).and_return(nil)
            expect(described_class.new(user_id: described_class::DEFAULT_USER_ID)).to receive(:get_access_token!)
            # spotify_client = described_class.new(user_id: described_class::DEFAULT_USER_ID)
          end
        end

        context 'oauth_code is not present' do
          it 'raises an exception' do
          end
        end
      end
    end

    context 'user token does not exist' do
      it 'gets created' do
      end
    end
  end
end
