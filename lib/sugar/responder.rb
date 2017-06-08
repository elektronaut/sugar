module Sugar
  class Responder < ActionController::Responder
    def to_mobile
      default_render
    rescue ActionView::MissingTemplate => e
      navigation_behavior(e)
    end
  end
end
