class InvitesController < ApplicationController

	requires_authentication :except => [:accept]
	requires_user           :except => [:accept]
    
	before_filter :load_invite,    :only => [:show, :edit, :update, :destroy]
	before_filter :verify_invites, :only => [:new, :create]

	protected
	
		# Loads the requested invite
		def load_invite
			@invite = Invite.find(params[:id]) rescue nil
			unless @invite
				flash[:notice] = "Could not find invite with ID ##{params[:id]}"
				redirect_to invites_url and return
			end
		end
	
		# Verifies that the user has available invites
		def verify_invites
			unless @current_user && @current_user.available_invites?
				flash[:notice] = "You don't have any invites!"
				redirect_to online_users_url
			end
		end

	public
	
		# Show active invites
		def index
			@invites = @current_user.invites.active
		end

		# Show everyone's invites
		def all
			require_user_admin_or_user(nil, :redirect => invites_url)
			@invites = Invite.find_active
		end

		# Accept an invite
		def accept
			@invite = Invite.first(:conditions => {:token => params[:id]})
			if @invite && @invite.expired?
				@invite.destroy
				flash[:notice] ||= "Your invite has expired!"
			elsif @invite
				redirect_to new_user_by_token_url(:token => @invite.token) and return
			else
				flash[:notice] ||= "That's not a valid invite!"
			end
			redirect_to login_users_url and return
		end

		# Create a new invite
		def new
			@invite = @current_user.invites.new
		end
	
		# Create a new invite
		def create
			@invite = @current_user.invites.create(params[:invite])
			if @invite.valid?
				begin
					Mailer.invite(@invite, accept_invite_url(:id => @invite.token)).deliver
					flash[:notice] = "Your invite has been sent to #{@invite.email}"
				rescue
					flash[:notice] = "There was a problem sending your invite to #{@invite.email}, it has been cancelled."
					@invite.destroy
				end
				redirect_to invites_url and return
			else
				render :action => :new
			end
		end
	
		# def show
		# 	require_user_admin_or_user(@invite.user, :redirect => invites_url)
		# 	render :action => :edit
		# end
		#
		# def edit
		# 	require_admin_or_user(@invite.user, :redirect => invites_url)
		# end
		# 
		# def update
		# 	require_admin_or_user(@invite.user, :redirect => invites_url)
		# 	if @invite.update_attributes(params[:invite])
		# 		flash[:notice] = "Invite was updated"
		# 		redirect_to invites_url and return
		# 	else
		# 		render :action => :edit
		# 	end
		# end

		# Delete an invite
		def destroy
			require_user_admin_or_user(@invite.user, :redirect => invites_url)
			@invite.destroy
			flash[:notice] = "Your invite has been cancelled."
			redirect_to invites_url and return
		end

end