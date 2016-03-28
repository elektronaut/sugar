# encoding: utf-8

module Sugar
  class FormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::OutputSafetyHelper

    def errors_on?(attribute)
      errors_on(attribute).any?
    end

    def errors_on(attribute)
      errors = object.errors[attribute] || []
      errors = [errors] unless errors.is_a?(Array)
      errors
    end

    def first_error_on(attribute)
      errors_on(attribute).first
    end

    def label(method, text = nil, options = {}, &_block)
      text ||= human_attribute_name(method)
      if errors_on?(method)
        text += content_tag(:span, " " + first_error_on(method), class: "error")
      elsif options[:description]
        text += content_tag(
          :span,
          " &mdash; #{options[:description]}".html_safe, class: "description"
        )
      end
      content_tag "label", text.html_safe, for: full_attribute_name(method)
    end

    def field_with_label(attribute, content, label_text = nil, options = {})
      classes = ["field"]
      classes << "field_with_errors" if errors_on?(attribute)

      label_tag = label(
        attribute,
        label_text,
        description: options[:description]
      )

      if options[:note]
        content = safe_join(
          [content, (options[:note]).to_s.html_safe],
          "<br>".html_safe
        )
      end

      content_tag "p", label_tag + content, class: classes.join(" ")
    end

    def labelled_text_field(attribute, label_text = nil, options = {})
      labelled_field(:text_field, attribute, label_text, options)
    end

    def labelled_text_area(attribute, label_text = nil, options = {})
      labelled_field(:text_area, attribute, label_text, options)
    end

    def labelled_date_select(attribute, label_text = nil, options = {})
      labelled_field(:date_select, attribute, label_text, options)
    end

    def labelled_datetime_select(attribute, label_text = nil, options = {})
      labelled_field(:datetime_select, attribute, label_text, options)
    end

    def labelled_time_select(attribute, label_text = nil, options = {})
      labelled_field(:time_select, attribute, label_text, options)
    end

    def labelled_file_field(attribute, label_text = nil, options = {})
      labelled_field(:file_field, attribute, label_text, options)
    end

    def labelled_password_field(attribute, label_text = nil, options = {})
      labelled_field(:password_field, attribute, label_text, options)
    end

    def labelled_time_zone_select(
          attribute,
          label_text = nil,
          priority_zones = nil,
          options = {}
    )
      label_text, options, field_options = parse_label_text_and_options(
        label_text,
        options
      )
      field_with_label(
        attribute,
        time_zone_select(attribute, priority_zones, options),
        label_text,
        field_options
      )
    end

    def labelled_select(attribute, choices, label_text = nil, options = {})
      label_text, options, field_options = parse_label_text_and_options(
        label_text,
        options
      )
      field_with_label(
        attribute,
        select(attribute, choices, options),
        label_text,
        field_options
      )
    end

    def labelled_check_box(attr, label = nil, options = {},
                           checked = "1", unchecked = "0")
      label, options, field_options =
        parse_label_and_opts(label, options)
      field_with_label(
        attr,
        check_box(attr, options, checked, unchecked),
        label,
        field_options
      )
    end

    private

    def extract_field_options(options)
      field_options = {}
      [:description, :note].each do |key|
        if options.key?(key)
          field_options[key] = options[key]
          options.delete(key)
        end
      end
      [options, field_options]
    end

    def full_attribute_name(attribute)
      [object.class.to_s.underscore, attribute].join("_")
    end

    def human_attribute_name(attribute)
      object.class.human_attribute_name(attribute)
    end

    def labelled_field(type, attribute, label_text = nil, options = {})
      label_text, options, field_options = parse_label_and_opts(
        label_text,
        options
      )
      field_with_label(
        attribute,
        send(type, attribute, options),
        label_text,
        field_options
      )
    end

    def parse_label_and_opts(label_text = nil, options = {})
      if label_text.is_a?(Hash) && options == {}
        options = label_text
        label_text = nil
      end
      [label_text, *extract_field_options(options)]
    end
  end
end
