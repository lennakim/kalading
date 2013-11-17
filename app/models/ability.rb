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
    end

    can :read, :all if user.roles.include? ROLE_ID('manager')
    
    if user.roles.include? ROLE_ID('storehouse_admin')
      can :read, :all
      can [:create, :update, :destroy], [Storehouse, Partbatch, Part, PartType, PartBrand, Supplier]
    end

    if user.roles.include? ROLE_ID('data_admin')
      can :read, :all
      can [:create, :update, :destroy], [Auto, AutoBrand, AutoModel, AutoSubmodel, Partbatch, Part, PartType, PartBrand, Supplier]
    end

    if user.roles.include? ROLE_ID('engineer')
      can :read, :all
      can :update, Order do |o|
        o.engineer == user
      end
    end
    
    if user.roles.include? ROLE_ID('dispatcher')
      can :read, :all
      can [:create, :update, :destroy], Order
    end
    
  end
end
