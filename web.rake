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
    File.write(File.join(File.dirname(__FILE__),
                         "../../public/system/maintenance.html"),
               template.result(binding))
  end

  desc "Enable web"
  task enable: :environment do
    maintenance_file = File.join(File.dirname(__FILE__),
                                 "../../public/system/maintenance.html")
    FileUtils.rm_f(maintenance_file)
  end
end
