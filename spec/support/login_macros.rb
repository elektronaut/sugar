module LoginMacros
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def it_requires_login_for(*actions)
      actions, opts = require_login_options(actions)
      actions.each do |action|
        it "requires login for #{action} action" do
          logout
          perform_login_macro_request(action, opts)
          expect(response).to redirect_to(login_users_url)
        end
      end
    end

    def it_requires_authentication_for(*actions)
      actions, opts = require_login_options(actions)
      actions.each do |action|
        it "requires authentication for #{action}" do
          private_browsing!
          expect(controller).to receive(:require_user_account)
            .at_least(:once)
            .and_return(true)
          perform_login_macro_request(action, opts)
        end
      end
    end

    def it_requires_user_for(*actions)
      actions, opts = require_login_options(actions)
      actions.each do |action|
        it "requires a user for #{action}" do
          expect(controller).to receive(:require_user_account)
            .at_least(:once)
            .and_return(true)
          perform_login_macro_request(action, opts)
        end
      end
    end

    def it_requires_admin_for(*actions)
      actions, opts = require_login_options(actions)
      actions.each do |action|
        it_requires_verify_user(action, :admin, opts)
      end
    end

    def it_requires_moderator_for(*actions)
      actions, opts = require_login_options(actions)
      actions.each do |action|
        it_requires_verify_user(action, :moderator, opts)
      end
    end

    def it_requires_user_admin_for(*actions)
      actions, opts = require_login_options(actions)
      actions.each do |action|
        it_requires_verify_user(action, :user_admin, opts)
      end
    end

    private

    def it_requires_verify_user(action, flag, opts = {})
      it "requires a #{flag} for #{action}" do
        received = false
        expect(controller).to receive(:verify_user) do |o|
          received = true if o[flag]
          true
        end.at_least(:once)
        perform_login_macro_request(action, opts)
        expect(received).to eq(true)
      end
    end

    def require_login_options(actions)
      default_options = { method: :get, params: { id: 1 }, format: :html }
      opts = if actions.last.is_a?(Hash)
               default_options.merge(actions.pop)
             else
               default_options
             end
      [actions, opts]
    end
  end

  def private_browsing!
    allow(Sugar).to receive(:public_browsing?).and_return(false)
  end

  def login(user = nil)
    @current_user = user || create(:user)
    session[:user_id] = @current_user.id
    session[:persistence_token] = @current_user.persistence_token
    session[:ips] = ["0.0.0.0"]
  end

  def logout
    session[:user_id] = nil
    session[:persistence_token] = nil
    session[:ips] = []
  end

  private

  def perform_login_macro_request(action, opts)
    send(opts[:method], action, params: opts[:params], format: opts[:format])
  end
end
