require "spec_helper"

describe MaintainsController do
  describe "routing" do

    it "routes to #index" do
      get("/maintains").should route_to("maintains#index")
    end

    it "routes to #new" do
      get("/maintains/new").should route_to("maintains#new")
    end

    it "routes to #show" do
      get("/maintains/1").should route_to("maintains#show", :id => "1")
    end

    it "routes to #edit" do
      get("/maintains/1/edit").should route_to("maintains#edit", :id => "1")
    end

    it "routes to #create" do
      post("/maintains").should route_to("maintains#create")
    end

    it "routes to #update" do
      put("/maintains/1").should route_to("maintains#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/maintains/1").should route_to("maintains#destroy", :id => "1")
    end

  end
end
