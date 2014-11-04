Kalading::Application.routes.draw do
  resources :clients


  resources :image_texts


  resources :tool_records


  resources :tool_types


  resources :maintains


  resources :user_types


  resources :motoroil_groups


  resources :cities


  resources :videos


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

  devise_for :users, :skip => [:registrations], controllers: { sessions: "sessions" }
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
  
  get 'storehouses/:id/show_history' => 'storehouses#show_history', :as => :show_history
  post 'storehouses_inout/:id' => 'storehouses#inout', :as => :inout_storehouse
  get 'parts/:id/edit_part_automodel' => 'parts#edit_part_automodel', :as => :edit_part_automodel
  delete 'parts/:id/automodels/:auto_submodel_id' => 'parts#delete_auto_submodel', :as => :delete_part_auto_submodel
  post 'parts/:id/automodels' => 'parts#add_auto_submodel', :as => :add_part_auto_submodel
  get 'storehouses/:id/print_storehouse_out/:ht_id' => 'storehouses#print_storehouse_out', :as => :print_storehouse_out
  get 'part_statistics' => 'storehouses#statistics', :as => :part_statistics
  delete 'part_urlinfo/:id' => 'parts#destroy_urlinfo', :as => :delete_part_urlinfo
  get 'storehouses/:id/part_transfer' => 'storehouses#part_transfer', :as => :storehouse_part_transfer
  post 'storehouses/:id/part_transfer_to' => 'storehouses#part_transfer_to', :as => :storehouse_part_transfer_to

  get 'auto_parts' => 'orders#query_parts', :as => :query_parts
  get 'orders_history' => 'orders#history', :as => :order_history
  get 'latest_orders' => 'orders#latest_orders', :as => :latest_orders
  post 'orders/:id/uploadpic' => 'orders#uploadpic', :as => :uploadpic_orders
  get 'orders/:id/duplicate' => 'orders#duplicate', :as => :duplicate_order
  match 'orders_calcprice' => 'orders#calcprice', via: [:put, :post], :as => :calcprice_order
  get 'auto_maintain_order/:asm_id' => 'orders#auto_maintain', :as => :auto_maintain_order
  post 'auto_maintain_price/:asm_id' => 'orders#auto_maintain_price', :as => :auto_maintain_price
  post 'auto_maintain_order/:asm_id' => 'orders#create_auto_maintain_order', :as => :create_auto_maintain_order
  post 'auto_verify_order' => 'orders#create_auto_verify_order', :as => :create_auto_verify_order
  post 'auto_test_order' => 'orders#create_auto_test_order', :as => :create_auto_test_order
  post 'auto_maintain_order2' => 'orders#create_auto_maintain_order2', :as => :create_auto_maintain_order2
  get 'auto_test_order' => 'orders#auto_test_order', :as => :auto_test_order
  get 'auto_verify_order' => 'orders#auto_verify_order', :as => :auto_verify_order
  post 'auto_test_price' => 'orders#auto_test_price', :as => :auto_test_price
  post 'auto_verify_price' => 'orders#auto_verify_price', :as => :auto_verify_price
  get 'auto_maintain_packs' => 'orders#auto_maintain_packs', :as => :auto_maintain_packs
  get 'order_prompt' => 'orders#order_prompt', :as => :order_prompt
  get 'order_seq_check' => 'orders#order_seq_check', :as => :order_seq_check
  get 'order_tag_stats' => 'orders#tag_stats', :as => :order_tag_stats
  get 'order_evaluation_list' => 'orders#evaluation_list', :as => :order_evaluation_list
  get 'tomorrow_orders' => 'orders#tomorrow_orders', :as => :tomorrow_orders
    
  post 'maintains/:id/uploadpic' => 'maintains#uploadpic', :as => :uploadpic_maintains
  get 'last_maintain/:id' => 'maintains#last_maintain', :as => :last_maintain
  get 'auto_inspection_report' => 'maintains#auto_inspection_report', :as => :auto_inspection_report
  get 'maintain_summary/:id' => 'maintains#maintain_summary', :as => :maintain_summary
  post 'tool_records/:id/uploadpic' => 'tool_records#uploadpic', :as => :uploadpic_tool_records

  # For baichebao
  post 'auto_maintain_pack/:asm_id' => 'orders#create_auto_maintain_order3', :as => :create_auto_maintain_pack

  # For weiche
  get 'auto_sms' => 'auto_brands#auto_sms', :as => :auto_sms
  get 'auto_maintain_query/:asm_id' => 'orders#auto_maintain_query', :as => :auto_maintain_query
  post 'auto_maintain_order_weiche/:asm_id' => 'orders#create_auto_maintain_order4', :as => :create_auto_maintain_order_weiche

  get 'auto_submodels_oil_cap_edit' => 'auto_submodels#oil_cap_edit', :as => :auto_submodels_oil_cap_edit
  post 'auto_submodels_oil_cap_modify' => 'auto_submodels#oil_cap_modify', :as => :auto_submodels_oil_cap_modify
  get 'auto_submodels_service_level_edit' => 'auto_submodels#service_level_edit', :as => :auto_submodels_service_level_edit
  post 'auto_submodels_service_level_modify' => 'auto_submodels#service_level_modify', :as => :auto_submodels_service_level_modify
  get 'auto_submodels/:id/available_parts' => 'auto_submodels#available_parts', :as => :auto_submodels_available_parts

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

  get 'discount_query' => 'discounts#query', :as => :discount_query

  get 'city_capacity/:id' => 'cities#capacity', :as => :city_capacity
  get 'orders/:id/print' => 'orders#print', :as => :print_order
  
  get 'client_query' => 'clients#find', :as => :client_query
  
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
