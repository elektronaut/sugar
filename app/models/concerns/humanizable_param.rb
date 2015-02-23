module HumanizableParam
  extend ActiveSupport::Concern

  def humanized_param(slug)
    "#{id}-" + slug.
      gsub(/[\[\{]/, "(").
      gsub(/[\]\}]/, ")").
      gsub(/[^\w\d!$&'()*,;=\-]+/, "-").
      gsub(/[\-]{2,}/, "-").
      gsub(/(^\-|\-$)/, "")
  end
end
