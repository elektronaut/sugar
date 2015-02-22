module DrawingsController
  extend ActiveSupport::Concern

  included do
    before_action :require_s3, only: [:drawing]
  end

  def drawing
    create_post(drawing_params.merge(user: current_user))
  end

  protected

  def drawing_file(&block)
    Tempfile.open("drawing.jpg", encoding: "ascii-8bit") do |file|
      data = Base64.decode64(params[:drawing])
      file.write(data)
      file.rewind
      block.call(file)
    end
  end

  def drawing_params
    drawing_file do |file|
      upload = Upload.create(file, name: "drawing.jpg")
      if upload.valid?
        {
          body: "<div class=\"drawing\">" +
            "<img src=\"#{upload.url}\" alt=\"Drawing\" />" +
            "</div>"
        }
      else
        {}
      end
    end
  end
end
