require "spec_helper"

describe PartbatchesController do
  describe "routing" do

    it "routes to #index" do
      get("/partbatches").should route_to("partbatches#index")
    end

    it "routes to #new" do
      get("/partbatches/new").should route_to("partbatches#new")
    end

    it "routes to #show" do
      get("/partbatches/1").should route_to("partbatches#show", :id => "1")
    end

    it "routes to #edit" do
      get("/partbatches/1/edit").should route_to("partbatches#edit", :id => "1")
    end

    it "routes to #create" do
      post("/partbatches").should route_to("partbatches#create")
    end

    it "routes to #update" do
      put("/partbatches/1").should route_to("partbatches#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/partbatches/1").should route_to("partbatches#destroy", :id => "1")
    end

  end
end
