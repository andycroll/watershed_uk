require_relative 'live_helper'

# The whole feed: one request.
class LiveApiShapeTest < Minitest::Test
  include ApiShapes

  def test_feed_is_readable
    assert_feed_shape(WatershedUk::Internal::Ticketsolve.new.feed)
  end
end
