require 'rails_helper'

RSpec.describe "PartTransfers", :type => :request do
  describe "GET /part_transfers" do
    it "works! (now write some real specs)" do
      get part_transfers_path
      expect(response).to have_http_status(200)
    end
  end
end
