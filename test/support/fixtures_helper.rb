# Read fixtures from disk: Watershed's Ticketsolve feed, trimmed to a few
# shows at three of its venues, a few events each and no descriptions or
# images. It follows the shape in api_shapes.rb.
module FixturesHelper
  private

  def read_fixture(filepath)
    File.read(File.expand_path("../../fixtures/#{filepath}", __FILE__))
  end
end
