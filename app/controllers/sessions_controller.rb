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
                    render json: { result: 'ok', authentication_token: resource.authentication_token, info:  resource }, status: :created
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
        #current_user.reset_authentication_token! if current_user
        super
    end
    
    def invalid_login_attempt
        warden.custom_failure!
        render :json => { result: t(:phone_num_invalid) },  :status => :ok
    end
end