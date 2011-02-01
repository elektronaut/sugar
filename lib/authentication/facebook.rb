module Authentication
	module Facebook

		class << self
			# Injects the Facebook filters
			def included(base)
				base.send(:before_filter, :setup_facebook_session)
				base.send(:before_filter, :load_facebook_user)
			end
		end

		protected

			# Verifies and sets up the Facebook session
			def setup_facebook_session
				if Sugar.config(:facebook_app_id) && request.cookies["fbs_#{Sugar.config(:facebook_app_id)}"]
					# Parse the facebook session
					facebook_session = request.cookies["fbs_#{Sugar.config(:facebook_app_id)}"].gsub(/(^\"|\"$)/, '')
					facebook_session = CGI::parse(facebook_session).inject(Hash.new) do |memo, val|
						memo[val.first] = val.last.first
						memo
					end
					facebook_session.symbolize_keys!

					# Verify the payload
					payload = facebook_session.keys.sort_by{|k| k.to_s}.reject{|k| k == :sig}.map{|k| "#{k.to_s}=#{facebook_session[k]}"}.join
					expected_sig = Digest::MD5.hexdigest(payload + Sugar.config(:facebook_api_secret))
					if facebook_session[:sig] && !facebook_session[:sig].empty? && facebook_session[:sig] == expected_sig
						@facebook_session = facebook_session
					else
						@facebook_session = false
					end
				end
			end
			
			# Tries to set @current_user based on @facebook_session[:uid]
			def load_facebook_user
				if @facebook_session && @facebook_session[:uid]
					if user = User.find_by_facebook_uid(@facebook_session[:uid])
						# Update the access token if it has changed
						if @facebook_session[:access_token] && @facebook_session[:access_token] != user.facebook_access_token
							user.update_attribute(:facebook_access_token, @facebook_session[:access_token])
						end
						@current_user ||= user
					else
						if Sugar.config(:signups_allowed)
							flash[:notice] = "You must choose a username before connecting"
							redirect_to new_user_url(:anchor => 'facebook') and return
						else
							flash[:notice] = "Your Facebook account wasn't recognized"
							redirect_to login_users_url and return
						end
					end
				end
			end

	end
end