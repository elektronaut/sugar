
-- Categories

RENAME TABLE LUM_Category TO categories;
ALTER TABLE categories 
	CHANGE CategoryID id INTEGER(11) NOT NULL auto_increment,
	CHANGE Name name VARCHAR(255),
	CHANGE Description description TEXT,
	CHANGE Priority position INTEGER(11),
	DROP COLUMN Subscribeable,
	ADD COLUMN created_at DATETIME default NULL,
	ADD COLUMN updated_at DATETIME default NULL,
	ADD COLUMN discussions_count INTEGER(11) NOT NULL default '0',
	ADD COLUMN `trusted` tinyint(1) NOT NULL default '0',
	ENGINE = InnoDB DEFAULT CHARSET=utf8;

UPDATE categories SET created_at = NOW(), updated_at = NOW();
DROP INDEX CategoryID ON categories;

-- Posts

RENAME TABLE LUM_Comment TO posts;
-- Delete whispers
DELETE FROM posts WHERE Deleted = '1';
DELETE FROM posts WHERE DiscussionID IN (SELECT DiscussionID FROM LUM_Discussion WHERE WhisperUserID IS NULL OR WhisperUserID > 0);
DELETE FROM posts WHERE WhisperUserID IS NOT NULL AND WhisperUserID > 0;
ALTER TABLE posts 
	CHANGE CommentID id INTEGER(11) NOT NULL auto_increment,
	CHANGE DiscussionID discussion_id INTEGER(11),
	CHANGE AuthUserID user_id INTEGER(11),
	CHANGE DateCreated created_at datetime default NULL,
	CHANGE DateEdited updated_at datetime default NULL,
	DROP COLUMN EditUserID,
	DROP COLUMN WhisperUserID,
	CHANGE Body body text,
	CHANGE FormatType format_type varchar(255),
	DROP COLUMN Deleted,
	DROP COLUMN DateDeleted,
	DROP COLUMN DeleteUserID,
	DROP COLUMN RemoteIp,
	ADD COLUMN body_html text NULL,
	ENGINE = InnoDB DEFAULT CHARSET=utf8;
	
UPDATE posts SET updated_at = created_at;

DROP INDEX CommentID ON posts;
DROP INDEX DiscussionID ON posts;
DROP INDEX DiscussionID_2 ON posts;

CREATE INDEX user_id_index ON posts (user_id);
CREATE INDEX discussion_id_index ON posts (discussion_id);
CREATE INDEX created_at_index ON posts (created_at);

-- Discussions

RENAME TABLE LUM_Discussion TO discussions;
-- Delete whispered discussions
DELETE FROM discussions WHERE WhisperUserID IS NULL OR WhisperUserID > 0;
ALTER TABLE discussions
	CHANGE DiscussionID id int(11) NOT NULL auto_increment,
	DROP COLUMN AuthUserID,
	CHANGE FirstCommentID poster_id int(11),
	CHANGE LastUserID last_poster_id int(11),
	DROP COLUMN active,
	CHANGE Closed closed tinyint(1) NOT NULL default '0',
	CHANGE Sticky sticky tinyint(1) NOT NULL default '0',
	CHANGE Name title VARCHAR(255),
	CHANGE DateCreated created_at datetime,
	CHANGE DateLastActive last_post_at datetime,
	ADD COLUMN updated_at datetime NULL,
	DROP COLUMN CountComments,
	DROP COLUMN WhisperUserID,
	CHANGE CategoryID category_id int(11),
	DROP COLUMN WhisperToLastUserID,
	DROP COLUMN WhisperFromLastUserID,
	DROP COLUMN DateLastWhisper,
	DROP COLUMN TotalWhisperCount,
	DROP COLUMN Sink,
	ADD COLUMN nsfw tinyint(1) NOT NULL default '0',
	ADD COLUMN `trusted` tinyint(1) NOT NULL default '0',
	ADD COLUMN posts_count int(11) default '0',
	ENGINE = InnoDB DEFAULT CHARSET=utf8;

UPDATE discussions SET updated_at = created_at;
UPDATE discussions SET sticky = 0 WHERE closed = 2;
UPDATE discussions SET sticky = 0 WHERE sticky = 2;

DROP INDEX CategoryID ON discussions;
DROP INDEX LastUserID ON discussions;
DROP INDEX FirstCommentID ON discussions;

CREATE INDEX poster_id_index ON discussions (poster_id);
CREATE INDEX category_id_index ON discussions (category_id);
CREATE INDEX created_at_index ON discussions (created_at);
CREATE INDEX last_post_at_index ON discussions (last_post_at);
CREATE INDEX sticky_index ON discussions (sticky);

-- Users

