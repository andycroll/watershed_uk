require_relative '../../../test_helper'

class WatershedUk::Internal::TicketsolveTest < Minitest::Test
  include FeedStubs

  def setup
    @ticketsolve = WatershedUk::Internal::Ticketsolve.new
  end

  def test_feed_is_the_shows_document
    stub_feed

    assert_equal read_fixture('shows.xml'), @ticketsolve.feed
    assert_requested :get, FEED_URL, headers: { 'User-Agent' => WatershedUk::Internal::Http::USER_AGENT }
  end

  def test_feed_is_utf8
    stub_feed

    assert_equal Encoding::UTF_8, @ticketsolve.feed.encoding
  end

  def test_errors_name_the_status_but_not_the_body
    stub_request(:get, FEED_URL).to_return(status: 500, body: 'secret')

    error = assert_raises(RuntimeError) { @ticketsolve.feed }
    assert_equal 'Ticketsolve HTTP error 500', error.message
  end

  def test_redirects_are_not_followed
    stub_request(:get, FEED_URL).to_return(status: 302, headers: { 'Location' => 'https://watershed.ticketsolve.com/' })

    assert_raises(RuntimeError) { @ticketsolve.feed }
  end

  def test_transient_errors_are_retried
    stub_request(:get, FEED_URL).to_raise(Errno::ECONNRESET).then.to_return(status: 200, body: '<venues/>')

    @ticketsolve.stub(:sleep, nil) { @ticketsolve.feed }

    assert_requested :get, FEED_URL, times: 2
  end

  def test_retries_give_up
    stub_request(:get, FEED_URL).to_raise(Net::ReadTimeout)

    assert_raises(Net::ReadTimeout) { @ticketsolve.stub(:sleep, nil) { @ticketsolve.feed } }
    assert_requested :get, FEED_URL, times: 3
  end
end
