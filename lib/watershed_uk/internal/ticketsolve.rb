# frozen_string_literal: true

module WatershedUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Reads Watershed's Ticketsolve box office
    class Ticketsolve
      USER_AGENT = 'Mozilla/5.0 (compatible; watershed_uk; +https://github.com/andycroll/watershed_uk)'

      # Every show on sale at Watershed and its partner venues, with every
      # advertised event, in one public document
      FEED_URL = 'https://watershed.ticketsolve.com/shows.xml'

      def initialize
        @http = Cinebase::Http.new(headers: { 'User-Agent' => USER_AGENT })
      end

      # @return [String] the shows feed, parsed by {Parser::Feed}
      def feed
        @http.get(FEED_URL)
      end
    end
  end
end
