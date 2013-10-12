require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe PartBrandsController do

  # This should return the minimal set of attributes required to create a valid
  # PartBrand. As you add validations to PartBrand, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "name" => "MyString" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # PartBrandsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all part_brands as @part_brands" do
      part_brand = PartBrand.create! valid_attributes
      get :index, {}, valid_session
      assigns(:part_brands).should eq([part_brand])
    end
  end

  describe "GET show" do
    it "assigns the requested part_brand as @part_brand" do
      part_brand = PartBrand.create! valid_attributes
      get :show, {:id => part_brand.to_param}, valid_session
      assigns(:part_brand).should eq(part_brand)
    end
  end

  describe "GET new" do
    it "assigns a new part_brand as @part_brand" do
      get :new, {}, valid_session
      assigns(:part_brand).should be_a_new(PartBrand)
    end
  end

  describe "GET edit" do
    it "assigns the requested part_brand as @part_brand" do
      part_brand = PartBrand.create! valid_attributes
      get :edit, {:id => part_brand.to_param}, valid_session
      assigns(:part_brand).should eq(part_brand)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new PartBrand" do
        expect {
          post :create, {:part_brand => valid_attributes}, valid_session
        }.to change(PartBrand, :count).by(1)
      end

      it "assigns a newly created part_brand as @part_brand" do
        post :create, {:part_brand => valid_attributes}, valid_session
        assigns(:part_brand).should be_a(PartBrand)
        assigns(:part_brand).should be_persisted
      end

      it "redirects to the created part_brand" do
        post :create, {:part_brand => valid_attributes}, valid_session
        response.should redirect_to(PartBrand.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved part_brand as @part_brand" do
        # Trigger the behavior that occurs when invalid params are submitted
        PartBrand.any_instance.stub(:save).and_return(false)
        post :create, {:part_brand => { "name" => "invalid value" }}, valid_session
        assigns(:part_brand).should be_a_new(PartBrand)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        PartBrand.any_instance.stub(:save).and_return(false)
        post :create, {:part_brand => { "name" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested part_brand" do
        part_brand = PartBrand.create! valid_attributes
        # Assuming there are no other part_brands in the database, this
        # specifies that the PartBrand created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        PartBrand.any_instance.should_receive(:update_attributes).with({ "name" => "MyString" })
        put :update, {:id => part_brand.to_param, :part_brand => { "name" => "MyString" }}, valid_session
      end

      it "assigns the requested part_brand as @part_brand" do
        part_brand = PartBrand.create! valid_attributes
        put :update, {:id => part_brand.to_param, :part_brand => valid_attributes}, valid_session
        assigns(:part_brand).should eq(part_brand)
      end

      it "redirects to the part_brand" do
        part_brand = PartBrand.create! valid_attributes
        put :update, {:id => part_brand.to_param, :part_brand => valid_attributes}, valid_session
        response.should redirect_to(part_brand)
      end
    end

    describe "with invalid params" do
      it "assigns the part_brand as @part_brand" do
        part_brand = PartBrand.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        PartBrand.any_instance.stub(:save).and_return(false)
        put :update, {:id => part_brand.to_param, :part_brand => { "name" => "invalid value" }}, valid_session
        assigns(:part_brand).should eq(part_brand)
      end

      it "re-renders the 'edit' template" do
        part_brand = PartBrand.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        PartBrand.any_instance.stub(:save).and_return(false)
        put :update, {:id => part_brand.to_param, :part_brand => { "name" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested part_brand" do
      part_brand = PartBrand.create! valid_attributes
      expect {
        delete :destroy, {:id => part_brand.to_param}, valid_session
      }.to change(PartBrand, :count).by(-1)
    end

    it "redirects to the part_brands list" do
      part_brand = PartBrand.create! valid_attributes
      delete :destroy, {:id => part_brand.to_param}, valid_session
      response.should redirect_to(part_brands_url)
    end
  end

end
