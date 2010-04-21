CREATE TABLE `LUM_Notify` (
  `NotifyID` int(11) NOT NULL auto_increment,
  `UserID` int(11) NOT NULL default '0',
  `Method` varchar(10) NOT NULL default '',
  `SelectID` int(11) NOT NULL default '0',
  PRIMARY KEY  (`NotifyID`),
  KEY `UserID` (`UserID`),
  KEY `SelectID` (`SelectID`)
) ENGINE=MyISAM AUTO_INCREMENT=55 DEFAULT CHARSET=latin1;

CREATE TABLE `LUM_Role` (
  `RoleID` int(2) NOT NULL auto_increment,
  `Name` varchar(100) NOT NULL default '',
  `Icon` varchar(155) NOT NULL default '',
  `Description` varchar(200) NOT NULL default '',
  `PERMISSION_SIGN_IN` enum('1','0') NOT NULL default '0',
  `PERMISSION_HTML_ALLOWED` enum('1','0') NOT NULL default '0',
  `Active` enum('1','0') NOT NULL default '1',
  `PERMISSION_RECEIVE_APPLICATION_NOTIFICATION` enum('1','0') NOT NULL default '0',
  `Permissions` text,
  `Priority` int(11) NOT NULL default '0',
  `UnAuthenticated` enum('1','0') NOT NULL default '0',
  PRIMARY KEY  (`RoleID`)
) ENGINE=MyISAM AUTO_INCREMENT=23 DEFAULT CHARSET=latin1;

CREATE TABLE `LUM_UserBookmark` (
  `UserID` int(10) NOT NULL default '0',
  `DiscussionID` int(8) NOT NULL default '0',
  PRIMARY KEY  (`UserID`,`DiscussionID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `LUM_UserDiscussionWatch` (
  `UserID` int(10) NOT NULL default '0',
  `DiscussionID` int(8) NOT NULL default '0',
  `CountComments` int(11) NOT NULL default '0',
  `LastViewed` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`UserID`,`DiscussionID`),
  KEY `UserID_DiscussionID` (`UserID`,`DiscussionID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `categories` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `description` text,
  `position` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `discussions_count` int(11) NOT NULL default '0',
  `trusted` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;

CREATE TABLE `delayed_jobs` (
  `id` int(11) NOT NULL auto_increment,
  `priority` int(11) default '0',
  `attempts` int(11) default '0',
  `handler` text,
  `last_error` varchar(255) default NULL,
  `run_at` datetime default NULL,
  `locked_at` datetime default NULL,
  `failed_at` datetime default NULL,
  `locked_by` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=latin1;

CREATE TABLE `discussion_relationships` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `discussion_id` int(11) default NULL,
  `participated` tinyint(1) NOT NULL default '0',
  `following` tinyint(1) NOT NULL default '1',
  `favorite` tinyint(1) NOT NULL default '0',
  `trusted` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `user_id_index` (`user_id`),
  KEY `discussion_id_index` (`discussion_id`),
  KEY `participated_index` (`participated`),
  KEY `following_index` (`following`),
  KEY `favorite_index` (`favorite`),
  KEY `trusted_index` (`trusted`)
) ENGINE=InnoDB AUTO_INCREMENT=168039 DEFAULT CHARSET=latin1;

CREATE TABLE `discussion_views` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `discussion_id` int(11) default NULL,
  `post_index` int(11) NOT NULL default '0',
  `post_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `user_id_index` (`user_id`),
  KEY `discussion_id_index` (`discussion_id`),
  KEY `post_id_index` (`post_id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=latin1;

CREATE TABLE `discussions` (
  `id` int(11) NOT NULL auto_increment,
  `poster_id` int(11) default NULL,
  `last_poster_id` int(11) default NULL,
  `closed` tinyint(1) NOT NULL default '0',
  `sticky` tinyint(1) NOT NULL default '0',
  `title` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `last_post_at` datetime default NULL,
  `category_id` int(11) default NULL,
  `updated_at` datetime default NULL,
  `nsfw` tinyint(1) NOT NULL default '0',
  `trusted` tinyint(1) NOT NULL default '0',
  `posts_count` int(11) default '0',
  `delta` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `poster_id_index` (`poster_id`),
  KEY `category_id_index` (`category_id`),
  KEY `created_at_index` (`created_at`),
  KEY `last_post_at_index` (`last_post_at`),
  KEY `sticky_index` (`sticky`),
  KEY `trusted_index` (`trusted`),
  KEY `delta_index` (`delta`),
  FULLTEXT KEY `discussions_title_fulltext` (`title`)
) ENGINE=MyISAM AUTO_INCREMENT=13942 DEFAULT CHARSET=utf8;

CREATE TABLE `messages` (
  `id` int(11) NOT NULL auto_increment,
  `recipient_id` int(11) default NULL,
  `sender_id` int(11) default NULL,
  `subject` varchar(255) default NULL,
  `body` text,
  `read` tinyint(1) NOT NULL default '0',
  `deleted` tinyint(1) NOT NULL default '0',
  `deleted_by_sender` tinyint(1) NOT NULL default '0',
  `replied_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `recipient_id_index` (`recipient_id`),
  KEY `sender_id_index` (`sender_id`),
  KEY `read_index` (`read`),
  KEY `deleted_index` (`deleted`),
  KEY `deleted_by_sender_index` (`deleted_by_sender`)
) ENGINE=InnoDB AUTO_INCREMENT=62760 DEFAULT CHARSET=utf8;

CREATE TABLE `posts` (
  `id` int(11) NOT NULL auto_increment,
  `discussion_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `body` text,
  `format_type` varchar(255) default NULL,
  `body_html` text,
  `edited_at` datetime default NULL,
  `trusted` tinyint(1) NOT NULL default '0',
  `delta` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `user_id_index` (`user_id`),
  KEY `discussion_id_index` (`discussion_id`),
  KEY `created_at_index` (`created_at`),
  KEY `trusted_index` (`trusted`),
  KEY `delta_index` (`delta`)
) ENGINE=InnoDB AUTO_INCREMENT=518752 DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `username` varchar(255) default NULL,
  `hashed_password` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `last_active` datetime default NULL,
  `inviter_id` int(11) default NULL,
  `realname` varchar(255) character set latin1 default NULL,
  `updated_at` datetime default NULL,
  `description` text,
  `banned` tinyint(1) NOT NULL default '0',
  `activated` tinyint(1) NOT NULL default '0',
  `user_admin` tinyint(1) NOT NULL default '0',
  `moderator` tinyint(1) NOT NULL default '0',
  `admin` tinyint(1) NOT NULL default '0',
  `trusted` tinyint(1) NOT NULL default '0',
  `posts_count` int(11) NOT NULL default '0',
  `discussions_count` int(11) default '0',
  `location` varchar(255) default NULL,
  `birthday` date default NULL,
  `stylesheet_url` varchar(255) default NULL,
  `work_safe_urls` tinyint(1) NOT NULL default '0',
  `gamertag` varchar(255) default NULL,
  `html_disabled` tinyint(1) NOT NULL default '0',
  `avatar_url` varchar(255) default NULL,
  `msn` varchar(255) default NULL,
  `gtalk` varchar(255) default NULL,
  `aim` varchar(255) default NULL,
  `twitter` varchar(255) default NULL,
  `flickr` varchar(255) default NULL,
  `last_fm` varchar(255) default NULL,
  `website` varchar(255) default NULL,
  `notify_on_message` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`id`),
  KEY `username_index` (`username`)
) ENGINE=MyISAM AUTO_INCREMENT=604 DEFAULT CHARSET=utf8;

