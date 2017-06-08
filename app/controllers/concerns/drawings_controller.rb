module DrawingsController
  extend ActiveSupport::Concern

  def drawing
    create_post(drawing_params.merge(user: current_user))
  end

  protected

  def drawing_params
    post_image = PostImage.create(data: Base64.decode64(params[:drawing]),
                                  content_type: "image/jpeg",
                                  filename: "drawing.jpg")
    return {} unless post_image.valid?
    {
      body: '<div class="drawing">' \
        "[image:#{post_image.id}:#{post_image.content_hash}]" \
        "</div>"
    }
  end
end
