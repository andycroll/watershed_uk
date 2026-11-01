# frozen_string_literal: true

module WatershedUk
  # @api private
  module Internal
    module Parser
      # Reads one Ticketsolve event of a Watershed show as a film screening
      class Screening
        # Watershed's categories for screenings, including broadcasts such as
        # National Theatre Live. Talks, workshops and other events have their
        # own categories.
        FILM_CATEGORIES = ['Film', 'Event Cinema'].freeze

        SOLD_OUT = 'sold out'

        CATEGORY_VARIANTS = { 'Event Cinema' => 'arts' }.freeze
        TAG_VARIANTS = { '35mm' => '35mm', 'audio_description' => 'audio_described', 'ntl' => 'arts' }.freeze

        # The box office notes each event's access and extras in its comment,
        # e.g. 'This screening has descriptive subtitles'
        COMMENT_VARIANTS = {
          /descriptive subtitles|captioned/i => 'subtitled',
          /\bbabies\b/i => 'baby',
          /\brelaxed screening\b/i => 'relaxed',
          /\bQ&A\b/ => 'q&a'
        }.freeze
        TITLE_VARIANTS = { /\(35mm\b/i => '35mm', /\bQ&A\b/ => 'q&a' }.freeze

        # Festival tags carry a two digit year, e.g. 'afrika_eye_ae26'
        FESTIVAL_TAGS = {
          /\Aafrika_eye_ae(\d{2})\z/ => 'Afrika Eye',
          /\Abpff(\d{2})_/ => 'Bristol Palestine Film Festival'
        }.freeze

        # National Theatre Live shows are tagged, and often untitled as such
        NT_LIVE_TAG = 'ntl'
        NT_LIVE = /\A(?:NT|National Theatre) Live:/
        THREE_D = /\b3D\b/i

        # @param [Feed::Show] show
        # @return [Boolean] whether the show is a film, rather than a talk,
        #   workshop or other event. Some films have no category, but every
        #   film has a certificate in its name.
        def self.film?(show)
          if show.category.empty?
            show.name.match?(TitleSanitizer::CERTIFICATE)
          else
            FILM_CATEGORIES.include?(show.category)
          end
        end

        # @param [Feed::Show] show the film
        # @param [Feed::Event] event one screening of it
        def initialize(show, event)
          @show = show
          @event = event
        end

        # @return [Hash] options for WatershedUk::Performance.new
        def to_hash
          {
            booking_url: @event.status == SOLD_OUT ? nil : @event.url,
            dimension: @show.name.match?(THREE_D) ? '3d' : '2d',
            festival: festival,
            film_name: TitleSanitizer.new(title).sanitized,
            film_year: Cinebase::TitleSanitizer.film_year(title),
            starting_at: @event.starting_at,
            variant: variant
          }
        end

        private

        def festival
          FESTIVAL_TAGS.each do |pattern, name|
            tag = @show.tags.grep(pattern).first
            return Cinebase::Festival.new(name: name, year: 2000 + tag[pattern, 1].to_i) if tag
          end
          Cinebase::Festival.from_title(title, year: @event.starting_at.year)
        end

        def title
          if @show.tags.include?(NT_LIVE_TAG) && !@show.name.match?(NT_LIVE)
            "NT Live: #{@show.name}"
          else
            @show.name
          end
        end

        def variant
          variants = @show.tags.filter_map { |tag| TAG_VARIANTS[tag] }
          variants << CATEGORY_VARIANTS[@show.category]
          variants += COMMENT_VARIANTS.filter_map { |pattern, variant| variant if @event.comment.match?(pattern) }
          variants += TITLE_VARIANTS.filter_map { |pattern, variant| variant if @show.name.match?(pattern) }
          variants.compact.uniq
        end
      end
    end
  end
end
