module WatershedUk
  # A single screening of a film at the Watershed cinema
  class Performance < Cinebase::Performance
    # @!attribute [r] booking_url
    #   @return [String, nil] the Ticketsolve booking URL, nil when sold out
    # @!attribute [r] cinema_name
    #   @return [String] the cinema name
    # @!attribute [r] cinema_id
    #   @return [String] the cinema id
    # @!attribute [r] dimension
    #   @return [String] 2d or 3d
    # @!attribute [r] film_name
    #   @return [String] the film name

    # @!method initialize(options)
    #   @param [Hash] options options hash
    #   @option options [String] :booking_url (nil) buying url for the screening
    #   @option options [String] :cinema_name name of the cinema
    #   @option options [String] :cinema_id website id of the cinema
    #   @option options [String] :dimension ('2d') dimension of the screening
    #   @option options [Cinebase::Festival] :festival (nil) festival edition
    #   @option options [String] :film_name name of the film
    #   @option options [Integer] :film_year (nil) year from the film's title
    #   @option options [Time] :starting_at listed start time of the performance

    # Performances within an inclusive range of showing dates. The Ticketsolve
    # feed holds every advertised date, so any range is one request.
    # @param [String] cinema_id the cinema's id, 'watershed'
    # @param [Date] from first date (defaults to today in London)
    # @param [Date] to last date (defaults to 13 days after from)
    # @return [Array<WatershedUk::Performance>]
    def self.at(
      cinema_id,
      from: Cinebase::London.today,
      to: from + 13
    )
      raise ArgumentError, 'to must not precede from' if to < from

      cinema = Cinema.new(cinema_id)
      if cinema.name.empty?
        []
      else
        venues = Internal::Parser::Feed.new(Internal::Ticketsolve.new.feed).venues
        shows = venues.select { |venue| venue.id == cinema.ticketsolve_venue_id }.flat_map(&:shows)
        performances = screenings(shows, from..to).map do |screening|
          new(screening.to_hash.merge(cinema_id: cinema.id, cinema_name: cinema.name))
        end
        performances.sort_by(&:starting_at)
      end
    end

    # @!method showing_on
    #   The date of the screening
    #   @return [Date]

    # @!method starting_at
    #   UTC time of the screening
    #   @return [Time]

    # @!method variant
    #   The kinds of screening (35mm, arts, audio_described, baby, q&a,
    #   relaxed, subtitled)
    #   @return <Array[String]>

    def self.screenings(shows, dates)
      shows.select { |show| Internal::Parser::Screening.film?(show) }.flat_map do |show|
        show.events
            .select { |event| dates.cover?(Cinebase::London.date(event.starting_at)) }
            .map { |event| Internal::Parser::Screening.new(show, event) }
      end
    end
    private_class_method :screenings
  end
end
