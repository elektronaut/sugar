module HumanizableParam
  extend ActiveSupport::Concern

  def humanized_param(slug)
    slug = slug.gsub(/[\[\{]/,'(')
    slug = slug.gsub(/[\]\}]/,')')
    slug = slug.gsub(/[^\w\d!$&'()*,;=\-]+/,'-').gsub(/[\-]{2,}/,'-').gsub(/(^\-|\-$)/,'')
    "#{self.id.to_s};" + slug
  end
end