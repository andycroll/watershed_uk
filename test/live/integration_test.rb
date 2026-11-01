require_relative 'live_helper'

class LiveIntegrationTest < Minitest::Test
  def test_watershed_has_performances
    today = Date.today
    performances = WatershedUk::Performance.at('watershed', from: today, to: today + 365)

    assert(performances.all? { |p| p.instance_of?(WatershedUk::Performance) })
    assert_operator performances.count, :>, 50
    assert_operator performances.map(&:showing_on).max, :>, today + 30
    assert(performances.filter_map(&:booking_url).all? { |url| url.match?(ApiShapes::BOOKING_URL) })
    refute(performances.any? { |p| p.film_name.match?(WatershedUk::Internal::TitleSanitizer::CERTIFICATE) })
  end
end
