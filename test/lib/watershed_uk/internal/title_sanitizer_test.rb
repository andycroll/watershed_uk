require_relative '../../../test_helper'

class WatershedUk::Internal::TitleSanitizerTest < Minitest::Test
  def test_plain_titles_are_unchanged
    assert_sanitized 'Peter Wollen: Arrows of Desire + Friendship’s Death', 'Peter Wollen: Arrows of Desire + Friendship’s Death'
    assert_sanitized 'Play Me Something + Ways of Listening', 'Play Me Something + Ways of Listening'
  end

  def test_certificates
    assert_sanitized 'A Muppet Christmas Carol', 'A Muppet Christmas Carol (U)'
    assert_sanitized 'Wildwood', 'Wildwood (12A)'
    assert_sanitized 'Being Heumann', 'Being Heumann (18 CTBA)'
    assert_sanitized 'Congo Boy', 'Congo Boy (18) CTBA'
  end

  def test_subtitled_markers_after_certificates
    assert_sanitized 'Fjord', 'Fjord (15) S'
    assert_sanitized 'American Doctor', 'American Doctor  (18) PS'
    assert_sanitized 'Dial Code Santa Claus', 'Bristol Bad Film Club presents: Dial Code Santa Claus (18 CTBA) S'
  end

  def test_presenter_partner_and_strand_prefixes
    assert_sanitized '2026 Film London Jarman Award', 'Spike Island x Watershed: 2026 Film London Jarman Award (18) CTBA'
    assert_sanitized 'The History of Concrete', 'Preview: The History of Concrete (18 CTBA) PS'
    assert_sanitized 'The Big Sea', 'Bristol Surf Cinema: The Big Sea (15)'
    assert_sanitized 'Daïchi Saïto', 'Sonic Cinema: Daïchi Saïto (35mm) (18 CTBA)'
  end

  def test_formats_cuts_and_anniversaries
    assert_sanitized 'Phantom Thread', 'Phantom Thread (35mm) (15)'
    assert_sanitized 'Short Cuts', 'Short Cuts (35mm UK Roadshow Tour) (18)'
    assert_sanitized 'Little Shop of Horrors', "Little Shop of Horrors (Director's Cut) (PG)"
    assert_sanitized "It's A Wonderful Life", "It's A Wonderful Life (80th Anniversary) (U)"
  end

  def test_q_and_a_and_panel_add_ons
    assert_sanitized 'I See Buildings Fall Like Lightning', 'I See Buildings Fall Like Lightning + Clio Barnard Q&A (15)'
    assert_sanitized 'Notes From the Underground + Amigo the Griot', 'Notes From the Underground + Amigo the Griot + Q&A  (18 CTBA)'
    assert_sanitized 'Landscapes of Memory', 'Landscapes of Memory + panel discussion (18)'
  end

  def test_national_theatre_live
    assert_sanitized 'National Theatre Live: Golden Boy', 'NT Live: Golden Boy (12A)'
  end

  def test_royal_ballet_and_opera
    assert_sanitized 'Royal Ballet and Opera: Swan Lake', 'RBO 2026-27: Swan Lake (12A)'
  end

  private

  def assert_sanitized(expected, title)
    assert_equal expected, WatershedUk::Internal::TitleSanitizer.new(title).sanitized
  end
end
