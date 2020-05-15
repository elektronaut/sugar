# frozen_string_literal: true

namespace :sugar do
  desc "Delete all posts for a given user"
  task delete_posts: :environment do
    user = User.find_by(id: ENV["USER_ID"])
    unless user
      puts "Usage: #{$PROGRAM_NAME} sugar:delete_posts USER_ID=<id>"
      exit
    end
    puts "Deleting #{user.discussion_posts.count} posts..."
    user.discussion_posts.update(deleted: true)
    user.update(public_posts_count: 0)
  end

  desc "Scrub private data from the database"
  task scrub_private_data: :environment do
    keep_users = ENV["KEEP_USERS"].split(",").map(&:to_i)

    Conversation.delete_all
    Post.where(conversation: true).delete_all
    PasswordResetToken.delete_all

    User.all.reject { |u| keep_users.include?(u.id) }.each do |u|
      u.update(hashed_password: "", persistence_token: "")
    end
  end
end
