module WatershedUk
  # The object representing the Watershed cinema in Bristol
  class Cinema < Cinebase::Cinema
    # @!attribute [r] id
    #   @return [String] the cinema's id, 'watershed'

    # Watershed is one venue, sold through Ticketsolve alongside its partner
    # venues and event spaces. The address is from the website's footer, the
    # coordinates from the cinema's OpenStreetMap node 12973154703.
    VENUES = {
      'watershed' => {
        name: 'Watershed', ticketsolve_venue_id: '426565625',
        street_address: '1 Canons Road', extended_address: 'Harbourside', locality: 'Bristol',
        postal_code: 'BS1 5TX', latitude: 51.4517753, longitude: -2.598143
      }
    }.freeze

    ADDRESS_PARTS = %i(street_address extended_address locality region postal_code).freeze
    URL = 'https://www.watershed.co.uk'.freeze

    # Constructor
    # @param [String] id the cinema's id, 'watershed'
    # @return [WatershedUk::Cinema]
    def initialize(id)
      @id = id.to_s.downcase
    end

    # Return basic cinema information for all cinemas
    # @return [Array<WatershedUk::Cinema>]
    # @example
    #   WatershedUk::Cinema.all
    #   #=> [<WatershedUk::Cinema>]
    def self.all
      VENUES.keys.map { |id| new(id) }
    end

    # @!method address
    #   Address of the cinema
    #   @return [Hash] of different address parts
    #   @see #adr

    # Address of the cinema
    # @return [Hash] contains :street_address, :extended_address,
    # :locality, :region, :postal_code, :country_name
    # @example
    #   cinema = WatershedUk::Cinema.new('watershed')
    #   cinema.adr
    #   #=> {
    #         street_address:   '1 Canons Road',
    #         extended_address: 'Harbourside',
    #         locality:         'Bristol',
    #         region:           nil,
    #         postal_code:      'BS1 5TX',
    #         country_name:     'United Kingdom'
    #       }
    # @note Uses method naming as at http://microformats.org/wiki/adr
    def adr
      ADDRESS_PARTS.to_h { |part| [part, venue[part]] }.merge(country_name: 'United Kingdom')
    end

    # Brand of the cinema
    # @return [String] which will always be 'Independent'
    def brand
      'Independent'.freeze
    end

    # @return [Float, nil]
    def latitude
      venue[:latitude]
    end

    # @return [Float, nil]
    def longitude
      venue[:longitude]
    end

    # The name of the cinema
    # @return [String]
    # @example
    #   WatershedUk::Cinema.new('watershed').name
    #   #=> 'Watershed'
    def name
      venue[:name].to_s
    end

    # The url of the cinema's website
    # @return [String]
    # @example
    #   WatershedUk::Cinema.new('watershed').url
    #   #=> 'https://www.watershed.co.uk'
    def url
      venue.empty? ? '' : URL
    end

    # @api private
    # @return [String, nil] the venue's id in the Ticketsolve feed
    def ticketsolve_venue_id
      venue[:ticketsolve_venue_id]
    end

    private

    def venue
      VENUES.fetch(id, {})
    end
  end
end
