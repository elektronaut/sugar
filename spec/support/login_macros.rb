module LoginMacros
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def it_requires_login_for(*actions)
      actions.each do |action|
        it "#{action} action should require login" do
          get action, :id => 1
          response.should redirect_to(login_users_url)
        end
      end
    end
  end

  def login(user=nil)
    @current_user = user || create(:user)
    session[:user_id] = @current_user.id
    session[:hashed_password] = @current_user.hashed_password
    session[:ips] = ['0.0.0.0']
  end
end