RENAME TABLE LUM_User TO users;
ALTER TABLE users ADD COLUMN realname VARCHAR(255) NULL;
UPDATE users SET realname = CONCAT(FirstName, " ", LastName);
ALTER TABLE users
	CHANGE UserID id int(11) NOT NULL auto_increment,
	DROP COLUMN StyleID,
	DROP COLUMN CustomStyle,
	DROP COLUMN FirstName,
	DROP COLUMN LastName,
	CHANGE Name username VARCHAR(255),
	CHANGE `Password` hashed_password VARCHAR(255),
	DROP COLUMN VerificationKey,
	DROP COLUMN EmailVerificationKey,
	CHANGE Email email VARCHAR(255),
	DROP COLUMN UtilizeEmail,
	DROP COLUMN ShowName,
	DROP COLUMN Icon,
	DROP COLUMN Picture,
	DROP COLUMN CountVisit,
	DROP COLUMN CountDiscussions,
	DROP COLUMN CountComments,
	CHANGE DateFirstVisit created_at datetime,
	CHANGE DateLastActive last_active datetime,
	DROP COLUMN RemoteIp,
	DROP COLUMN LastDiscussionPost,
	DROP COLUMN DiscussionSpamCheck,
	DROP COLUMN LastCommentPost,
	DROP COLUMN CommentSpamCheck,
	DROP COLUMN UserBlocksCategories,
	DROP COLUMN DefaultFormatType,
	DROP COLUMN SendNewApplicantNotifications,
	DROP COLUMN Preferences,
	DROP COLUMN SubscribeOwn,
	DROP COLUMN Notified,
	CHANGE InvitationID inviter_id int(11),
	DROP COLUMN InvitationsSent,
	DROP COLUMN InvitationsAllowed,
	DROP COLUMN Attributes,
	DROP COLUMN Discovery,
	ADD COLUMN updated_at datetime NULL,
	ADD COLUMN `description` text,
	ADD COLUMN `banned` tinyint(1) NOT NULL default '0',
	ADD COLUMN `activated` tinyint(1) NOT NULL default '0',
	ADD COLUMN `user_admin` tinyint(1) NOT NULL default '0',
	ADD COLUMN `moderator` tinyint(1) NOT NULL default '0',
	ADD COLUMN `admin` tinyint(1) NOT NULL default '0',
	ADD COLUMN `trusted` tinyint(1) NOT NULL default '0',
	ADD COLUMN `posts_count` int(11) NOT NULL default '0',
	ADD COLUMN `discussions_count` int(11) default '0',
	ADD COLUMN `location` varchar(255) default NULL,
	ADD COLUMN `birthday` date default NULL,
	ADD COLUMN `stylesheet_url` varchar(255) default NULL,
	ADD COLUMN `work_safe_urls` tinyint(1) NOT NULL default '0',
	ADD COLUMN `gamertag` varchar(255) default NULL,
	ADD COLUMN `html_disabled` tinyint(1) NOT NULL default '0',
	ENGINE = InnoDB DEFAULT CHARSET=utf8;
	
-- Misc. roles
UPDATE users SET banned = '1'     WHERE RoleID = 1;
UPDATE users SET admin = '1'      WHERE RoleID = 6;
UPDATE users SET user_admin = '1' WHERE RoleID = 5;
UPDATE users SET moderator = '1'  WHERE RoleID = 8;
UPDATE users SET moderator = '1'  WHERE RoleID = 4;

-- Trusted people
UPDATE users SET trusted = '1'    WHERE RoleID = 4;
UPDATE users SET trusted = '1'    WHERE RoleID = 5;
UPDATE users SET trusted = '1'    WHERE RoleID = 6;
UPDATE users SET trusted = '1'    WHERE RoleID = 8;
UPDATE users SET trusted = '1'    WHERE RoleID = 15;

ALTER TABLE users DROP COLUMN RoleID;
	
UPDATE users SET updated_at = NOW();
UPDATE users SET activated = '1';

DROP INDEX InvitationID ON users;
CREATE INDEX username_index ON users (username);


-- Fix poster_id on discussions
UPDATE discussions SET poster_id = (SELECT user_id FROM posts WHERE posts.discussion_id = discussions.id ORDER BY id ASC LIMIT 1);

-- Update last post counts
UPDATE discussions SET posts_count       = (SELECT COUNT(*) FROM posts WHERE posts.discussion_id = discussions.id);
UPDATE categories  SET discussions_count = (SELECT COUNT(*) FROM discussions WHERE discussions.category_id = categories.id);
UPDATE users       SET discussions_count = (SELECT COUNT(*) FROM discussions WHERE discussions.poster_id = users.id);
UPDATE users       SET posts_count       = (SELECT COUNT(*) FROM posts WHERE posts.user_id = users.id);


-- Bring the scema up to speed on rails migrations

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `schema_migrations` (`version`) VALUES ('20080625185118');
INSERT INTO `schema_migrations` (`version`) VALUES ('20080625202342');
INSERT INTO `schema_migrations` (`version`) VALUES ('20080625202348');
INSERT INTO `schema_migrations` (`version`) VALUES ('20080625213006');
INSERT INTO `schema_migrations` (`version`) VALUES ('20080629000639');
INSERT INTO `schema_migrations` (`version`) VALUES ('20080629003929');


-- Drop the crap

DROP TABLE LUM_CategoryBlock;
DROP TABLE LUM_CategoryRoleBlock;
DROP TABLE LUM_Clipping;
DROP TABLE LUM_CommentBlock;
DROP TABLE LUM_DiscussionUserWhisperFrom;
DROP TABLE LUM_DiscussionUserWhisperTo;
DROP TABLE LUM_Invitation;
DROP TABLE LUM_IpHistory;
DROP TABLE LUM_Style;
DROP TABLE LUM_UserBlock;
DROP TABLE LUM_UserRoleHistory;
DROP TABLE LUM_UserSearch;


