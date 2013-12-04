Kalading::Application.routes.draw do
  resources :discounts

  resources :service_types


  resources :orders do
    resources :pictures
  end


  resources :partbatches

  resources :storehouses do
    resource :partbatches
  end

  resources :suppliers

  resources :autos

  resources :parts

  resources :part_types


  resources :part_brands


  resources :auto_submodels do
    resources :pictures
  end

  resources :auto_models


  resources :auto_brands
  

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :users, :skip => [:registrations]                                          
  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users_update/:id' => 'devise/registrations#update', :as => 'user_registration'
  end
    
  get 'users' => 'users#index', :as => :users
  get 'users/:id/edit' => 'users#edit', :as => :edit_user
  get 'users/:id' => 'users#show', :as => :user
  put 'users/:id' => 'users#update', :as => :update_user
  get 'users_new' => 'users#new', :as => :new_user
  post 'users' => 'users#create', :as => :create_user
  delete 'users/:id' => 'users#destroy', :as => :user
  
  post 'partbatches/:id' => 'partbatches#inout', :as => :inout_partbatch
  get 'storehouses/:id/show_history' => 'storehouses#show_history', :as => :show_history
  get 'parts/:id/edit_part_automodel' => 'parts#edit_part_automodel', :as => :edit_part_automodel
  delete 'parts/:id/automodels/:auto_submodel_id' => 'parts#delete_auto_submodel', :as => :delete_part_auto_submodel
  post 'parts/:id/automodels' => 'parts#add_auto_submodel', :as => :add_part_auto_submodel
  get 'storehouses/:id/print_storehouse_out/:ht_id' => 'storehouses#print_storehouse_out', :as => :print_storehouse_out

  get 'auto_parts' => 'orders#query_parts', :as => :query_parts
  get 'orders_history' => 'orders#history', :as => :order_history
  post 'orders/:id/uploadpic' => 'orders#uploadpic', :as => :uploadpic_orders
  get 'orders/:id/duplicate' => 'orders#duplicate', :as => :duplicate_order
  match 'orders_calcprice' => 'orders#calcprice', via: [:put, :post], :as => :calcprice_order

  get 'auto_submodels_oil_cap_edit' => 'auto_submodels#oil_cap_edit', :as => :auto_submodels_oil_cap_edit
  post 'auto_submodels_oil_cap_modify' => 'auto_submodels#oil_cap_modify', :as => :auto_submodels_oil_cap_modify
  get 'auto_submodels_service_level_edit' => 'auto_submodels#service_level_edit', :as => :auto_submodels_service_level_edit
  post 'auto_submodels_service_level_modify' => 'auto_submodels#service_level_modify', :as => :auto_submodels_service_level_modify
  post 'auto_submodels_import' => 'auto_submodels#import', :as => :auto_submodels_import
  post 'auto_submodels_import_by_id/:id' => 'auto_submodels#import_by_id', :as => :auto_submodels_import_by_id

  get 'auto_submodels_edit_with_catalog' => 'auto_submodels#edit_with_catalog', :as => :auto_submodels_edit_with_catalog
  get 'part_match' => 'parts#match', :as => :part_match
  get 'part_select/:id' => 'parts#part_select', :as => :part_select
  post 'part_select/:id' => 'parts#update_part_select', :as => :update_part_select
  get 'part_delete_match/:id' => 'parts#delete_match', :as => :part_delete_match
  get 'parts_by_brand_and_type' => 'parts#parts_by_brand_and_type', :as => :parts_by_brand_and_type

  post 'partbatch_import' => 'storehouses#import', :as => :partbatch_import

  # singular for weixin app
  get 'm' => 'orders#order_begin', :as => :order_begin
  get 'choose_service' => 'orders#choose_service', :as => :order_choose_service
  get 'choose_auto_model' => 'orders#choose_auto_model', :as => :order_choose_auto_model
  get 'choose_auto_submodel' => 'orders#choose_auto_submodel', :as => :order_choose_auto_submodel
  get 'pay' => 'orders#pay', :as => :order_pay
  get 'discount_apply' => 'orders#discount_apply', :as => :discount_apply
  get 'order_preview' => 'orders#order_preview', :as => :order_preview
  get 'order_finish' => 'orders#order_finish', :as => :order_finish

  resources :auto_brands
  root :to => 'orders#index'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
