class AdminController < ApplicationController
	def configuration
		unless @current_user && @current_user.admin?
			flash[:notice] = "You don't have permission to view this page"
			redirect_to root_url and return
		end
		if request.post? && params[:config]
			Sugar.update_configuration(params[:config])
		end
	end
end
