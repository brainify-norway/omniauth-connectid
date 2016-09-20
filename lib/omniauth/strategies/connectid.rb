require 'multi_json'
require 'jwt'
require 'omniauth/strategies/oauth2'
require 'uri'

module OmniAuth
  module Strategies
    class Connectid < OmniAuth::Strategies::OAuth2
      option :name, "connectid"
      option :client_options, {
        :site          => 'https://connectid.no',
        :authorize_url => '/user/oauth/authorize',
        :token_url     => '/user/oauth/token'
      }

      uid {
        raw_info['userId']
      }

      info do
        if raw_info["credential"]["credentialType"] == "A"
          email = raw_info["credential"]["credential"]
          mobile = raw_info["phoneNumbers"]["phoneNumber"]["phoneNumber"]
        else
          email = Array(raw_info["emails"]["email"]).first
          mobile = raw_info["credential"]["credential"]
        end

        {
          :email => email,
          :mobile => mobile
        }
      end

      extra do
        {
          :raw_info => raw_info,
          :raw_subscriptions_info => raw_subscription_info
        }
      end

      def raw_info
        @raw_info ||= Hash.from_xml(access_token.get('https://api.mediaconnect.no/capi/v1/customer/profile').body)["profile"]
      end

      def raw_subscription_info
        @raw_subscription_info ||= Hash.from_xml(access_token.get('https://api.mediaconnect.no/capi/v1/subscription').body)["subscriptions"]
      end
    end
  end
end
