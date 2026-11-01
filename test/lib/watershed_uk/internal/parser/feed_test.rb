require_relative '../../../../test_helper'

class WatershedUk::Internal::Parser::FeedTest < Minitest::Test
  include FixturesHelper

  def setup
    @venues = WatershedUk::Internal::Parser::Feed.new(read_fixture('shows.xml')).venues
  end

  def test_venues
    assert_equal %w(426567511 426565722 426565625), @venues.map(&:id)
    assert_equal ['Easton Community Centre', 'Pervasive Media Studio', 'Watershed Cinemas'], @venues.map(&:name)
  end

  def test_shows
    show = @venues.last.shows.first

    assert_equal '1173694824', show.id
    assert_equal 'Bristol Bad Film Club presents: Dial Code Santa Claus (18 CTBA) S', show.name
    assert_equal 'Film', show.category
    assert_equal %w(bristol_bad_film_club dial_code_santa_claus main rep_screening), show.tags
    assert_match %r{\Ahttps://watershed\.ticketsolve\.com/shows/\d+/events\z}, show.url
  end

  def test_categories_may_be_empty
    show = @venues.first.shows.first

    assert_equal '', show.category
  end

  def test_events
    event = @venues.last.shows.first.events.first

    assert_equal '428912381', event.id
    assert_equal Time.utc(2026, 12, 19, 20, 0), event.starting_at
    assert_predicate event.starting_at, :utc?
    assert_equal 'available', event.status
    assert_match(/\AThis event will start at the advertised screening time/, event.comment)
    assert_match %r{/events/428912381\z}, event.url
  end

  def test_missing_elements_read_as_empty
    xml = '<venues><venue id="1"><shows><show id="2"><name>Film</name><events>' \
          '<event id="3"><date_time_iso>2026-11-01T11:00:00+00:00</date_time_iso></event>' \
          '</events></show></shows></venue></venues>'

    venue = WatershedUk::Internal::Parser::Feed.new(xml).venues.first
    show = venue.shows.first

    assert_equal '', venue.name
    assert_equal '', show.category
    assert_empty show.tags
    assert_equal '', show.events.first.comment
  end
end
