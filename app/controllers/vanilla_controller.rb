# Controller for redirecting old URLs
class VanillaController < ApplicationController

    # http://butt3rscotch.org/vanilla/?page=2
    # http://butt3rscotch.org/vanilla/?CategoryID=11
    def discussions
        if params[:CategoryID]
            redirect_to category_url(params[:CategoryID])
        else
            redirect_to paged_discussions_path(:page => (params[:page] || 1))
        end
    end

    # http://butt3rscotch.org/vanilla/comments.php?DiscussionID=13892&page=6
    def discussion
        redirect_to paged_discussion_url(:id => params[:DiscussionID], :page => params[:page])
    end

    # http://butt3rscotch.org/vanilla/account.php?u=4
    def user
        redirect_to user_url(:id => params[:u])
    end

end
