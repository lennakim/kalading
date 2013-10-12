require "spec_helper"

describe StorehousesController do
  describe "routing" do

    it "routes to #index" do
      get("/storehouses").should route_to("storehouses#index")
    end

    it "routes to #new" do
      get("/storehouses/new").should route_to("storehouses#new")
    end

    it "routes to #show" do
      get("/storehouses/1").should route_to("storehouses#show", :id => "1")
    end

    it "routes to #edit" do
      get("/storehouses/1/edit").should route_to("storehouses#edit", :id => "1")
    end

    it "routes to #create" do
      post("/storehouses").should route_to("storehouses#create")
    end

    it "routes to #update" do
      put("/storehouses/1").should route_to("storehouses#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/storehouses/1").should route_to("storehouses#destroy", :id => "1")
    end

  end
end
