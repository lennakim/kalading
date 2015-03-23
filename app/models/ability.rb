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

    # 管理员
    if user.role_admin?
      can :manage, :all
      can :access, :rails_admin   # grant access to rails_admin
      can :dashboard              # grant access to the dashboard
      can [:edit_all, :order_stats], Order
      can :view, Video
    end

    # 总裁
    if user.manager?
      can :read, :all
      can :view, Video
    end

    # 视频审查员
    if user.video_inspector?
      can [:view, :read], Video
    end

    # 地方库管和全国库管
    if user.storehouse_admin? or user.national_storehouse_admin?
      can :read, :all
      can [:inout, :print_dispatch_card, :print_orders_card, :city_part_requirements], Storehouse
      can [:update, :edit_all, :calcprice, :print, :daily_orders], Order
      can :order_prompt, Order
      can :update, [Storehouse, Partbatch]
      can :read, Complaint
      can :update, Complaint do |c|
        c.handler == user
      end
    end

    # 全国库管
    if user.national_storehouse_admin?
      can [:manage_all, :part_transfer, :part_transfer_to, :part_yingyusunhao, :do_part_yingyusunhao, :statistics], Storehouse
      can [:create, :update, :destroy], [Storehouse, Partbatch, Part, PartType, PartBrand, Supplier]
      can :order_stats,  Order
    end

    # 数据管理员
    if user.data_admin?
      can :read, :all
      can [:create, :update, :destroy], [AutoBrand, AutoModel, AutoSubmodel, Partbatch, Part, PartType, PartBrand, Supplier, Storehouse, Discount]
      can :inout, Storehouse
      can [:match, :part_select, :update_part_select, :parts_by_brand_and_type, :delete_match, :edit_part_automodel, :add_auto_submodel, :delete_auto_submodel], Part
      can [:order_seq_check, :order_stats], Order
    end

    # 技师
    if user.engineer?
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

    # 调度，客服
    if user.dispatcher?
      can :read, :all
      can [:create, :update, :destroy, :edit_all, :duplicate, :calcprice, :order_prompt, :print, :send_sms_notify, :daily_orders], Order
      can [:create, :update, :edit_all, :send_sms_notify], Complaint
    end

    # 财务
    if user.finance?
      can [:read, :update], Order
    end

    # 技师主管
    if user.engineer_manager?
      can [:read, :calcprice, :print, :daily_orders], Order
      can :read, Complaint
      can :update, Complaint do |c|
        c.handler == user
      end
      can [:view, :read], Video
      can [:read, :create, :update, :destroy], Notification
    end
  end
end
