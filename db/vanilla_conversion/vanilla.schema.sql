-- phpMyAdmin SQL Dump
-- version 2.11.1.2
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jun 26, 2008 at 11:47 AM
-- Server version: 4.1.11
-- PHP Version: 5.2.0

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

-- --------------------------------------------------------

--
-- Table structure for table 'LUM_Category'
--

CREATE TABLE IF NOT EXISTS LUM_Category (
  CategoryID int(2) NOT NULL auto_increment,
  Name varchar(100) NOT NULL default '',
  Description text NOT NULL,
  Priority int(11) NOT NULL default '0',
  Subscribeable int(1) NOT NULL default '0',
  PRIMARY KEY  (CategoryID),
  KEY CategoryID (CategoryID)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=12 ;



-- --------------------------------------------------------

--
-- Table structure for table 'LUM_CategoryBlock'
--

CREATE TABLE IF NOT EXISTS LUM_CategoryBlock (
  CategoryID int(11) NOT NULL default '0',
  UserID int(11) NOT NULL default '0',
  Blocked enum('1','0') NOT NULL default '1',
  PRIMARY KEY  (CategoryID,UserID)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;



-- --------------------------------------------------------

--
-- Table structure for table 'LUM_CategoryRoleBlock'
--

CREATE TABLE IF NOT EXISTS LUM_CategoryRoleBlock (
  CategoryID int(11) NOT NULL default '0',
  RoleID int(11) NOT NULL default '0',
  Blocked enum('1','0') NOT NULL default '0',
  KEY CategoryID (CategoryID),
  KEY RoleID (RoleID)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


-- --------------------------------------------------------

--
-- Table structure for table 'LUM_Clipping'
--

CREATE TABLE IF NOT EXISTS LUM_Clipping (
  ClippingID int(11) NOT NULL auto_increment,
  UserID int(11) NOT NULL default '0',
  Label varchar(30) NOT NULL default '',
  Contents text NOT NULL,
  PRIMARY KEY  (ClippingID),
  KEY UserID (UserID)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;





-- --------------------------------------------------------

--
-- Table structure for table 'LUM_Comment'
--

CREATE TABLE IF NOT EXISTS LUM_Comment (
  CommentID int(8) NOT NULL auto_increment,
  DiscussionID int(8) NOT NULL default '0',
  AuthUserID int(10) NOT NULL default '0',
  DateCreated datetime default NULL,
  EditUserID int(10) default NULL,
  DateEdited datetime default NULL,
  WhisperUserID int(11) default NULL,
  Body text,
  FormatType varchar(20) default NULL,
  Deleted enum('1','0') NOT NULL default '0',
  DateDeleted datetime default NULL,
  DeleteUserID int(10) NOT NULL default '0',
  RemoteIp varchar(100) default '',
  PRIMARY KEY  (CommentID),
  KEY CommentID (CommentID),
  KEY DiscussionID (DiscussionID),
  KEY DiscussionID_2 (DiscussionID)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=516608 ;

-- --------------------------------------------------------




--
-- Table structure for table 'LUM_CommentBlock'
--

CREATE TABLE IF NOT EXISTS LUM_CommentBlock (
  BlockingUserID int(11) NOT NULL default '0',
  BlockedCommentID int(11) NOT NULL default '0',
  Blocked enum('1','0') NOT NULL default '1',
  KEY BlockingUserID (BlockingUserID),
  KEY BlockedCommentID (BlockedCommentID)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;




-- --------------------------------------------------------

--
-- Table structure for table 'LUM_Discussion'
--

CREATE TABLE IF NOT EXISTS LUM_Discussion (
  DiscussionID int(8) NOT NULL auto_increment,
  AuthUserID int(10) NOT NULL default '0',
  WhisperUserID int(11) NOT NULL default '0',
  FirstCommentID int(11) NOT NULL default '0',
  LastUserID int(11) NOT NULL default '0',
  Active enum('1','0') NOT NULL default '1',
  Closed enum('1','0') NOT NULL default '0',
  Sticky enum('1','0') NOT NULL default '0',
  Name varchar(100) NOT NULL default '',
  DateCreated datetime NOT NULL default '0000-00-00 00:00:00',
  DateLastActive datetime NOT NULL default '0000-00-00 00:00:00',
  CountComments int(4) NOT NULL default '1',
  CategoryID int(11) default NULL,
  WhisperToLastUserID int(11) default NULL,
  WhisperFromLastUserID int(11) default NULL,
  DateLastWhisper datetime default NULL,
  TotalWhisperCount int(11) NOT NULL default '0',
  Sink enum('1','0') NOT NULL default '0',
  PRIMARY KEY  (DiscussionID),
  KEY CategoryID (CategoryID),
  KEY WhisperToLastUserID (WhisperToLastUserID),
  KEY WhisperFromLastUserID (WhisperFromLastUserID),
  KEY LastUserID (LastUserID),
  KEY FirstCommentID (FirstCommentID),
  KEY WhisperUserID (WhisperUserID),
  KEY AuthUserID (AuthUserID)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=13911 ;





-- --------------------------------------------------------

--
-- Table structure for table 'LUM_DiscussionUserWhisperFrom'
--

CREATE TABLE IF NOT EXISTS LUM_DiscussionUserWhisperFrom (
  DiscussionID int(11) NOT NULL default '0',
  WhisperFromUserID int(11) NOT NULL default '0',
  LastUserID int(11) NOT NULL default '0',
  CountWhispers int(11) NOT NULL default '0',
  DateLastActive datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (DiscussionID,WhisperFromUserID),
  KEY WhisperFromUserID (WhisperFromUserID),
  KEY LastUserID (LastUserID)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


-- --------------------------------------------------------

--
-- Table structure for table 'LUM_DiscussionUserWhisperTo'
--

CREATE TABLE IF NOT EXISTS LUM_DiscussionUserWhisperTo (
  DiscussionID int(11) NOT NULL default '0',
  WhisperToUserID int(11) NOT NULL default '0',
  LastUserID int(11) NOT NULL default '0',
  CountWhispers int(11) NOT NULL default '0',
  DateLastActive datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (DiscussionID,WhisperToUserID),
  KEY LastUserID (LastUserID)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


-- --------------------------------------------------------

--
-- Table structure for table 'LUM_Invitation'
--

CREATE TABLE IF NOT EXISTS LUM_Invitation (
  InvitationID int(11) unsigned NOT NULL auto_increment,
  InvitationKey varchar(16) NOT NULL default '',
  InvitationDate datetime NOT NULL default '0000-00-00 00:00:00',
  Email varchar(200) NOT NULL default '',
  SenderID int(11) NOT NULL default '0',
  Used enum('1','0') NOT NULL default '0',
  PRIMARY KEY  (InvitationID),
  KEY InvitationKey (InvitationKey),
  KEY InvitationDate (InvitationDate),
  KEY SenderID (SenderID),
  KEY SenderID_2 (SenderID)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=40 ;


-- --------------------------------------------------------

--
-- Table structure for table 'LUM_IpHistory'
--

CREATE TABLE IF NOT EXISTS LUM_IpHistory (
  IpHistoryID int(11) NOT NULL auto_increment,
  RemoteIp varchar(30) NOT NULL default '',
  UserID int(11) NOT NULL default '0',
  DateLogged datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (IpHistoryID),
  KEY UserID_DateLogged (UserID,DateLogged)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=13840 ;


-- --------------------------------------------------------

--
-- Table structure for table 'LUM_Notify'
--

CREATE TABLE IF NOT EXISTS LUM_Notify (
  NotifyID int(11) NOT NULL auto_increment,
  UserID int(11) NOT NULL default '0',
  Method varchar(10) NOT NULL default '',
  SelectID int(11) NOT NULL default '0',
  PRIMARY KEY  (NotifyID),
  KEY UserID (UserID),
  KEY SelectID (SelectID)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=59 ;

-- --------------------------------------------------------

--
-- Table structure for table 'LUM_Role'
--

CREATE TABLE IF NOT EXISTS LUM_Role (
  RoleID int(2) NOT NULL auto_increment,
  Name varchar(100) NOT NULL default '',
  Icon varchar(155) NOT NULL default '',
  Description varchar(200) NOT NULL default '',
  PERMISSION_SIGN_IN enum('1','0') NOT NULL default '0',
  PERMISSION_HTML_ALLOWED enum('1','0') NOT NULL default '0',
  Active enum('1','0') NOT NULL default '1',
  PERMISSION_RECEIVE_APPLICATION_NOTIFICATION enum('1','0') NOT NULL default '0',
  Permissions text,
  Priority int(11) NOT NULL default '0',
  UnAuthenticated enum('1','0') NOT NULL default '0',
  PRIMARY KEY  (RoleID)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=23 ;

-- --------------------------------------------------------

--
-- Table structure for table 'LUM_Style'
--

CREATE TABLE IF NOT EXISTS LUM_Style (
  StyleID int(3) NOT NULL auto_increment,
  AuthUserID int(11) NOT NULL default '0',
  Name varchar(50) NOT NULL default '',
  Url varchar(255) NOT NULL default '',
  PreviewImage varchar(20) NOT NULL default '',
  PRIMARY KEY  (StyleID),
  KEY AuthUserID (AuthUserID)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=7 ;


-- --------------------------------------------------------

--
-- Table structure for table 'LUM_User'
--

CREATE TABLE IF NOT EXISTS LUM_User (
  UserID int(10) NOT NULL auto_increment,
  RoleID int(2) NOT NULL default '0',
  StyleID int(3) NOT NULL default '1',
  CustomStyle varchar(255) default NULL,
  FirstName varchar(50) NOT NULL default '',
  LastName varchar(50) NOT NULL default '',
  Name varchar(20) NOT NULL default '',
  `Password` varchar(32) NOT NULL default '',
  VerificationKey varchar(50) NOT NULL default '',
  EmailVerificationKey varchar(50) default NULL,
  Email varchar(200) NOT NULL default '',
  UtilizeEmail enum('1','0') NOT NULL default '0',
  ShowName enum('1','0') NOT NULL default '1',
  Icon varchar(255) default NULL,
  Picture varchar(255) default NULL,
  Attributes text NOT NULL,
  CountVisit int(8) NOT NULL default '0',
  CountDiscussions int(8) NOT NULL default '0',
  CountComments int(8) NOT NULL default '0',
  DateFirstVisit datetime NOT NULL default '0000-00-00 00:00:00',
  DateLastActive datetime NOT NULL default '0000-00-00 00:00:00',
  RemoteIp varchar(100) NOT NULL default '',
  LastDiscussionPost datetime default NULL,
  DiscussionSpamCheck int(11) NOT NULL default '0',
  LastCommentPost datetime default NULL,
  CommentSpamCheck int(11) NOT NULL default '0',
  UserBlocksCategories enum('1','0') NOT NULL default '0',
  DefaultFormatType varchar(20) default NULL,
  SendNewApplicantNotifications enum('1','0') NOT NULL default '0',
  Discovery text,
  Preferences text,
  SubscribeOwn tinyint(1) NOT NULL default '0',
  Notified tinyint(1) NOT NULL default '0',
  InvitationID int(11) unsigned NOT NULL default '0',
  InvitationsSent tinyint(4) NOT NULL default '0',
  InvitationsAllowed tinyint(4) NOT NULL default '1',
  PRIMARY KEY  (UserID),
  KEY InvitationID (InvitationID),
  KEY RoleID (RoleID),
  KEY StyleID (StyleID)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=547 ;




-- --------------------------------------------------------

--
-- Table structure for table 'LUM_UserBlock'
--

CREATE TABLE IF NOT EXISTS LUM_UserBlock (
  BlockingUserID int(11) NOT NULL default '0',
  BlockedUserID int(11) NOT NULL default '0',
  Blocked enum('1','0') NOT NULL default '1',
  KEY BlockingUserID (BlockingUserID),
  KEY BlockedUserID (BlockedUserID)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table 'LUM_UserBookmark'
--

CREATE TABLE IF NOT EXISTS LUM_UserBookmark (
  UserID int(10) NOT NULL default '0',
  DiscussionID int(8) NOT NULL default '0',
  PRIMARY KEY  (UserID,DiscussionID)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table 'LUM_UserDiscussionWatch'
--

CREATE TABLE IF NOT EXISTS LUM_UserDiscussionWatch (
  UserID int(10) NOT NULL default '0',
  DiscussionID int(8) NOT NULL default '0',
  CountComments int(11) NOT NULL default '0',
  LastViewed datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (UserID,DiscussionID),
  KEY UserID_DiscussionID (UserID,DiscussionID)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table 'LUM_UserRoleHistory'
--

CREATE TABLE IF NOT EXISTS LUM_UserRoleHistory (
  UserID int(10) NOT NULL default '0',
  RoleID int(2) NOT NULL default '0',
  `Date` datetime NOT NULL default '0000-00-00 00:00:00',
  AdminUserID int(10) NOT NULL default '0',
  Notes varchar(200) default NULL,
  RemoteIp varchar(100) default NULL,
  KEY UserID (UserID),
  KEY RoleID (RoleID),
  KEY AdminUserID (AdminUserID)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


-- --------------------------------------------------------

--
-- Table structure for table 'LUM_UserSearch'
--

CREATE TABLE IF NOT EXISTS LUM_UserSearch (
  SearchID int(11) NOT NULL auto_increment,
  Label varchar(30) NOT NULL default '',
  UserID int(11) NOT NULL default '0',
  Keywords varchar(100) NOT NULL default '',
  `Type` enum('Users','Topics','Comments') NOT NULL default 'Topics',
  PRIMARY KEY  (SearchID),
  KEY UserID (UserID)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

