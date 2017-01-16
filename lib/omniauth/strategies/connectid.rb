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

        name = {
          :first_name => "",
          :middle_name => "",
          :last_name => ""
        }

        if profile["name"].present?
          name = {
            :first_name => profile["name"]["firstName"] ? profile["name"]["firstName"] : "",
            :middle_name => profile["name"]["middleName"] ? profile["name"]["middleName"] : "",
            :last_name => profile["name"]["lastName"] ? profile["name"]["lastName"] : ""
          }
        end


        {
          :email => email.present? ? email : "",
          :mobile => mobile.present ? mobile : "",
          :name => name
        }
      end

      extra do
        subscriptions = []

        if raw_subscription_info
          subscriptions = Hash.from_xml(raw_subscription_info)["subscriptions"]["subscription"]

          if subscriptions.class == Hash
            subscriptions = [subscriptions]
          end
        end

        {
          :subscriptions => subscriptions
        }
      end

      def raw_info
        begin
          @raw_info ||= access_token.get('https://api.mediaconnect.no/capi/v1/customer/profile').body
        rescue => e
        end
      end

      def raw_subscription_info
        begin
          @raw_subscription_info ||= access_token.get('https://api.mediaconnect.no/capi/v1/subscription').body
        rescue => e
        end
      end
    end
  end
end
