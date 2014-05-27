class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale

  def check_for_mobile
    session[:mobile_override] = params[:mobile] if params[:mobile]
    #prepare_for_mobile if mobile_device?  && !params[:mobilejs]
  end

  def prepare_for_mobile
    request.format = :mobile
  end

  def mobile_device?
    #return 1
    if session[:mobile_override]
      session[:mobile_override] == "1"
    else
      # Season this regexp to taste. I prefer to treat iPad as non-mobile.
      (request.user_agent =~ /Mobile|webOS/) && (request.user_agent !~ /iPad/)
      #true
    end
  end
  helper_method :mobile_device?
  
  def after_sign_in_path_for(user)
    orders_path
  end

  def after_sign_out_path_for(user)
    orders_path
  end
  
  attr_accessor :current_operator
  
  def set_default_operator
    self.current_operator = current_user
  end
  
  def set_locale
    if params[:locale] && I18n.available_locales.include?( params[:locale].to_sym )
      session[:locale] = params[:locale]
    end
    I18n.locale = session[:locale] || I18n.default_locale
  end

end
