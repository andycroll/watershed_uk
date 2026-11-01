# frozen_string_literal: true

module WatershedUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Reads Watershed's Ticketsolve box office
    class Ticketsolve
      include Http

      # Every show on sale at Watershed and its partner venues, with every
      # advertised event, in one public document
      FEED_URL = 'https://watershed.ticketsolve.com/shows.xml'

      # @return [String] the shows feed, parsed by {Parser::Feed}
      def feed
        get(FEED_URL)
      end
    end
  end
end
