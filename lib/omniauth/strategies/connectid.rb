require 'multi_json'
require 'jwt'
require 'omniauth/strategies/oauth2'
require 'uri'

module OmniAuth
  module Strategies
    class Connectid < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, "connectid"

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
        :site          => 'https://connectid.no',
        :authorize_url => '/user/oauth/authorize',
        :token_url     => '/user/oauth/token'
      }

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid {
        raw_info['userId']
      }

      info do
        {
          # :name => raw_info['name']["firstName"] + ,
          :email => raw_info['credential']['credential']
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        profile = access_token.get('https://api.mediaconnect.no/capi/v1/customer/profile')
        @raw_info ||= Hash.from_xml(profile.body)["profile"]
        @raw_info
      end

    end
  end
end
