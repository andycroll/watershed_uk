require_relative '../../../../test_helper'

class WatershedUk::Internal::Parser::ScreeningTest < Minitest::Test
  Feed = WatershedUk::Internal::Parser::Feed
  Screening = WatershedUk::Internal::Parser::Screening

  def test_film_categories_are_films
    assert Screening.film?(show(category: 'Film'))
    assert Screening.film?(show(category: 'Event Cinema'))
  end

  def test_other_categories_are_not_films
    %w(Event Workshop Lunchtime\ Talk Seat\ Sponsorship).each do |category|
      refute Screening.film?(show(name: 'Wildwood (12A)', category: category)), category
    end
  end

  def test_shows_without_a_category_are_films_when_certificated
    assert Screening.film?(show(name: 'Congo Boy (18) CTBA'))
    refute Screening.film?(show(name: 'Supporters Evening 2026'))
  end

  def test_three_d_titles
    assert_equal '3d', to_hash(show(name: 'Avatar 3D (12A)'))[:dimension]
  end

  def test_film_years_come_from_titles
    hash = to_hash(show(name: 'The Store (1983) (18 CTBA)'))

    assert_equal 'The Store', hash[:film_name]
    assert_equal 1983, hash[:film_year]
  end

  def test_titled_national_theatre_live_is_not_prefixed_twice
    hash = to_hash(show(name: 'NT Live: Hamlet (12A)', tags: %w(ntl)))

    assert_equal 'National Theatre Live: Hamlet', hash[:film_name]
  end

  def test_festivals_come_from_tags
    hash = to_hash(show(name: 'Concrete Land (18) S', tags: %w(bpff27_palestine main)))

    assert_equal Cinebase::Festival.new(name: 'Bristol Palestine Film Festival', year: 2027), hash[:festival]
  end

  def test_festivals_come_from_titles
    hash = to_hash(show(name: 'CFF: Fjord (15)'))

    assert_equal Cinebase::Festival.new(name: 'CFF', year: 2026), hash[:festival]
    assert_equal 'Fjord', hash[:film_name]
  end

  private

  def show(name: 'Wildwood (12A)', category: '', tags: [])
    event = Feed::Event.new(id: '1', starting_at: Time.utc(2026, 11, 1, 11), status: 'available', comment: '',
                            url: 'https://watershed.ticketsolve.com/shows/2/events/1')
    Feed::Show.new(id: '2', name: name, category: category, tags: tags,
                   url: 'https://watershed.ticketsolve.com/shows/2/events', events: [event])
  end

  def to_hash(show)
    Screening.new(show, show.events.first).to_hash
  end
end
