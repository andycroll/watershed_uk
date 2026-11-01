# frozen_string_literal: true

module WatershedUk
  # @api private
  module Internal
    module Parser
      # Parses a Ticketsolve shows.xml feed: venues, each with its shows, each
      # with its events. Nothing here is particular to Watershed.
      class Feed
        # A Ticketsolve venue, e.g. id '426565625', name 'Watershed Cinemas'
        Venue = Data.define(:id, :name, :shows)

        # A production on sale, e.g. a film, with the tags and category the
        # box office gives it
        Show = Data.define(:id, :name, :category, :tags, :url, :events)

        # A single performance of a show, with its UTC start, its status such
        # as 'available' or 'sold out', the box office's comment and its
        # booking page
        Event = Data.define(:id, :starting_at, :status, :comment, :url)

        # @param [String] xml a shows.xml document
        def initialize(xml)
          @document = REXML::Document.new(xml)
        end

        # @return [Array<Venue>]
        def venues
          @document.get_elements('venues/venue').map do |venue|
            Venue.new(id: venue.attributes['id'], name: text(venue, 'name'),
                      shows: venue.get_elements('shows/show').map { |show| show(show) })
          end
        end

        private

        def show(show)
          Show.new(
            id: show.attributes['id'],
            name: text(show, 'name'),
            category: text(show, 'event_category'),
            tags: show.get_elements('tags/tag').map { |tag| tag.text.to_s.strip },
            url: text(show, 'url'),
            events: show.get_elements('events/event').map { |event| event(event) }
          )
        end

        def event(event)
          Event.new(
            id: event.attributes['id'],
            starting_at: Time.iso8601(text(event, 'date_time_iso')).utc,
            status: text(event, 'status'),
            comment: text(event, 'comment'),
            url: text(event, 'url')
          )
        end

        # Names and comments are CDATA sections between whitespace
        def text(element, path)
          node = element.elements[path]
          node ? node.texts.map(&:value).join.strip : ""
        end
      end
    end
  end
end
