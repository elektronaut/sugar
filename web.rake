# frozen_string_literal: true

namespace :web do
  desc "Disable web"
  task disable: :environment do
    require "erb"
    @reason = ENV["REASON"] || "DOWNTIME! The toobs are being vacuumed, " \
                               "check back in a couple of minutes."
    template_file = File.join(File.dirname(__FILE__),
                              "../../config/maintenance.erb")
    template = ""
    File.open(template_file) { |fh| template = fh.read }
    template = ERB.new(template)
    File.open(
      File.join(File.dirname(__FILE__), "../../public/system/maintenance.html"),
      "w"
    ) do |fh|
      fh.write template.result(binding)
    end
  end

  desc "Enable web"
  task enable: :environment do
    maintenance_file = File.join(File.dirname(__FILE__),
                                 "../../public/system/maintenance.html")
    File.unlink(maintenance_file) if File.exist?(maintenance_file)
  end
end
