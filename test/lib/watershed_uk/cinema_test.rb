require_relative '../../test_helper'

class WatershedUk::CinemaTest < Minitest::Test
  def test_all_returns_watershed
    cinemas = WatershedUk::Cinema.all

    assert(cinemas.all? { |cinema| cinema.instance_of?(WatershedUk::Cinema) })
    assert_equal %w(watershed), cinemas.map(&:id)
  end

  def test_new_stores_downcase_string_id
    assert_equal 'watershed', WatershedUk::Cinema.new('Watershed').id
  end

  def test_name_full_name_and_slug
    cinema = WatershedUk::Cinema.new('watershed')

    assert_equal 'Watershed', cinema.name
    assert_equal 'Independent Watershed', cinema.full_name
    assert_equal 'independent-watershed', cinema.slug
  end

  def test_brand
    assert_equal 'Independent', WatershedUk::Cinema.new('watershed').brand
  end

  def test_url
    assert_equal 'https://www.watershed.co.uk', WatershedUk::Cinema.new('watershed').url
  end

  def test_adr
    expected = {
      street_address:   '1 Canons Road',
      extended_address: 'Harbourside',
      locality:         'Bristol',
      region:           nil,
      postal_code:      'BS1 5TX',
      country_name:     'United Kingdom'
    }

    assert_equal expected, WatershedUk::Cinema.new('watershed').adr
  end

  def test_coordinates
    cinema = WatershedUk::Cinema.new('watershed')

    assert_in_delta 51.4517753, cinema.latitude
    assert_in_delta(-2.598143, cinema.longitude)
  end

  def test_ticketsolve_venue_id
    assert_equal '426565625', WatershedUk::Cinema.new('watershed').ticketsolve_venue_id
  end

  def test_unknown_cinema_has_no_details
    cinema = WatershedUk::Cinema.new('zzz')

    assert_equal '', cinema.name
    assert_equal '', cinema.url
    assert_nil cinema.latitude
    assert_nil cinema.longitude
    assert_nil cinema.ticketsolve_venue_id
  end
end
