Kalading::Application.routes.draw do
  get "doc/v2"

  resources :engineers do
    member do
      get :tool_assignments
    end

    collection do
      get :my_tool_assignments
    end
  end

  resources :tags


  resources :clients


  resources :complaints


  resources :notifications


  resources :image_texts


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

  resources :tool_types, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :service_vehicles, only: [:index, :new, :create, :edit, :update, :destroy] do
    member do
      get :tool_assignments
    end
    collection do
      get :local
    end
  end

  resources :tool_batches, only: [:index, :new] do
    collection do
      post :bulk_create
    end
  end

  resources :tool_assignments, only: [:index] do
    member do
      put :break
      put :lose
    end

    collection do
      get :prepare_for_assigning, as: :prepare
      post :batch_assign, as: :batch
    end
  end

  resources :tool_assignees, only: [:index]
  resources :tool_brands, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :tool_suppliers, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :tool_details, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :tool_deliveries, only: [:index, :new, :create] do
    member do
      get :prepare_for_receiving
      put :receive
    end
  end

  resources :tool_statistics, only: [:index]

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
  put 'user_realtime_info' => 'users#update_realtime_info', :as => :update_user_realtime_info
  get 'user_realtime_info' => 'users#get_realtime_info', :as => :get_user_realtime_info
  get 'curr_user_state' => 'users#set_state', :as => :set_user_state

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
  get 'storehouses/:id/part_yingyusunhao' => 'storehouses#part_yingyusunhao', :as => :storehouse_part_yingyusunhao
  post 'storehouses/:id/do_part_yingyusunhao' => 'storehouses#do_part_yingyusunhao', :as => :storehouse_do_part_yingyusunhao
  get 'city_part_requirements' => 'storehouses#city_part_requirements', :as => :city_part_requirements
  get 'storehouse/:id/print_dispatch_card' => 'storehouses#print_dispatch_card', :as=> :print_dispatch_card
  get 'storehouse/:id/print_orders_card' => 'storehouses#print_orders_card', :as=> :print_orders_card

  get 'latest_orders' => 'orders#latest_orders', :as => :latest_orders
  get 'orders/:id/duplicate' => 'orders#duplicate', :as => :duplicate_order
  match 'orders_calcprice' => 'orders#calcprice', via: [:put, :post], :as => :calcprice_order
  get 'auto_maintain_order/:asm_id' => 'orders#auto_maintain', :as => :auto_maintain_order
  post 'auto_maintain_price/:asm_id' => 'orders#auto_maintain_price', :as => :auto_maintain_price
  post 'auto_maintain_order/:asm_id' => 'orders#create_auto_maintain_order', :as => :create_auto_maintain_order
  post 'auto_verify_order' => 'orders#create_auto_verify_order', :as => :create_auto_verify_order
  post 'auto_test_order' => 'orders#create_auto_test_order', :as => :create_auto_test_order
  post 'auto_maintain_order2' => 'orders#create_auto_maintain_order2', :as => :create_auto_maintain_order2
  post 'auto_special_order' => 'orders#create_auto_special_order', :as => :create_auto_special_order
  get 'auto_test_order' => 'orders#auto_test_order', :as => :auto_test_order
  get 'auto_verify_order' => 'orders#auto_verify_order', :as => :auto_verify_order
  post 'auto_test_price' => 'orders#auto_test_price', :as => :auto_test_price
  post 'auto_verify_price' => 'orders#auto_verify_price', :as => :auto_verify_price
  get 'auto_maintain_packs' => 'orders#auto_maintain_packs', :as => :auto_maintain_packs
  get 'order_prompt' => 'orders#order_prompt', :as => :order_prompt
  get 'order_seq_check' => 'orders#order_seq_check', :as => :order_seq_check
  get 'order_tag_stats' => 'orders#tag_stats', :as => :order_tag_stats
  get 'order_evaluation_list' => 'orders#evaluation_list', :as => :order_evaluation_list
  get 'orders/:id/send_sms_notify' => 'orders#send_sms_notify', :as => :order_send_sms_notify
  get 'daily_orders' => 'orders#daily_orders', :as => :daily_orders
  get 'order_stats' => 'orders#order_stats', :as => :order_stats
  get 'orders/:id/parts_auto_deliver' => 'orders#order_parts_auto_deliver', :as => :order_parts_auto_deliver
  get 'orders/:id/history' => 'orders#history', :as => :order_history
  
  get 'complaints/:id/send_sms_notify' => 'complaints#send_sms_notify', :as => :complaint_send_sms_notify

  post 'maintains/:id/uploadpic' => 'maintains#uploadpic', :as => :uploadpic_maintains
  get 'last_maintain/:id' => 'maintains#last_maintain', :as => :last_maintain
  get 'auto_inspection_report' => 'maintains#auto_inspection_report', :as => :auto_inspection_report
  get 'maintain_summary/:id' => 'maintains#maintain_summary', :as => :maintain_summary

  # For baichebao
  post 'auto_maintain_pack/:asm_id' => 'orders#create_auto_maintain_order3', :as => :create_auto_maintain_pack

  # For weiche
  get 'auto_sms' => 'auto_brands#auto_sms', :as => :auto_sms
  get 'auto_sms_with_pm25' => 'auto_brands#auto_sms_with_pm25', :as => :auto_sms_with_pm25
  get 'auto_maintain_query/:asm_id' => 'orders#auto_maintain_query', :as => :auto_maintain_query
  post 'auto_maintain_order_weiche/:asm_id' => 'orders#create_auto_maintain_order4', :as => :create_auto_maintain_order_weiche
  # For renbao
  post 'auto_maintain_order_renbao/:asm_id' => 'orders#create_auto_maintain_order5', :as => :create_auto_maintain_order_renbao
  # For jd
  post 'auto_maintain_order_jd/:asm_id' => 'orders#create_auto_maintain_order_jd', :as => :create_auto_maintain_order_jd
  # For wei_dian_dao_jia
  post 'auto_maintain_order_weidiandaojia/:asm_id' => 'orders#create_auto_maintain_order_weidiandaojia', :as => :create_auto_maintain_order_weidiandaojia

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

  get 'discount_query' => 'discounts#query', :as => :discount_query

  get 'city_capacity/:id' => 'cities#capacity', :as => :city_capacity
  get 'orders/:id/print' => 'orders#print', :as => :print_order

  get 'client_query' => 'clients#find', :as => :client_query

  resources :auto_brands
  root :to => 'orders#index'

  mount Base => '/api' #api
end
