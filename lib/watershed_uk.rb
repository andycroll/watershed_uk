require 'rexml/document'
require 'time'

require 'cinebase'

require_relative './watershed_uk/version'

require_relative './watershed_uk/internal/ticketsolve'
require_relative './watershed_uk/internal/title_sanitizer'

require_relative './watershed_uk/internal/parser/feed'
require_relative './watershed_uk/internal/parser/screening'

require_relative './watershed_uk/cinema'
require_relative './watershed_uk/performance'

# watershed_uk gem
module WatershedUk
end
