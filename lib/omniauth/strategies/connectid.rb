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
        profile = Hash.from_xml(raw_info)["profile"]

        if profile["credential"]["credentialType"] == "A"
          email = profile["credential"]["credential"]
          mobile = profile["phoneNumbers"]["phoneNumber"]["phoneNumber"]
        else
          email = Array(profile["emails"]["email"]).first
          mobile = profile["credential"]["credential"]
        end

        {
          :email => email,
          :mobile => mobile
        }
      end

      extra do
        subscriptions = Hash.from_xml(raw_subscription_info)["subscriptions"]["subscription"]
        subscriptions = [subscriptions] if subscriptions.class == Hash
        {
          :subscriptions => subscriptions
        }
      end

      def raw_info
        @raw_info ||= access_token.get('https://api.mediaconnect.no/capi/v1/customer/profile').body
      end

      def raw_subscription_info
        @raw_subscription_info ||= access_token.get('https://api.mediaconnect.no/capi/v1/subscription').body
      end
    end
  end
end
