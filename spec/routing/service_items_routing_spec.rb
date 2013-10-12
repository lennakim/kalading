require "spec_helper"

describe ServiceItemsController do
  describe "routing" do

    it "routes to #index" do
      get("/service_items").should route_to("service_items#index")
    end

    it "routes to #new" do
      get("/service_items/new").should route_to("service_items#new")
    end

    it "routes to #show" do
      get("/service_items/1").should route_to("service_items#show", :id => "1")
    end

    it "routes to #edit" do
      get("/service_items/1/edit").should route_to("service_items#edit", :id => "1")
    end

    it "routes to #create" do
      post("/service_items").should route_to("service_items#create")
    end

    it "routes to #update" do
      put("/service_items/1").should route_to("service_items#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/service_items/1").should route_to("service_items#destroy", :id => "1")
    end

  end
end
