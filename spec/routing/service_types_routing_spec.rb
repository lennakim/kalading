require "spec_helper"

describe ServiceTypesController do
  describe "routing" do

    it "routes to #index" do
      get("/service_types").should route_to("service_types#index")
    end

    it "routes to #new" do
      get("/service_types/new").should route_to("service_types#new")
    end

    it "routes to #show" do
      get("/service_types/1").should route_to("service_types#show", :id => "1")
    end

    it "routes to #edit" do
      get("/service_types/1/edit").should route_to("service_types#edit", :id => "1")
    end

    it "routes to #create" do
      post("/service_types").should route_to("service_types#create")
    end

    it "routes to #update" do
      put("/service_types/1").should route_to("service_types#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/service_types/1").should route_to("service_types#destroy", :id => "1")
    end

  end
end
