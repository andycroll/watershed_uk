require_relative '../../../test_helper'

class WatershedUk::Internal::TicketsolveTest < Minitest::Test
  include FeedStubs

  def setup
    @ticketsolve = WatershedUk::Internal::Ticketsolve.new
  end

  def test_feed_is_the_shows_document
    stub_feed

    assert_equal read_fixture('shows.xml'), @ticketsolve.feed
    assert_requested :get, FEED_URL, headers: { 'User-Agent' => WatershedUk::Internal::Ticketsolve::USER_AGENT }
  end

  def test_errors_name_the_status_but_not_the_body
    stub_request(:get, FEED_URL).to_return(status: 500, body: 'secret')

    error = assert_raises(RuntimeError) { @ticketsolve.feed }
    assert_equal 'HTTP error 500 from watershed.ticketsolve.com', error.message
  end

  def test_transient_errors_are_retried
    stub_request(:get, FEED_URL).to_raise(Errno::ECONNRESET).then.to_return(status: 200, body: '<venues/>')

    Cinebase::Http.stub(:pause, nil) { @ticketsolve.feed }

    assert_requested :get, FEED_URL, times: 2
  end
end
