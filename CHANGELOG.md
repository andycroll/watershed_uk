# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.0.1] - 2026-11-02

### Changed
- Requests and London times use cinebase 5.8's `Cinebase::Http` and `Cinebase::London`.
- HTTP errors read "HTTP error 500 from watershed.ticketsolve.com" rather than "Ticketsolve HTTP error 500".
- Connections give up after 10 seconds rather than 30; responses still have 30 seconds.

## [1.0.0] - 2026-11-02

### Added
- `WatershedUk::Cinema.all` and `WatershedUk::Cinema.new(id)` for Watershed in Bristol, keyed `'watershed'`, with the address from the website's footer and coordinates from OpenStreetMap.
- `WatershedUk::Performance.at(id, from:, to:)`, from Watershed's Ticketsolve feed, which holds every advertised date in one request, with booking links, variants from tags, event comments and titles, and Afrika Eye and Bristol Palestine Film Festival screenings. Partner venues, talks, workshops, events and seat sponsorships are dropped.
- A fixture trimmed from the live feed, a live shape test that checks the real feed without storing it, and GitHub Actions CI and release workflows.
