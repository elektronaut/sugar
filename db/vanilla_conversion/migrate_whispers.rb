require 'rubygems'
require 'mysql'

begin
    dbh = Mysql.real_connect('localhost', 'root', '', 'b3s_final')

    dbh.query("DELETE FROM messages")

    # Convert whispered discussions
    discussions_res = dbh.query("SELECT DiscussionID, WhisperUserID, AuthUserID, Name FROM LUM_Discussion WHERE WhisperUserID IS NULL OR WhisperUserID > 0;")
    while discussion = discussions_res.fetch_row do
        discussion_id, recipient_id, sender_id, subject = discussion
        posts_res = dbh.query("SELECT AuthUserID, Body, Deleted, DateCreated FROM LUM_Comment WHERE DiscussionID = #{discussion_id}")
        while post = posts_res.fetch_row do
            poster_id, body, deleted, created_at = post
            if poster_id == sender_id
                dbh.query("INSERT INTO messages (recipient_id, sender_id, subject, body, `read`, deleted, created_at, updated_at) 
                    VALUES (#{recipient_id}, #{sender_id}, '"+dbh.escape_string(subject)+"', '"+dbh.escape_string(body)+"', 1, #{deleted}, '#{created_at}', '#{created_at}')")
            else
                dbh.query("INSERT INTO messages (recipient_id, sender_id, subject, body, `read`, deleted, created_at, updated_at) 
                    VALUES (#{sender_id}, #{recipient_id}, '"+dbh.escape_string(subject)+"', '"+dbh.escape_string(body)+"', 1, #{deleted}, '#{created_at}', '#{created_at}')")
            end
        end
    end
    
    # In-thread whispers
    posts_res = dbh.query("SELECT c.AuthUserID, c.WhisperUserID, c.Body, c.Deleted, c.DateCreated, d.name FROM LUM_Comment c, LUM_Discussion d WHERE c.DiscussionID = d.DiscussionID AND c.WhisperUserID IS NOT NULL AND c.WhisperUserID > 0")
    while post = posts_res.fetch_row do
        sender_id, recipient_id, body, deleted, created_at, subject = post
        dbh.query("INSERT INTO messages (recipient_id, sender_id, subject, body, `read`, deleted, created_at, updated_at) 
            VALUES (#{recipient_id}, #{sender_id}, '"+dbh.escape_string(subject)+"', '"+dbh.escape_string(body)+"', 1, #{deleted}, '#{created_at}', '#{created_at}')")
    end
    

rescue Mysql::Error => e
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
ensure
    dbh.close if dbh
end
