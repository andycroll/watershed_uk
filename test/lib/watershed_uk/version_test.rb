require_relative '../../test_helper'

class WatershedUk::VersionTest < Minitest::Test
  def test_version_is_defined
    refute_nil WatershedUk::VERSION
  end
end
