require "spec_helper"

describe AutoBrandsController do
  describe "routing" do

    it "routes to #index" do
      get("/auto_brands").should route_to("auto_brands#index")
    end

    it "routes to #new" do
      get("/auto_brands/new").should route_to("auto_brands#new")
    end

    it "routes to #show" do
      get("/auto_brands/1").should route_to("auto_brands#show", :id => "1")
    end

    it "routes to #edit" do
      get("/auto_brands/1/edit").should route_to("auto_brands#edit", :id => "1")
    end

    it "routes to #create" do
      post("/auto_brands").should route_to("auto_brands#create")
    end

    it "routes to #update" do
      put("/auto_brands/1").should route_to("auto_brands#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/auto_brands/1").should route_to("auto_brands#destroy", :id => "1")
    end

  end
end
