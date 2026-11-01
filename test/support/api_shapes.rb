# The parts of the Ticketsolve feed the gem reads. Checked against the
# trimmed fixture and, in the live suite, against the real feed held only in
# memory.
module ApiShapes
  Feed = WatershedUk::Internal::Parser::Feed

  BOOKING_URL = %r{\Ahttps://watershed\.ticketsolve\.com/shows/\d+/events/\d+\z}
  # Seat sponsorships book a chosen seat
  EVENT_URL = %r{\Ahttps://watershed\.ticketsolve\.com/shows/\d+/events/\d+(?:/seats)?\z}
  STATUSES = ['available', 'sold out'].freeze

  private

  def assert_feed_shape(xml)
    venues = Feed.new(xml).venues
    venue_ids = venues.map(&:id)
    assert_includes venue_ids, WatershedUk::Cinema.new('watershed').ticketsolve_venue_id
    venue_ids.each { |id| assert_match(/\A\d+\z/, id) }

    shows = venues.flat_map(&:shows)
    refute_empty shows
    shows.each { |show| assert_show_shape(show) }
  end

  def assert_show_shape(show)
    refute_empty show.name
    assert_kind_of String, show.category
    show.tags.each { |tag| assert_match(/\A[a-z0-9_]+\z/, tag) }
    refute_empty show.events
    show.events.each do |event|
      assert_kind_of Time, event.starting_at
      assert_includes STATUSES, event.status
      assert_kind_of String, event.comment
      assert_match EVENT_URL, event.url
    end
  end
end
