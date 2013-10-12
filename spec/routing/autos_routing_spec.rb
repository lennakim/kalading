require "spec_helper"

describe AutosController do
  describe "routing" do

    it "routes to #index" do
      get("/autos").should route_to("autos#index")
    end

    it "routes to #new" do
      get("/autos/new").should route_to("autos#new")
    end

    it "routes to #show" do
      get("/autos/1").should route_to("autos#show", :id => "1")
    end

    it "routes to #edit" do
      get("/autos/1/edit").should route_to("autos#edit", :id => "1")
    end

    it "routes to #create" do
      post("/autos").should route_to("autos#create")
    end

    it "routes to #update" do
      put("/autos/1").should route_to("autos#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/autos/1").should route_to("autos#destroy", :id => "1")
    end

  end
end
