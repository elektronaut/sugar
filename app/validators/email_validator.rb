require 'mail'

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      email = Mail::Address.new(value)
      valid = email.domain && email.address == value
      tree = email.__send__(:tree)
      valid &&= (tree.domain.dot_atom_text.elements.size > 1)
    rescue Exception => e
      valid = false
    end
    record.errors[attribute] << (options[:message] || "is invalid") unless valid
  end
end