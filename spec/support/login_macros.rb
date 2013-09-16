module LoginMacros
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def it_requires_login_for(*actions)
      options = { method: :get, params: { id: 1 } }
      if actions.last.kind_of?(Hash)
        options.merge!(actions.pop)
      end
      actions.each do |action|
        it "requires login for #{action} action" do
          logout
          self.send options[:method], action, options[:params]
          response.should redirect_to(login_users_url)
        end
      end
    end

    def it_requires_authentication_for(*actions)
      options = { method: :get, params: { id: 1 } }
      if actions.last.kind_of?(Hash)
        options.merge!(actions.pop)
      end
      actions.each do |action|
        it "requires authentication for #{action}" do
          Sugar.stub(:public_browsing?).and_return(false)
          controller.should_receive(:require_user_account)
            .at_least(:once)
            .and_return(true)
          self.send options[:method], action, options[:params]
        end
      end
    end

    def it_requires_user_for(*actions)
      options = { method: :get, params: { id: 1 } }
      if actions.last.kind_of?(Hash)
        options.merge!(actions.pop)
      end
      actions.each do |action|
        it "requires a user for #{action}" do
          controller.should_receive(:require_user_account)
            .at_least(:once)
            .and_return(true)
          self.send options[:method], action, options[:params]
        end
      end
    end

    def it_requires_admin_for(*actions)
      options = { method: :get, params: { id: 1 } }
      if actions.last.kind_of?(Hash)
        options.merge!(actions.pop)
      end
      actions.each do |action|
        it "requires an admin for #{action}" do
          received_option = false
          controller.should_receive(:verify_user) { |options|
            if options[:admin]
              received_option = true
            end
            true
          }.at_least(:once)
          self.send options[:method], action, options[:params]
          received_option.should be_true
        end
      end
    end

    def it_requires_moderator_for(*actions)
      options = { method: :get, params: { id: 1 } }
      if actions.last.kind_of?(Hash)
        options.merge!(actions.pop)
      end
      actions.each do |action|
        it "requires a moderator for #{action}" do
          received_option = false
          controller.should_receive(:verify_user) { |options|
            if options[:moderator]
              received_option = true
            end
            true
          }.at_least(:once)
          self.send options[:method], action, options[:params]
          received_option.should be_true
        end
      end
    end

    def it_requires_user_admin_for(*actions)
      options = { method: :get, params: { id: 1 } }
      if actions.last.kind_of?(Hash)
        options.merge!(actions.pop)
      end
      actions.each do |action|
        it "requires a user admin for #{action}" do
          received_option = false
          controller.should_receive(:verify_user) { |options|
            if options[:user_admin]
              received_option = true
            end
            true
          }.at_least(:once)
          self.send options[:method], action, options[:params]
          received_option.should be_true
        end
      end
    end

  end

  def login(user=nil)
    @current_user = user || create(:user)
    session[:user_id] = @current_user.id
    session[:persistence_token] = @current_user.persistence_token
    session[:ips] = ['0.0.0.0']
  end

  def logout
    session[:user_id] = nil
    session[:persistence_token] = nil
    session[:ips] = []
  end

end
