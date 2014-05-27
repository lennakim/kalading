#encoding: UTF-8
class SessionsController < Devise::SessionsController
    #todo: only do this for iphone app
    prepend_before_filter :require_no_authentication, :only => [:create ]
    skip_before_filter :verify_authenticity_token
    
    def create
        respond_to do |format|
            format.json do
                return render(:json => {result: t(:phone_num_invalid) }, status: :ok) if !params[:phone_num]
                self.resource = User.find_for_database_authentication(:phone_num => params[:phone_num])
                return render(:json => {result: t(:phone_num_not_found) }, status: :ok) unless resource
                if resource.valid_password?(params[:password])
                    sign_in(resource_name, resource)
                    resource.update_tracked_fields!(request)
                    resource.ensure_authentication_token!  #make sure the user has a token generated
                    render json: { result: 'ok', authentication_token: resource.authentication_token , name: resource.name }, status: :created
                else
                    render json: { result: t(:incorrect_password) }, status: :ok
                end
            end
            
            format.html do
                self.resource = warden.authenticate!(auth_options)
                set_flash_message(:notice, :signed_in) if is_navigational_format?
                sign_in(resource_name, resource)
                respond_with resource, :location => after_sign_in_path_for(resource)
            end
        end
    end
    
    def destroy
      redirect_path = after_sign_out_path_for(resource_name)
      signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
      set_flash_message :notice, :signed_out if signed_out && is_navigational_format?
  
      # We actually need to hardcode this as Rails default responder doesn't
      # support returning empty response on GET request
      respond_to do |format|
        format.all { head :no_content }
        format.json { render json: { result: 'ok' } }
        format.any(*navigational_formats) { redirect_to redirect_path }
      end
    end
    
    def invalid_login_attempt
        warden.custom_failure!
        render :json => { result: t(:phone_num_invalid) },  :status => :ok
    end
end