# encoding: utf-8

namespace :sugar do

  desc "Pack themes"
  task :pack_themes => :environment do
    themes_dir = File.join(File.dirname(__FILE__), "../../public/themes")
    Dir.entries(themes_dir).select{|d| File.exists?(File.join(themes_dir, d, 'theme.yml'))}.each do |theme|
      `cd #{themes_dir} && zip -r #{theme}.zip #{theme}`
    end
  end

  desc "Pack themes"
  task :pack => [:pack_themes] do
  end

  desc "Disable web"
  task :disable_web => :environment  do
    require 'erb'
    reason = ENV['REASON'] || "DOWNTIME! The toobs are being vacuumed, check back in a couple of minutes."
    template_file = File.join(File.dirname(__FILE__), '../../config/maintenance.erb')
    template = ''; File.open(template_file){ |fh| template = fh.read }
    template = ERB.new(template)
    File.open(File.join(File.dirname(__FILE__), '../../public/system/maintenance.html'), "w") do |fh|
      fh.write template.result(binding)
    end
  end

  desc "Enable web"
  task :enable_web do
    maintenance_file = File.join(File.dirname(__FILE__), '../../public/system/maintenance.html')
    File.unlink(maintenance_file) if File.exist?(maintenance_file)
  end

  desc "Delete and reclaim expired invites"
  task :expire_invites => :environment do
    puts "Deleting expired invites"
    Invite.destroy_expired!
  end

  desc "Routine maintenance"
  task :routine => [:expire_invites] do
  end

  desc "Regenerate participated discussions"
  task :generate_participated_discussions => :environment do
    User.find(:all, :order => 'username ASC').each do |user|
      puts "Generating participated discussions for #{user.username}.."
      discussions = Discussion.find_by_sql("SELECT DISTINCT exchange_id AS id, trusted FROM posts WHERE user_id = #{user.id}")
      puts "  - #{discussions.length} discussions found, generating relationships"
      discussions.each do |d|
        DiscussionRelationship.define(user, d, :participated => true)
      end
    end
  end

  desc "Remove empty discussions"
  task :remove_empty_discussions => :environment do
    empty_discussions = Discussion.find(:all, :conditions => ['posts_count = 0'])
    puts "#{empty_discussions.length} empty discussions found, cleaning..."
    users      = empty_discussions.map{|d| d.poster}.compact.uniq
    categories = empty_discussions.map{|d| d.category}.compact.uniq
    empty_discussions.each do |d|
      d.destroy
    end
  end

end
