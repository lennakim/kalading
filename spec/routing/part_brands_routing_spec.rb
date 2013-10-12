require "spec_helper"

describe PartBrandsController do
  describe "routing" do

    it "routes to #index" do
      get("/part_brands").should route_to("part_brands#index")
    end

    it "routes to #new" do
      get("/part_brands/new").should route_to("part_brands#new")
    end

    it "routes to #show" do
      get("/part_brands/1").should route_to("part_brands#show", :id => "1")
    end

    it "routes to #edit" do
      get("/part_brands/1/edit").should route_to("part_brands#edit", :id => "1")
    end

    it "routes to #create" do
      post("/part_brands").should route_to("part_brands#create")
    end

    it "routes to #update" do
      put("/part_brands/1").should route_to("part_brands#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/part_brands/1").should route_to("part_brands#destroy", :id => "1")
    end

  end
end
