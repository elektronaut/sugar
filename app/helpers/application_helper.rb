# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	def formatted_time(time, options={})
		return "Never" unless time
		if time > 14.days.ago
			time_ago_in_words(time)+" ago"
		else
			time.strftime("%b %d, %Y")
		end
	end

	def meify(string, user)
		string.gsub(/(^|\<[\w]+\s?\/?\>|[\s])\/me/){ $1 + profile_link(user, nil, :class => :poster) }.html_safe
	end

	def pretty_link(url)
		url = "http://"+url unless url =~ /^(f|ht)tps?:\/\//
		url = url.gsub(/\/$/, '') if url =~ /^(f|ht)tps?:\/\/[\w\d\-\.]*\/$/
		link_to url.gsub(/^(f|ht)tps?:\/\//, ''), url
	end

	# Generate HTML for a field, with label and optionally description and errors.
	#
	# The options are:
	# * <tt>:description</tt>: Description of the field
	# * <tt>:errors</tt>:      Error messages for the attribute
	#
	# An example:
	#   <% form_for 'user', @user do |f| %>
	#     <%= labelled_field f.text_field( :username ), "Username", 
	#                        :description => "Choose your username, minimum 4 characters", 
	#                        :errors => @user.errors[:username] %>
	#     <%= submit_tag "Save" %>
	#   <% end %>
	#
	def labelled_field(field, label=nil, options={}, &block)
		if !options[:errors].blank?
			output  = '<p class="field field_with_errors">'
		else
			output  = '<p class="field">'
		end
		output += "<label>#{label}" if label
		if options[:errors]
			error = options[:errors]
			error = error.last if error.kind_of? Array
			output += ' <span class="error">' + error.to_s + '</span>'
		end
		output += "<span class=\"description\"> &mdash; #{options[:description]}</span>" if options[:description]
		output += "</label>" if label
		output += field
		output += "<br />"+capture(&block) if block_given?
		output += "</p>"
		return output.html_safe
	end
	
	# Generates avatar image tag for a user
	def avatar_image_tag(user, size='32')
		if user.avatar_url?
			image_tag user.avatar_url, :alt => user.username, :size => "#{size}x#{size}"
		else
			image_tag user.gravatar_url(:size => size), :alt => user.username, :size => "#{size}x#{size}"
		end
	end

	def add_body_class(*class_names)
		@body_classes ||= []
		@body_classes += [class_names].flatten # Should also work with arrays
	end

	def body_classes
		@body_classes ||= []
		@body_classes << 'with_sidebar' if content_for?(:sidebar) && !@body_classes.include?('with_sidebar')
		@body_classes.uniq.join(' ')
	end

	def possessive(noun)
		(noun =~ /s$/) ? "#{noun}'" : "#{noun}'s"
	end

	# Generates a link to the users profile
	def profile_link(user, link_text=nil, options={})
		if user
			link_text ||= user.username
			link_to link_text, user_profile_path(:id => user.username), {:title => "#{possessive(user.username)} profile"}.merge(options)
		else
			"Unknown"
		end
	end

	# Class names for discussion
	def discussion_classes(discussions, discussion)
		@_discussion_classes ||= {}
		@_discussion_classes[[discussions, discussion]] ||= [discussion.labels.map(&:downcase), %w{odd even}[discussions.index(discussion)%2], (new_posts?(discussion) ? 'new_posts' : nil), "in_category#{discussion.category_id}", "by_user#{discussion.poster_id}", "discussion", "discussion#{discussion.id}"].flatten.compact.join(' ')
	end

	# Class names for conversation
	def conversation_classes(users, user)
		[%w{odd even}[users.index(user)%2], (@current_user.unread_messages_from?(user) ? 'new_posts' : nil), "by_user#{user.id}", "conversation#{user.id}", "conversation"].flatten.compact.join(' ')
	end

	def format_post(string)
		PostParser.parse(string)
	end

	def last_viewed_post(discussion)
		return discussion.posts_count unless @discussion_views
	end

	def discussion_view(discussion, user)
		return nil unless @discussion_views
		@_discussion_view_lookup_table ||= @discussion_views.inject(Hash.new) do |hash, dv|
			hash[[dv.discussion_id, dv.user_id]] = dv unless hash[[dv.discussion_id, dv.user_id]] && hash[[dv.discussion_id, dv.user_id]].post_index > dv.post_index
			hash
		end
		@_discussion_view_lookup_table[[discussion.id, user.id]] ||= DiscussionView.new(:user_id => user.id, :discussion_id => discussion.id, :post_index => 0)
	end

	def new_posts_count(discussion)
		return 0 unless @discussion_views
		discussion.posts_count - discussion_view(discussion, @current_user).post_index
	end

	def new_posts?(discussion)
		return false unless @discussion_views
		@_new_posts ||= {}
		@_new_posts[discussion] ||= (new_posts_count(discussion) > 0) ? true : false
	end

	def last_discussion_page(discussion)
		return 1 unless @current_user
		return discussion.last_page unless @discussion_views && new_posts?(discussion)
		page = (discussion_view(discussion, @current_user)[:post_index].to_f / Post::POSTS_PER_PAGE).ceil
		page = 1 if page < 1
		page
	end

	def last_discussion_page_path(d)
		if ((last_page = last_discussion_page(d)) > 1)
			if @discussion_views && last_post_id = discussion_view(d, @current_user).post_id
				paged_discussion_path(:id => d.to_param, :page => last_page, :anchor => "post-#{last_post_id}")
			else
				paged_discussion_path(:id => d.to_param, :page => last_page)
			end
		else
			if @discussion_views && last_post_id = discussion_view(d, @current_user).post_id
				discussion_path(:id => d.to_param, :anchor => "post-#{last_post_id}")
			else
				discussion_path(:id => d.to_param)
			end
		end
	end

	def theme_path(theme_name=nil)
		theme_format = (request.format == :mobile) ? 'mobile' : 'regular'
		theme_name ||= (request.format == :mobile) ? Sugar.config(:default_mobile_theme) : Sugar.config(:default_theme)
		"/themes/#{theme_format}/#{theme_name}"
	end

	def search_mode_options
		options = [['in discussions', search_path], ['in posts', search_posts_path]]
		options << ['in this discussion', search_posts_discussion_path(@discussion)] if @discussion && @discussion.id
		options
	end

	def post_page(post)
		if params[:controller] == 'discussions' && params[:action] == 'show' && @posts
			# Speed tweak
			@posts.page
		else
			post.page
		end
	end
	
	def header_tab(name, url, options={})
		options[:section] ||= name.downcase.to_sym
		options[:id]      ||= "#{options[:section]}_link"
		options[:class]   ||= []
		options[:class]   = [options[:class]] unless options[:class].kind_of?(Array)

		classes = [options[:section].to_s] + options[:class]
		classes << 'current' if @section == options[:section]
		
		content_tag(
			:li, 
			link_to(name, url, :id => options[:id]), 
			:class => classes
		)
	end

end
