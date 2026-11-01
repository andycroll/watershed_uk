require_relative 'fixtures_helper'

# Serve the fixture in place of Watershed's Ticketsolve feed
module FeedStubs
  include FixturesHelper

  FEED_URL = WatershedUk::Internal::Ticketsolve::FEED_URL

  private

  def stub_feed(body = read_fixture('shows.xml'))
    stub_request(:get, FEED_URL).to_return(status: 200, body: body)
  end
end
