require_relative '../../test_helper'

class WatershedUk::PerformanceTest < Minitest::Test
  include FeedStubs

  FROM = Date.new(2026, 11, 1)
  BOOKING = 'https://watershed.ticketsolve.com/shows/'.freeze

  def test_at_returns_film_performances_in_time_order
    stub_feed

    performances = performances_at('watershed')

    assert(performances.all? { |p| p.instance_of?(WatershedUk::Performance) })
    assert_equal 32, performances.count
    assert_equal performances.map(&:starting_at).sort, performances.map(&:starting_at)
  end

  def test_at_reads_every_date_from_one_request
    stub_feed

    performances_at('WATERSHED')

    assert_requested :get, FEED_URL, times: 1
  end

  def test_at_keeps_to_the_range
    stub_feed

    assert_equal 3, WatershedUk::Performance.at('watershed', from: FROM, to: FROM).count
  end

  def test_at_sets_cinema_details
    stub_feed

    performances = performances_at('watershed')

    assert_equal ['watershed'], performances.map(&:cinema_id).uniq
    assert_equal ['Watershed'], performances.map(&:cinema_name).uniq
  end

  def test_at_parses_first_performance
    stub_feed

    performance = performances_at('watershed').first

    assert_equal 'Wildwood', performance.film_name
    assert_nil performance.film_year
    assert_equal Time.utc(2026, 11, 1, 11, 10), performance.starting_at
    assert_equal '2d', performance.dimension
    assert_empty performance.variant
    assert_nil performance.festival
    assert_equal "#{BOOKING}1173694175/events/428918121", performance.booking_url
  end

  def test_summer_times_are_converted_to_utc
    stub_feed

    performance = performances_at('watershed').last

    assert_equal 'Chungking Express', performance.film_name
    assert_equal Time.utc(2027, 5, 1, 17, 0), performance.starting_at
  end

  def test_dates_are_london_dates
    stub_feed(late_screening_feed)

    assert_equal 1, WatershedUk::Performance.at('watershed', from: Date.new(2027, 5, 2), to: Date.new(2027, 5, 2)).count
    assert_empty WatershedUk::Performance.at('watershed', from: Date.new(2027, 5, 1), to: Date.new(2027, 5, 1))
  end

  def test_sold_out_performances_have_no_booking_url
    stub_feed

    performance = performances_at('watershed').detect { |p| p.starting_at == Time.utc(2026, 11, 20, 17, 10) }

    assert_equal 'You Can See Everything', performance.film_name
    assert_nil performance.booking_url
  end

  def test_talks_events_and_partner_venues_are_dropped
    stub_feed

    names = performances_at('watershed').map(&:film_name)

    refute_includes names, 'Very Normal Talk'
    refute_includes names, 'The Puppet Folk Experience – Christmas Special'
    refute_includes names, 'Amazing Grace: YorubaWorlds'
  end

  def test_films_without_a_category_are_kept
    stub_feed

    performance = find('428913571')

    assert_equal 'Congo Boy', performance.film_name
    assert_equal Cinebase::Festival.new(name: 'Afrika Eye', year: 2026), performance.festival
  end

  def test_variants_come_from_tags_comments_and_titles
    stub_feed

    assert_equal %w(audio_described relaxed subtitled), find('428904525').variant
    assert_equal %w(baby subtitled), find('428916332').variant
    assert_equal %w(35mm q&a), find('428916513').variant
    assert_equal %w(q&a), find('428911139').variant
  end

  def test_national_theatre_live_is_named_and_arts
    stub_feed

    performance = find('428882883')

    assert_equal 'Golden Boy', performance.film_name
    assert_equal 'National Theatre Live', performance.event.name
    assert_equal %w(arts), performance.variant
  end

  def test_unknown_cinema_makes_no_request
    assert_empty WatershedUk::Performance.at('zzz', from: FROM, to: FROM)
    assert_not_requested :get, FEED_URL
  end

  def test_to_must_not_precede_from
    assert_raises(ArgumentError) { WatershedUk::Performance.at('watershed', from: FROM, to: FROM - 1) }
  end

  private

  def performances_at(cinema_id)
    WatershedUk::Performance.at(cinema_id, from: FROM, to: FROM >> 12)
  end

  def find(event_id)
    performances_at('watershed').detect { |p| p.booking_url.to_s.end_with?("/#{event_id}") }
  end

  # 00:30 on 2 May in London is still 1 May in UTC
  def late_screening_feed
    read_fixture('shows.xml').sub('2027-05-01T18:00:00+01:00', '2027-05-02T00:30:00+01:00')
  end
end
