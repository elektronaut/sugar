DROP TABLE LUM_CategoryBlock;
DROP TABLE LUM_CategoryRoleBlock;
DROP TABLE LUM_CommentBlock;
DROP TABLE LUM_DiscussionUserWhisperFrom;
DROP TABLE LUM_DiscussionUserWhisperTo;
DROP TABLE LUM_IpHistory;
DROP TABLE LUM_Style;
DROP TABLE LUM_UserBlock;
DROP TABLE LUM_UserRoleHistory;
DROP TABLE LUM_UserSearch;

-- Categories

RENAME TABLE LUM_Category TO categories;
ALTER TABLE categories 
	CHANGE CategoryID id INTEGER(11),
	CHANGE Name name VARCHAR(255),
	CHANGE Description description TEXT,
	CHANGE Priority position INTEGER(11),
	DROP COLUMN Subscribeable,
	ADD COLUMN created_at DATETIME default NULL,
	ADD COLUMN updated_at DATETIME default NULL,
	ADD COLUMN discussions_count INTEGER(11) NOT NULL default '0',
	ENGINE = InnoDB DEFAULT CHARSET=utf8;

UPDATE categories SET created_at = NOW(), updated_at = NOW();

-- Posts

RENAME TABLE LUM_Comment TO posts;
DELETE FROM posts WHERE Deleted = '1';
DELETE FROM posts WHERE DiscussionID IN (SELECT DiscussionID FROM LUM_Discussion WHERE WhisperUserID IS NULL OR WhisperUserID > 0);
DELETE FROM posts WHERE WhisperUserID IS NULL OR WhisperUserID > 0;
ALTER TABLE posts 
	CHANGE CommentID id INTEGER(11),
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
	ENGINE = InnoDB DEFAULT CHARSET=utf8;

-- Discussions

RENAME TABLE LUM_Discussion TO discussions;
DELETE FROM discussions WHERE WhisperUserID IS NULL OR WhisperUserID > 0;
ALTER TABLE discussions
	CHANGE DiscussionID id int(11),
	DROP COLUMN AuthUserID,
	CHANGE FirstCommentID poster_id int(11),
	CHANGE LastUserID last_poster_id int(11),
	DROP COLUMN active,
	CHANGE Closed closed tinyint(1),
	CHANGE Sticky sticky tinyint(1),
	CHANGE Name title VARCHAR(255),
	CHANGE DateCreated created_at datetime,
	CHANGE DateLastActive last_post_at datetime,
	ADD COLUMN updated_at datetime NULL,
	DROP COLUMN CountComments,
	CHANGE CategoryID category_id int(11),
	DROP COLUMN WhisperToLastUserID,
	DROP COLUMN WhisperFromLastUserID,
	DROP COLUMN DateLastWhisper,
	DROP COLUMN TotalWhisperCount,
	DROP COLUMN Sink,
	ADD COLUMN nsfw tinyint(1) NOT NULL default '0',
	ADD COLUMN posts_count int(11) default '0',
	ENGINE = InnoDB DEFAULT CHARSET=utf8;

UPDATE discussions SET updated_at = created_at;
UPDATE discussions SET sticky = 0 WHERE closed = 2;
UPDATE discussions SET sticky = 0 WHERE sticky = 2;

-- Users

RENAME TABLE LUM_User TO users;
ALTER TABLE users ADD COLUMN realname VARCHAR(255) NULL;
UPDATE users SET realname = CONCAT(FirstName, " ", LastName);
ALTER TABLE users
	CHANGE UserID id int(11),
	DROP COLUMN RoleID,
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
	ADD COLUMN updated_at datetime NULL,
	ADD COLUMN `description` text,
	ADD COLUMN `banned` tinyint(1) NOT NULL default '0',
	ADD COLUMN `activated` tinyint(1) NOT NULL default '0',
	ADD COLUMN `admin` tinyint(1) NOT NULL default '0',
	ADD COLUMN `posts_count` int(11) NOT NULL default '0',
	ADD COLUMN `discussions_count` int(11) default '0',
	ADD COLUMN `location` varchar(255) default NULL,
	ADD COLUMN `birthday` date default NULL,
	ADD COLUMN `stylesheet_url` varchar(255) default NULL,
	ADD COLUMN `work_safe_urls` tinyint(1) NOT NULL default '0',
	ADD COLUMN `gamertag` varchar(255) default NULL,
	ADD COLUMN `html_disabled` tinyint(1) NOT NULL default '0',
	ENGINE = InnoDB DEFAULT CHARSET=utf8;
	
UPDATE users SET updated_at = NOW();

