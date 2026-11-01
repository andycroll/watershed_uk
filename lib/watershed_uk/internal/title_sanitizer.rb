module WatershedUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Sanitize and standardize film titles
    class TitleSanitizer < Cinebase::TitleSanitizer
      # @!method initialize(title)
      #   Constructor
      #   @param [String] title a film title
      #   @return [WatershedUk::Internal::TitleSanitizer]

      # @!method sanitized
      #   sanitized and standardized title
      #   @return [String] sanitised title

      # BBFC certificate, or CTBA when it is yet to be announced, e.g. '(15)',
      # '(18 CTBA)' or '(18) CTBA'
      CERTIFICATE = /\((?:U|PG|12A?|15|18|CTBA)(?: CTBA)?\)(?:\s*CTBA)?/

      private

      # strings and regex to be removed
      def remove
        [
          /\s*#{CERTIFICATE}(?:\s+P?S)?\s*\z/,    # certificate, then (partly) subtitled
          /\A[^:]+ presents:\s*/i,                 # presenter
          /\A[^:]+ x Watershed:\s*/i,              # partner
          /\A(?:Preview|Bristol Surf Cinema|Sonic Cinema):\s*/i, # strand
          /\s*\(35mm [^)]*\)/i,                    # film print tour
          /\s*\(Director[’']s Cut\)/i,             # cut
          /\s*\+\s*panel discussion\z/i            # panel add-on
        ] + COMMON_REMOVE
      end

      # regexes and their replacements
      def replace
        {
          /\A(?:NT|National Theatre) Live:\s*(.*)/ => 'National Theatre Live: '
        }.merge(COMMON_REPLACE)
      end
    end
  end
end
