class Ability
  include CanCan::Ability

  def ROLE_ID(r)
    User::ROLE_STRINGS.index(r).to_s
  end

  def initialize(user)
    user ||= User.new
    
    can :update, User do |u|
      u == user
    end

    if user.roles.include? ROLE_ID('role_admin')
      can :manage, :all
      can :access, :rails_admin   # grant access to rails_admin
      can :dashboard              # grant access to the dashboard
      can [:edit_all, :statistics], Order
      can :view, Video
    end

    if user.roles.include? ROLE_ID('manager')
      can :read, :all 
      can :view, Video
    end
    
    if user.roles.include? ROLE_ID('video_inspector')
      can [:view, :read], Video
    end

    if (user.roles.include? ROLE_ID('storehouse_admin')) || (user.roles.include? ROLE_ID('national_storehouse_admin'))
      can :read, :all
      can [:inout, :print_dispatch_card, :part_yingyusunhao, :do_part_yingyusunhao, :city_part_requirements], Storehouse
      can [:create, :update, :destroy], [Storehouse, Partbatch, Part, PartType, PartBrand, Supplier]
      can [:update, :edit_all, :calcprice, :print, :daily_orders], Order
      can :order_prompt, Order
      can :read, Complaint
      can :update, Complaint do |c|
        c.handler == user
      end
    end

    if user.roles.include? ROLE_ID('national_storehouse_admin')
      can :manage_all, Storehouse
    end
    
    if user.roles.include? ROLE_ID('data_admin')
      can :read, :all
      can [:create, :update, :destroy], [AutoBrand, AutoModel, AutoSubmodel, Partbatch, Part, PartType, PartBrand, Supplier, Storehouse, Discount]
      can :inout, Storehouse
      can [:match, :part_select, :update_part_select, :parts_by_brand_and_type, :delete_match, :edit_part_automodel, :add_auto_submodel, :delete_auto_submodel], Part
      can :order_seq_check, Order
    end

    if user.roles.include? ROLE_ID('engineer')
      can [:read, :order_prompt], Order
      can :read, Complaint
      can :update, Complaint do |c|
        c.handler == user
      end
      can :update, Order do |o|
        o.engineer == user
      end
      can :update_realtime_info, User do |u|
        u == user
      end
    end
    
    if user.roles.include? ROLE_ID('dispatcher')
      can :read, :all
      can [:create, :update, :destroy, :edit_all, :duplicate, :calcprice, :order_prompt, :print, :send_sms_notify, :daily_orders], Order
      can [:create, :update, :edit_all, :send_sms_notify], Complaint
    end
    
    if user.roles.include? ROLE_ID('finance')
      can [:read, :update], Order
    end
  end
end
