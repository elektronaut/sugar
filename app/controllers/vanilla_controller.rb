# Controller for redirecting old URLs
class VanillaController < ApplicationController

	# /vanilla/?page=2
	# /vanilla/?CategoryID=11
	def discussions
		headers["Status"] = "301 Moved Permanently"
		if params[:CategoryID]
			redirect_to category_url(params[:CategoryID])
		else
			redirect_to paged_discussions_path(:page => (params[:page] || 1))
		end
	end

	# /vanilla/comments.php?DiscussionID=13892&page=6
	def discussion
		headers["Status"] = "301 Moved Permanently"
		redirect_to paged_discussion_url(:id => params[:DiscussionID], :page => params[:page])
	end

	# /vanilla/account.php?u=4
	def user
		headers["Status"] = "301 Moved Permanently"
		redirect_to user_url(:id => params[:u])
	end

end