CREATE TABLE `xbox_infos` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `status` int(11) default NULL,
  `gamerscore` int(11) default NULL,
  `info` varchar(255) default NULL,
  `info2` varchar(255) default NULL,
  `status_text` varchar(255) default NULL,
  `reputation` varchar(255) default NULL,
  `tile_url` varchar(255) default NULL,
  `valid_xml` tinyint(1) NOT NULL default '0',
  `xml_data` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `zone` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=116 DEFAULT CHARSET=latin1;

INSERT INTO schema_migrations (version) VALUES ('20080625185118');

INSERT INTO schema_migrations (version) VALUES ('20080625202342');

INSERT INTO schema_migrations (version) VALUES ('20080625202348');

INSERT INTO schema_migrations (version) VALUES ('20080625213006');

INSERT INTO schema_migrations (version) VALUES ('20080629000639');

INSERT INTO schema_migrations (version) VALUES ('20080629003929');

INSERT INTO schema_migrations (version) VALUES ('20080630110300');

INSERT INTO schema_migrations (version) VALUES ('20080630190725');

INSERT INTO schema_migrations (version) VALUES ('20080701172614');

INSERT INTO schema_migrations (version) VALUES ('20080705191931');

INSERT INTO schema_migrations (version) VALUES ('20080705221753');

INSERT INTO schema_migrations (version) VALUES ('20080828010822');

INSERT INTO schema_migrations (version) VALUES ('20080918034727');

INSERT INTO schema_migrations (version) VALUES ('20080918155718');

INSERT INTO schema_migrations (version) VALUES ('20081214201048');

INSERT INTO schema_migrations (version) VALUES ('20090404154958');

INSERT INTO schema_migrations (version) VALUES ('20090405021034');

INSERT INTO schema_migrations (version) VALUES ('20090429063818');