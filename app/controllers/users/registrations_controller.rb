# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create, :step2, :step3, :step4]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    @user = User.new
    puts "new (step 1)called"
  end

  def step2
    puts "step 2 called"
    # @user = User.new(user_params)
    # render :new unless @user.valid?(:step1)
    puts "registration params: #{session[:registration_params]}"
    session[:registration_params] ||= {}
    session[:registration_params].merge!(user_params.to_h)
    @user = User.new(session[:registration_params])
    render :step1 unless @user.valid?(:step1)
  end

  def step3
    puts "step 3"
    puts "registration_params: #{session[:registration_params]}"
    session[:registration_params].merge!(user_params.to_h)
    @user = User.new(session[:registration_params])
    @user.build_organisation unless @user.organisation
    render :step2 unless @user.valid?(:step2)
  end

  def step4
    puts "step 4"
    puts "registration_params: #{session[:registration_params]}"
    puts "user_params: #{user_params}"
    session[:registration_params].merge!(user_params.to_h)
    @user = User.new(session[:registration_params])
    @user.build_organisation unless @user.organisation
    render :step3 unless @user.valid?(:step3)
  end

  # def create
  #   super do |resource|
  #     if resource.persisted?
  #       # Sauvegarder l'organisation associée
  #       resource.organisation.save if resource.organisation

  #       # Définir le statut de l'utilisateur
  #       if resource.organisation.users.count == 1
  #         resource.update(status: 'org_admin')
  #       else
  #         resource.update(status: 'collaborateur')
  #       end
  #     end
  #   end
  # end

  def create
    puts "step create"
    puts "registration_params avant merge: #{session[:registration_params]}"
    puts "user_params: #{user_params}"
    # session[:registration_params].merge!(user_params.to_h)
    
    # Fusionner les attributs de l'utilisateur et de l'organisation
    session[:registration_params].merge!(user_params.to_h) do |key, old_val, new_val|
      if key.to_s == "organisation_attributes"
        old_val.merge(new_val)
      else
        new_val
      end
    end

    puts "registration_params apres merge: #{session[:registration_params]}"
    @user = User.new(session[:registration_params])
    puts "@user a ce stade: #{@user}"
    @user.status = 'org_admin'
    if @user.save
      session[:registration_params] = nil
      sign_in(@user)
      redirect_to root_path, notice: 'Inscription réussie.'
    else
      render :step4
    end
  end

 
  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:firstname, :lastname, :phone, :status, :birthdate, organisation_attributes: [:status, :creation_date, :business_name, :capital, :logo, :address, :address_line_2, :postal_code, :city, :country, :identification_number, :vat_number]])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :firstname, :lastname, :birthdate, :phone,
                                 organisation_attributes: [:business_name, :status, :capital, :creation_date, :address, :address_line_2, :postal_code, :logo, :city, :country, :identification_number, :vat_number])
  end


  # def build_organisation
  #   puts "Building organisation appelé"
  #   build_organisation
  #   puts resource.organisation.inspect
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
