# encoding: utf-8

module Sugar
  class FormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::OutputSafetyHelper

    # Are there any errors on this attribute?
    def errors_on?(attribute)
      errors_on(attribute).length > 0
    end

    # Returns all errors for the attribute
    def errors_on(attribute)
      errors = object.errors[attribute] || []
      errors = [errors] unless errors.kind_of?(Array)
      errors
    end

    # Returns the first error on attribute
    def first_error_on(attribute)
      errors_on(attribute).first
    end

    def image_file_field(attribute, options={})
      if object.send(attribute)
        content_tag('p', @template.dynamic_image_tag(object.send(attribute), :size => '120x100')) +
        self.file_field(attribute, options)
      else
        self.file_field(attribute, options)
      end
    end

    def field_with_label(attribute, content, label_text=nil, options={})
      classes = ['field']
      classes << 'field_with_errors' if errors_on?(attribute)

      label_text ||= object.class.human_attribute_name(attribute)

      if errors_on?(attribute)
        label_text += " <span class=\"error\">#{first_error_on(attribute)}</span>"
      elsif options[:description]
        label_text += content_tag(:span, " &mdash; #{options[:description]}".html_safe, class: "description")
      end

      label_tag = content_tag 'label', label_text.html_safe, :for => [object.class.to_s.underscore, attribute].join('_')

      if options[:note]
        content = safe_join([content, "#{options[:note]}".html_safe], "<br>".html_safe)
      end

      content_tag 'p', label_tag + content, :class => classes.join(' ')
    end

    def labelled_text_field(attribute, label_text=nil, options={})
      label_text, options, field_options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.text_field(attribute, options), label_text, field_options)
    end

    def labelled_text_area(attribute, label_text=nil, options={})
      label_text, options, field_options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.text_area(attribute, options), label_text, field_options)
    end

    def labelled_date_select(attribute, label_text=nil, options={})
      label_text, options, field_options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.date_select(attribute, options), label_text, field_options)
    end

    def labelled_datetime_select(attribute, label_text=nil, options={})
      label_text, options, field_options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.datetime_select(attribute, options), label_text, field_options)
    end

    def labelled_time_select(attribute, label_text=nil, options={})
      label_text, options, field_options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.time_select(attribute, options), label_text, field_options)
    end

    def labelled_time_zone_select(attribute, label_text=nil, priority_zones=nil, options={})
      label_text, options, field_options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.time_zone_select(attribute, priority_zones, options), label_text, field_options)
    end

    def labelled_select(attribute, choices, label_text=nil, options={})
      label_text, options, field_options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.select(attribute, choices, options), label_text, field_options)
    end

    def labelled_check_box(attribute, label_text=nil, options={}, checked_value="1", unchecked_value="0")
      label_text, options, field_options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.check_box(attribute, options, checked_value, unchecked_value), label_text, field_options)
    end

    def labelled_file_field(attribute, label_text=nil, options={})
      label_text, options, field_options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.file_field(attribute, options), label_text, field_options)
    end

    def labelled_image_file_field(attribute, label_text=nil, options={})
      label_text, options, field_options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.image_file_field(attribute, options), label_text, field_options)
    end

    def labelled_password_field(attribute, label_text=nil, options={})
      label_text, options, field_options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.password_field(attribute, options), label_text, field_options)
    end

    protected

    def extract_field_options(options)
      field_options = {}
      [:description, :note].each do |key|
        if options.has_key?(key)
          field_options[key] = options[key]
          options.delete(key)
        end
      end
      [options, field_options]
    end

    def parse_label_text_and_options(label_text=nil, options={})
      if label_text.kind_of?(Hash) && options == {}
        options = label_text
        label_text = nil
      end
      [label_text, *extract_field_options(options)]
    end

  end
end
