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

        email = nil
        mobile = nil

        begin
          profile = Hash.from_xml(raw_info)["profile"]

          p "Profile login"
          p profile

          if profile["credential"]["credentialType"] == "A"
            email = profile["credential"]["credential"]
            if profile["phoneNumbers"].class == Hash
              if profile["phoneNumbers"]["phoneNumber"].class == Hash
                if profile["phoneNumbers"]["phoneNumber"]["phoneNumber"].class == String
                  mobile = profile["phoneNumbers"]["phoneNumber"]["phoneNumber"]
                end
              elsif profile["phoneNumbers"]["phoneNumber"].class == String
                mobile = profile["phoneNumbers"]["phoneNumber"]
              end
            end
          else
            mobile = profile["credential"]["credential"]
            if profile["emails"].class == Hash
              if profile["emails"]["email"].class == String
                email = profile["emails"]["email"]
              elsif profile["emails"]["email"].class == Array
                email = profile["emails"]["email"][0]
              end
            end
          end
        rescue TypeError => e
        rescue NoMethodError => e
        rescue => e
        end

        {
          :email => email,
          :mobile => mobile
        }
      end

      extra do
        subscriptions = []

        begin
          subscriptions = Hash.from_xml(raw_subscription_info)["subscriptions"]["subscription"]
        rescue NoMethodError => e
        end

        if subscriptions.class != Array
          subscriptions = Array(subscriptions)
        end

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
