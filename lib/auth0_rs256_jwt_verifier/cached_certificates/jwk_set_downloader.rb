# frozen_string_literal: true
class Auth0RS256JWTVerifier
  class CachedCertificates
    class JWKSetDownloader
      InvalidJWKSetError = Class.new(RuntimeError)

      def initialize(http)
        @http = http
      end

      def download(url)
        url = String(url)
        body = @http.get(url)

        json_body = JSON.parse(body)
        json = json_body.instance_of?(Array) ? {"keys" => json_body } : json_body
        begin
          JWKSet.new(json)
        rescue JWKSet::ParseError
          raise InvalidJWKSetError
        end
      end

      class JWKSet
        include Enumerable

        ParseError = Class.new(RuntimeError)

        def initialize(hash)
          raise ParseError if hash["keys"].is_a?(Hash)
          @keys = hash["keys"].map { |key| JWK.new(key) }
        end

        def each
          @keys.each { |key| yield key }
        end

        def inspect
          "JWKSet(#{@keys.collect(&:inspect).join(", ")})"
        end
      end
      private_constant :JWKSet
    end
    private_constant :JWKSetDownloader
  end
end
