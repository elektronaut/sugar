class Setting < ActiveRecord::Base
	class << self
		def set(key, value)
			key = key.to_s
			value = 0 if value === false
			value = 1 if value === true
			value = nil if value === ''
			setting = Setting.find_by_key(key)
			setting ||= Setting.create(:key => key)
			setting.update_attribute(:value, value)
		end
	end
end
