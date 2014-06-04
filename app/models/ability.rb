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
      can :edit_all, Order
      can :view, Video
    end

    if user.roles.include? ROLE_ID('manager')
      can :read, :all 
      can :view, Video
    end
    
    if user.roles.include? ROLE_ID('storehouse_admin')
      can :read, :all
      can :inout, Storehouse
      can [:create, :update, :destroy], [Storehouse, Partbatch, Part, PartType, PartBrand, Supplier]
    end

    if user.roles.include? ROLE_ID('data_admin')
      can :read, :all
      can [:create, :update, :destroy], [Auto, AutoBrand, AutoModel, AutoSubmodel, Partbatch, Part, PartType, PartBrand, Supplier, Storehouse, Discount]
      can :inout, Storehouse
      can [:match, :part_select, :update_part_select, :parts_by_brand_and_type, :delete_match], Part
      
    end

    if user.roles.include? ROLE_ID('engineer')
      can :read, :all
      can :available_parts, AutoSubmodel
      can :update, Order do |o|
        o.engineer == user
      end
    end
    
    if user.roles.include? ROLE_ID('dispatcher')
      can :read, :all
      can [:create, :update, :destroy, :edit_all, :duplicate, :calcprice], Order
    end
    
  end
end
