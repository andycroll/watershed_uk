# frozen_string_literal: true

require 'net/http'

module WatershedUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Requests to Ticketsolve
    module Http
      TIMEOUT = 30
      RETRIES = 2
      USER_AGENT = 'Mozilla/5.0 (compatible; watershed_uk; +https://github.com/andycroll/watershed_uk)'
      TRANSIENT_ERRORS = [
        EOFError, Errno::ECONNRESET, Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError
      ].freeze

      private

      def get(url)
        uri = URI(url)
        attempts = 0
        begin
          response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: TIMEOUT, read_timeout: TIMEOUT) do |http|
            http.request(Net::HTTP::Get.new(uri, 'User-Agent' => USER_AGENT))
          end
        rescue *TRANSIENT_ERRORS
          attempts += 1
          raise if attempts > RETRIES

          sleep(attempts)
          retry
        end
        # Omit response bodies from errors, and never follow redirects.
        raise "Ticketsolve HTTP error #{response.code}" unless response.is_a?(Net::HTTPSuccess)

        String.new(response.body, encoding: Encoding::UTF_8)
      end
    end
  end
end
