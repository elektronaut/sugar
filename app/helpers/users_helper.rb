module UsersHelper
	# <%= users_tab "All Users", users_path, :action => 'index', :class => 'AllUsersTab' %>

	def users_tab(name, path, options={})
		classes = ['tab', options[:class]].compact
		classes << 'active' if options[:action] && options[:action] == params[:action]
		("<li class=\"#{classes.join(' ')}\">"+link_to(name, path)+"</li>").html_safe
	end
end