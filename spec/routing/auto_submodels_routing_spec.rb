require "spec_helper"

describe AutoSubmodelsController do
  describe "routing" do

    it "routes to #index" do
      get("/auto_submodels").should route_to("auto_submodels#index")
    end

    it "routes to #new" do
      get("/auto_submodels/new").should route_to("auto_submodels#new")
    end

    it "routes to #show" do
      get("/auto_submodels/1").should route_to("auto_submodels#show", :id => "1")
    end

    it "routes to #edit" do
      get("/auto_submodels/1/edit").should route_to("auto_submodels#edit", :id => "1")
    end

    it "routes to #create" do
      post("/auto_submodels").should route_to("auto_submodels#create")
    end

    it "routes to #update" do
      put("/auto_submodels/1").should route_to("auto_submodels#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/auto_submodels/1").should route_to("auto_submodels#destroy", :id => "1")
    end

  end
end
