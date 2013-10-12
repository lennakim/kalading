require 'spec_helper'

describe "Partbatches" do
  describe "GET /partbatches" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get partbatches_path
      response.status.should be(200)
    end
  end
end
