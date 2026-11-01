# WatershedUk

A simple gem to pull cinema and performance information for [Watershed](https://www.watershed.co.uk), the independent cinema in Bristol, and spit out useful formatted info.

## Installation

Add this line to your application's Gemfile:

    gem 'watershed_uk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install watershed_uk

## Usage

The gem conforms to the API set down in the `cinebase` gem, [andycroll/cinebase](https://github.com/andycroll/cinebase), which provides a lot of useful base vocabulary and repetitive code for this series of cinema focussed gems.

Performance titles are sanitized as much as possible, removing BBFC
certificates and the `S` and `PS` (partly subtitled) markers after them,
presenter, partner, preview and strand prefixes (`Bristol Bad Film Club
presents:`, `Spike Island x Watershed:`, `Preview:`, `Bristol Surf Cinema:`,
`Sonic Cinema:`), 35mm, director's cut and anniversary markers, years, and
Q&A and panel discussion add-ons, and naming National Theatre Live and Royal
Ballet and Opera screenings in full.

No token or setup is needed. Watershed sells tickets through Ticketsolve,
whose public XML feed lists every show on sale.

### Cinema

Watershed is one venue. The feed names it but gives no address, so the gem
holds it: the address from the website's footer and coordinates from
OpenStreetMap. Cinema methods make no requests.

``` ruby
WatershedUk::Cinema.all
#=> [<WatershedUk::Cinema ...>]

cinema = WatershedUk::Cinema.new('watershed')
#=> <WatershedUk::Cinema ...>

cinema.adr
#=> {
  street_address:   '1 Canons Road',
  extended_address: 'Harbourside',
  locality:         'Bristol',
  region:           nil,
  postal_code:      'BS1 5TX',
  country_name:     'United Kingdom'
}

cinema.brand
#=> 'Independent'

cinema.name
#=> 'Watershed'

cinema.full_name
#=> 'Independent Watershed'

cinema.id
#=> 'watershed'

cinema.latitude
#=> 51.4517753

cinema.longitude
#=> -2.598143

cinema.url
#=> 'https://www.watershed.co.uk'
```

### Performances

`Performance.at` returns performances for an inclusive range of showing dates,
defaulting to today in London and the following 13 days. The Ticketsolve feed
holds every advertised date, about six months ahead, so any range is one
request of about 320 KB.

``` ruby
WatershedUk::Performance.at('watershed', from: Date.today, to: Date.today + 2)
#=> [<WatershedUk::Performance ...>, <WatershedUk::Performance ...>, ...]

performance = WatershedUk::Performance.at('watershed').first
#=> <WatershedUk::Performance ...>

performance.film_name
#=> 'Daïchi Saïto' # from 'Sonic Cinema: Daïchi Saïto (35mm) (18 CTBA)'

performance.film_year
#=> nil # from the title, e.g. 1983 for 'The Store (1983) (18 CTBA)'

performance.dimension
#=> '2d'

performance.variant
#=> ['35mm', 'q&a']

performance.subtitled?
#=> false

performance.festival
#=> nil # e.g. #<data Cinebase::Festival name="Afrika Eye", year=2026>

performance.starting_at
#=> 2026-11-26 18:30:00 UTC

performance.booking_url
#=> 'https://watershed.ticketsolve.com/shows/1173695141/events/428916513'

performance.cinema_name
#=> 'Watershed'

performance.cinema_id
#=> 'watershed'
```

Booking links are each event's Ticketsolve page, which leads to ticket and
seat selection. Sold out performances have no booking link.

Only films at Watershed itself are returned. The feed also holds Watershed's
partner venues, its event spaces and the Pervasive Media Studio, which the gem
skips. Within the cinema it keeps the `Film` and `Event Cinema` categories,
and shows with no category that have a certificate in their name. Talks,
workshops, other events and seat sponsorships are dropped. Screenings with
an introduction, a Q&A or a panel are films.

Variants come from show tags, each event's comment and titles: `subtitled`
(descriptive subtitles or captions), `relaxed`, `baby` (parents and carers
of babies), `audio_described`, `35mm`, `arts` (National Theatre Live and
other event cinema) and `q&a`. Films subtitled from another language are
not a variant.

Festival tags name Afrika Eye and the Bristol Palestine Film Festival
editions.

## Tests

```sh
bundle exec rake          # unit tests against fixtures
bundle exec rake live     # live Ticketsolve feed
```

The fixture in `test/fixtures` is the Ticketsolve feed, trimmed to a few
shows at three of its venues, a few events each and no descriptions or
images. `test/support/api_shapes.rb` describes the parts the gem reads. The
unit suite checks the fixture against it and the live suite checks the real
feed, held only in memory. When the feed changes, update the shape first,
then the fixture.

## Releasing

Bump the version, merge, then run the **Release Gem** workflow in GitHub
Actions. It runs the tests, tags the version and publishes the gem through
RubyGems trusted publishing.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
