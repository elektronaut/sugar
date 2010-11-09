require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class InvitesControllerTest < ActionController::TestCase

	context "When logged in without invites" do 
		setup do 
			login_session(Factory(:user, :available_invites => 0)) 
		end

		context 'a GET on :new' do
			setup { get :new }
			should set_the_flash.to(/You don't have any invites!/)
			should respond_with(:redirect)
		end

		context 'a POST on :create' do
			setup { post :create }
			should set_the_flash.to(/You don't have any invites!/)
			should respond_with(:redirect)
		end
		
		context 'a GET on :all' do
			setup { get :all }
			should set_the_flash
			should respond_with(:redirect)
			should 'redirect back to invites' do
				assert_redirected_to discussions_path
			end
		end
	end
	
	context "When logged in with invites" do
		setup do
			@user = Factory(:user, :available_invites => 5)
			login_session(@user) 
		end

		context 'a GET on :new' do
			setup { get :new }
			should_not set_the_flash
			should render_template(:new)
			should assign_to(:invite)
		end

		context 'creating a new invite' do
			setup { post :create, :invite => {:email => 'no-reply@somewhere.com', :message => 'testing message'} }
			should assign_to(:invite)
			should set_the_flash.to(/Your invite has been sent/)
			should 'redirect' do
				assert_redirected_to invites_path
			end
			should 'send a welcome email' do
				invite_email = ActionMailer::Base.deliveries.first
				assert_equal invite_email.to[0], 'no-reply@somewhere.com'
				assert_match /testing message/, invite_email.body.to_s
			end
			should 'decrement available invites' do
				assert_equal 4, User.find(@user.id).available_invites
			end
		end

		context 'sending an invite to an existing user' do
			setup do
				@existing_user = Factory(:user, :email => 'existing@example.com')
				post :create, :invite => {:email => 'existing@example.com'}
			end
			should_not set_the_flash
			should render_template(:new)
			should assign_to(:invite)
			should 'instance an invalid invite' do
				assert !assigns(:invite).valid?
			end
			should 'not decrement available invites' do
				assert_equal 5, User.find(@user.id).available_invites
			end
		end
	end
	
	context "When logged in as user admin" do
		setup do
			@user = Factory(:user, :user_admin => true, :available_invites => 0)
			login_session(@user) 
		end

		context 'a GET on :all' do
			setup { get :all }
			should_not set_the_flash
			should respond_with(:success)
			should assign_to(:invites)
		end

		# User admins should be able to invites regardless of available invites
		context 'creating a new invite' do
			setup { post :create, :invite => {:email => 'no-reply@somewhere.com', :message => 'testing message'} }
			should assign_to(:invite)
			should set_the_flash.to(/Your invite has been sent/)
		end
	end
	
	context "With an existing invite" do
		setup do
			@invite = Factory(:invite)
		end
		
		context 'accepting it' do
			setup do
				get :accept, :id => @invite.token
			end
			should assign_to(:invite)
			should respond_with(:redirect)
			should 'redirect to the new user page' do
				assert_redirected_to(new_user_by_token_url(:token => @invite.token))
			end
		end
	end
	
	context "With an expired invite" do
		setup do
			@invite = Factory(:invite, :expires_at => 90.days.ago)
		end
		
		context 'accepting it' do
			setup do
				get :accept, :id => @invite.token
			end
			should assign_to(:invite)
			should respond_with(:redirect)
			should set_the_flash.to(/Your invite has expired/)
			should 'delete the invite' do
				assert !Invite.exists?(@invite)
			end
			should 'redirect to the login page' do
				assert_redirected_to(login_users_path)
			end
		end
	end

	context "Trying to accept an invalid token" do
		setup do
			get :accept, :id => 'thisisnotavalidtoken'
		end
		
		should respond_with(:redirect)
		should set_the_flash.to(/not a valid invite/)
		should 'redirect to the login page' do
			assert_redirected_to(login_users_path)
		end
	end
end
