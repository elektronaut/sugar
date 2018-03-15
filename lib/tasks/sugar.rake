# encoding: utf-8

namespace :sugar do
  desc "Delete all posts for a given user"
  task delete_posts: :environment do
    user = User.find_by(id: ENV["USER_ID"])
    unless user
      puts "Usage: #{$0} sugar:delete_posts USER_ID=<id>"
      exit
    end
    puts "Deleting #{user.discussion_posts.count} posts..."
    user.discussion_posts.update(deleted: true)
    user.update(public_posts_count: 0)
  end

  desc "Fix quoted post images"
  task fix_quoted_post_images: :environment do
    ex = /\/post_images\/([\w\d]{40})\/([\d]+x[\d]+)\/([\d]+)-[\d]+\.[\w]+/
    Post.where("body LIKE \"%/post_images/%\"").each do |post|
      new_body = post.body.gsub(ex) do |s|
        digest, size, id = $1, $2, $3
        new_digest = DynamicImage.digest_verifier.generate("show-#{id}-#{size}")
        s.gsub(digest, new_digest)
      end
      if post.body != new_body
        post.update_columns(
          body: new_body,
          body_html: nil
        )
      end
    end
  end

  desc "Scrub private data from the database"
  task scrub_private_data: :environment do
    keep_users = ENV["KEEP_USERS"].split(",").map(&:to_i)

    Conversation.delete_all
    Discussion.where(trusted: true).delete_all
    Post.where(trusted: true).delete_all
    Post.where(conversation: true).delete_all
    PasswordResetToken.delete_all

    User.all.reject { |u| keep_users.include?(u.id) }.each do |u|
      u.update_columns(hashed_password: "", persistence_token: "")
    end
  end

  desc "Move napkin drawings to S3"
  task upload_drawings: :environment do
    base_path = Rails.root.join("public/doodles")
    files = Dir.entries(base_path).select { |f| f =~ /\.jpg/ }
    posts = Post.find_by_sql(
      'SELECT * FROM posts WHERE body LIKE "%src=\"/doodles%"'
    )
    puts "Updating #{files.length} drawings in #{posts.length} posts..."

    files.each_with_index do |filename, i|
      path = base_path.join(filename)
      File.open(path) do |file|
        upload = Upload.create(file, name: filename)
        if upload.valid?
          pattern = "/doodles/#{filename}"
          posts.select { |p| p.body.match(pattern) }.each do |post|
            post.update_attributes(body: post.body.gsub(pattern, upload.url))
          end
          File.unlink(path)
        end
      end
      puts "Uploaded #{i}/#{files.length}..." if i > 20 && i % 20 == 0
    end
  end

  desc "Pack themes"
  task pack_themes: :environment do
    themes_dir = File.join(File.dirname(__FILE__), "../../public/themes")
    themes = Dir.entries(themes_dir).select do |d|
      File.exist?(File.join(themes_dir, d, "theme.yml"))
    end
    themes.each do |theme|
      `cd #{themes_dir} && zip -r #{theme}.zip #{theme}`
    end
  end

  desc "Pack themes"
  task pack: [:pack_themes] do
  end

  desc "Disable web"
  task disable_web: :environment do
    require "erb"
    @reason = ENV["REASON"] || "DOWNTIME! The toobs are being vacuumed, " \
                               "check back in a couple of minutes."
    template_file = File.join(
      File.dirname(__FILE__),
      "../../config/maintenance.erb"
    )
    template = ""
    File.open(template_file) { |fh| template = fh.read }
    template = ERB.new(template)
    File.open(
      File.join(File.dirname(__FILE__), "../../public/system/maintenance.html"),
      "w") do |fh|
      fh.write template.result(binding)
    end
  end

  desc "Enable web"
  task :enable_web do
    maintenance_file = File.join(
      File.dirname(__FILE__),
      "../../public/system/maintenance.html"
    )
    File.unlink(maintenance_file) if File.exist?(maintenance_file)
  end

  desc "Delete and reclaim expired invites"
  task expire_invites: :environment do
    puts "Deleting expired invites"
    Invite.destroy_expired!
  end

  desc "Routine maintenance"
  task routine: [:expire_invites] do
  end

  desc "Regenerate participated discussions"
  task generate_participated_discussions: :environment do
    User.find(:all, order: "username ASC").each do |user|
      puts "Generating participated discussions for #{user.username}.."
      discussions = Discussion.find_by_sql(
        "SELECT DISTINCT exchange_id AS id, trusted " \
          "FROM posts WHERE user_id = #{user.id}"
      )
      puts "  - #{discussions.length} discussions found, " \
           "generating relationships"
      discussions.each do |d|
        DiscussionRelationship.define(user, d, participated: true)
      end
    end
  end

  desc "Remove empty discussions"
  task remove_empty_discussions: :environment do
    empty_discussions = Discussion.find(:all, conditions: ["posts_count = 0"])
    puts "#{empty_discussions.length} empty discussions found, cleaning..."
    empty_discussions.each(&:destroy)
  end
end
