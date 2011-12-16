# encoding: utf-8

require 'spec_helper'

describe InvitesController do
	it_requires_login_for :index, :all, :new, :create, :destroy

	describe 'with no available invites' do
		before { login create(:user, :available_invites => 0) }

		[:new, :create].each do |action|
			describe "GET #{action}" do
				before { get action }
				it { should set_the_flash.to(/You don't have any invites!/) }
				it { should respond_with(:redirect) }
			end
		end
	end

	describe 'with available invites' do
		before do
			login(@user = create(:user, :available_invites => 5))
		end

		describe 'GET new' do
			before { get :new }
			it { should_not set_the_flash }
			it { should render_template(:new) }
			it { should assign_to(:invite).with_kind_of(Invite) }
		end

		describe 'POST create' do
			describe 'with a valid invitee' do
				before do
					post :create, :invite => {
						:email   => 'no-reply@example.com',
						:message => 'testing message'
					}
				end
				it { should assign_to(:invite).with_kind_of(Invite) }
				it { should set_the_flash.to(/Your invite has been sent/) }
				it { should respond_with(:redirect) }
				it 'redirects back to invites' do
					response.should redirect_to(invites_url)
				end
				it 'decrements available invites' do
					@user.reload
					@user.available_invites.should == 4
				end
				it 'sends a welcome email' do
					email = ActionMailer::Base.deliveries.first
					email.to[0].should eq('no-reply@example.com')
					email.body.to_s.should match(/testing message/)
				end
			end

			describe 'with an already existing user' do
				before do
					post :create, :invite => {
						:email => create(:user).email
					}
					it { should_not set_the_flash }
					it { should render_template(:new) }
					it { should assign_to(:invite).with_kind_of(Invite) }
					it 'does not decrement available invites' do
						@user.reload
						@user.available_invites.should == 5
					end
				end
			end
		end
	end

	describe 'GET all' do
		describe 'as a regular user' do
			before do
				login
				get :all
			end
			it { should set_the_flash }
			it { should respond_with(:redirect) }
			it 'redirects back to discussions' do
				response.should redirect_to(discussions_url)
			end
		end
	end

	describe 'when logged in as a user admin' do
		before do
			login(@user = create(:user_admin, :available_invites => 0))
		end
		describe 'GET all' do
			before { get :all }
			it { should_not set_the_flash }
			it { should respond_with(:success) }
			it { should render_template(:all) }
			it { should assign_to(:invites) }
		end

		describe 'POST create' do
			before do
				post :create, :invite => {
					:email   => 'no-reply@example.com',
					:message => 'testing message'
				}
			end
			it { should assign_to(:invite).with_kind_of(Invite) }
			it { should set_the_flash.to(/Your invite has been sent/) }
			it { should respond_with(:redirect) }
		end
	end


	describe 'GET accept' do
		describe 'with an existing invite' do
			before { @invite = create(:invite) }
			before { get :accept, :id => @invite.token }
			it { should assign_to(:invite).with_kind_of(Invite) }
			it { should_not set_the_flash }
			it 'redirects to the new user page' do
				response.should redirect_to(new_user_by_token_url(:token => @invite.token))
			end
		end

		describe 'with an expired invite' do
			before { @invite = create(:invite, :expires_at => 90.days.ago) }
			before { get :accept, :id => @invite.token }
			it { should assign_to(:invite).with_kind_of(Invite) }
			it { should set_the_flash.to(/Your invite has expired/) }
			it 'deletes the invite' do
				Invite.exists?(@invite).should be_false
			end
			it 'redirects to the login page' do
				response.should redirect_to(login_users_url)
			end
		end

		describe 'with an invalid token' do
			before { get :accept, :id => 'invalidtoken' }
			it 'does not find an invite' do
				assigns(:invite).should be_nil
			end
			it { should set_the_flash.to(/not a valid invite/) }
			it 'redirects to the login page' do
				response.should redirect_to(login_users_url)
			end
		end
	end

end
