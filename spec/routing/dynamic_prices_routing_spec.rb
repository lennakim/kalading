require "spec_helper"

describe DynamicPricesController do
  describe "routing" do

    it "routes to #index" do
      get("/dynamic_prices").should route_to("dynamic_prices#index")
    end

    it "routes to #new" do
      get("/dynamic_prices/new").should route_to("dynamic_prices#new")
    end

    it "routes to #show" do
      get("/dynamic_prices/1").should route_to("dynamic_prices#show", :id => "1")
    end

    it "routes to #edit" do
      get("/dynamic_prices/1/edit").should route_to("dynamic_prices#edit", :id => "1")
    end

    it "routes to #create" do
      post("/dynamic_prices").should route_to("dynamic_prices#create")
    end

    it "routes to #update" do
      put("/dynamic_prices/1").should route_to("dynamic_prices#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/dynamic_prices/1").should route_to("dynamic_prices#destroy", :id => "1")
    end

  end
end
