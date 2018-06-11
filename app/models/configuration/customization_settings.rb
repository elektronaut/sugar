# frozen_string_literal: true

class Configuration
  module CustomizationSettings
    extend ActiveSupport::Concern
    included do
      setting :forum_name, :string, "Sugar"
      setting :forum_short_name, :string, "Sugar"
      setting :forum_title, :string, "Sugar"
      setting :public_browsing, :boolean, false
      setting :signups_allowed, :boolean, true
      setting :domain_names, :string
      setting :mail_sender, :string

      # Customization
      setting :code_of_conduct, :string
      setting :custom_header, :string
      setting :custom_footer, :string
      setting :custom_javascript, :string
      setting(
        :emoticons,
        :string,
        "smiley laughing blush heart_eyes kissing_heart flushed worried " \
        "grimacing cry angry heart star +1 -1"
      )
    end
  end
end
