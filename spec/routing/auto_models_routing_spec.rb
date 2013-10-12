require "spec_helper"

describe AutoModelsController do
  describe "routing" do

    it "routes to #index" do
      get("/auto_models").should route_to("auto_models#index")
    end

    it "routes to #new" do
      get("/auto_models/new").should route_to("auto_models#new")
    end

    it "routes to #show" do
      get("/auto_models/1").should route_to("auto_models#show", :id => "1")
    end

    it "routes to #edit" do
      get("/auto_models/1/edit").should route_to("auto_models#edit", :id => "1")
    end

    it "routes to #create" do
      post("/auto_models").should route_to("auto_models#create")
    end

    it "routes to #update" do
      put("/auto_models/1").should route_to("auto_models#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/auto_models/1").should route_to("auto_models#destroy", :id => "1")
    end

  end
end
