-- ---------------------------------------------------------
-- PatchlyDB - Curated 20 Spotify Review Dataset (5 per Platform)
-- Purpose: Task 5 Demo Setup
-- ---------------------------------------------------------

USE PatchlyDB;
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Penalty; TRUNCATE TABLE ReleaseBugFix; TRUNCATE TABLE BugAssignment;
TRUNCATE TABLE DuplicateBug; TRUNCATE TABLE CustomerImpact;
TRUNCATE TABLE Bug; TRUNCATE TABLE ReviewSentiment; TRUNCATE TABLE Review;
TRUNCATE TABLE User; TRUNCATE TABLE EngineerSkill; TRUNCATE TABLE Engineer;
SET FOREIGN_KEY_CHECKS = 1;

-- Add PlatformID column to Review table (MySQL 8 compatible)
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='PatchlyDB' AND TABLE_NAME='Review' AND COLUMN_NAME='PlatformID');
SET @sql = IF(@col_exists = 0, 'ALTER TABLE Review ADD COLUMN PlatformID INT NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA='PatchlyDB' AND TABLE_NAME='Review' AND CONSTRAINT_NAME='FK_Review_Platform');
SET @sql2 = IF(@fk_exists = 0, 'ALTER TABLE Review ADD CONSTRAINT FK_Review_Platform FOREIGN KEY (PlatformID) REFERENCES Platform(PlatformID)', 'SELECT 1');
PREPARE stmt2 FROM @sql2; EXECUTE stmt2; DEALLOCATE PREPARE stmt2;

-- Engineers
INSERT INTO Engineer (EngineerID, Name, Email, DepartmentID, CurrentWorkload, MaxWorkload) VALUES 
(1, 'Alice Chen', 'alice.chen@patchly.local', 1, 0, 15),
(2, 'Bob Smith', 'bob.smith@patchly.local', 2, 0, 12),
(3, 'Charlie Davis','charlie.d@patchly.local', 1, 0, 20),
(4, 'Diana Prince', 'diana.p@patchly.local', 3, 0, 15),
(5, 'Evan Wright', 'evan.w@patchly.local', 3, 0, 10);

INSERT INTO EngineerSkill (EngineerID, SkillID) VALUES 
(1, 1), (1, 3), (2, 4), (2, 5), (3, 2), (4, 3), (5, 4), (5, 3);

INSERT INTO User (UserID, Name, Email) VALUES (10, 'SpotifyUser_10', 'user10@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (100, 10, 1, 'Personally, I don''t understand why you have to double down on the free version of the app with a bunch of ads AND limited song choices. That''s overkill and it makes this app hardly even usable for longer than 20 minutes before it devolves into music that''s vaguely related to the stuff you chose to listen to. It''s great when you spend money, but that''s by design. Y''all make enough money to give us more than 6 skips... I mean, c''mon.', 2, '2026-03-11 01:21:03', 0.11, 1);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (100, 4);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1000, 'Personally, I don''t understand why you h...', 'LLM Auto-Extracted Bug.', '2026-03-11 01:21:03', 'Review', 100, 1, 2, 1);
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5000, 1000, 1, '2026-03-11 01:21:03', '2026-03-12 01:21:03', NULL);
INSERT INTO User (UserID, Name, Email) VALUES (11, 'SpotifyUser_11', 'user11@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (101, 11, 1, 'Edit 2/27/26: Something seems to have changed in the last few weeks. I listen a lot, probably 4-5 hours a day while I do renovation work and every time I open the app it shows a "you are back online" message and it takes 2-3 minutes to load up all the recommendations and personalization stuff. Most of the time I am connected to high quality Wi-Fi or 5G networks. it''s definitely not a connection issue since it happens everywhere I go. It''s a music app so it''s not critical, but still.', 3, '2026-02-28 01:35:23', 0.17, 2);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (101, 5);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1001, 'Edit 2/27/26: Something seems to have ch...', 'LLM Auto-Extracted Bug.', '2026-02-28 01:35:23', 'Review', 101, 1, 1, 1);
UPDATE Bug SET StatusID = 4 WHERE BugID = 1001;
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5001, 1001, 2, '2026-02-28 01:35:23', '2026-02-28 05:35:23', '2026-02-28 06:35:23');
INSERT INTO User (UserID, Name, Email) VALUES (12, 'SpotifyUser_12', 'user12@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (102, 12, 1, 'I''ve used Spotify for a long time but the app just gets worse and worse each time I use it. The ads are the worst and only 6 skips an hour is just annoying. I was a premium user for a while, but $10 a month is way too much for me so I cancelled. After I did, the app ran way slower, it just shuts down for no reason, and I''ve gotten more problems (with time still left on my premium btw!) . I use music to help me with health stuff, it''s just such a shame that this app just sucks to use now.', 2, '2026-02-24 16:50:28', 0.35, 3);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (102, 4);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1002, 'I''ve used Spotify for a long time but th...', 'LLM Auto-Extracted Bug.', '2026-02-24 16:50:28', 'Review', 102, 1, 2, 1);
UPDATE Bug SET StatusID = 4 WHERE BugID = 1002;
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5002, 1002, 2, '2026-02-24 16:50:28', '2026-02-25 16:50:28', '2026-02-25 02:50:28');
INSERT INTO User (UserID, Name, Email) VALUES (13, 'SpotifyUser_13', 'user13@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (103, 13, 1, 'Great app! The only thing I hate about this app is that it literally does NOT give us the bare minimum!? For example, being able to loop a song. I get the ad part, I don''t mind it that much actually– but why not give free users the loop button? We already deal with 6 skips an hour, 2-4 ads after 2 songs, and not being able to play a playlist in order. Plus, the individual premium is 12 dollars a month, probably not bad for others, but I wouldn''t buy it for a music app. Updated: Not much change', 2, '2025-12-30 10:57:30', 0.12, 4);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (103, 3);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1003, 'Great app! The only thing I hate about t...', 'LLM Auto-Extracted Bug.', '2025-12-30 10:57:30', 'Review', 103, 5, 3, 1);
UPDATE Bug SET StatusID = 4 WHERE BugID = 1003;
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5003, 1003, 4, '2025-12-30 10:57:30', '2026-01-02 10:57:30', '2025-12-31 21:57:30');
INSERT INTO User (UserID, Name, Email) VALUES (14, 'SpotifyUser_14', 'user14@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (104, 14, 1, 'free version sucks. Windows media player is better by light years (and WMP isn''t an amazing platform, either). premium version works well enough to play music from, but is very confusing in how song ratings work. audiobooks are severely limited (15 hours with premium, and 15 hours more on a separate subscription - per month). if you want audiobooks or free music, I highly recommend a different platform.', 3, '2026-02-11 06:43:08', 0.18, 1);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (104, 3);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1004, 'free version sucks. Windows media player...', 'LLM Auto-Extracted Bug.', '2026-02-11 06:43:08', 'Review', 104, 4, 3, 1);
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5004, 1004, 2, '2026-02-11 06:43:08', '2026-02-14 06:43:08', NULL);
INSERT INTO User (UserID, Name, Email) VALUES (15, 'SpotifyUser_15', 'user15@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (105, 15, 1, 'I''ve been using this app to listen to music for a few years now it''s a great app, but there are a couple of problems that come with it. 1. I want to click on a song so I can listen to it after the ads, but then it tells me to get premium. It is also the same thing for when I want to unshuffle playlist. I make a playlist in the order I want and Spotify comes and ruins it. 2. They "claim" to give you 30 minutes of "uninterrupted listening", however they give me an ad after a couple of songs.', 3, '2025-10-04 04:22:27', 0.37, 2);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (105, 4);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1005, 'I''ve been using this app to listen to mu...', 'LLM Auto-Extracted Bug.', '2025-10-04 04:22:27', 'Review', 105, 2, 2, 1);
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5005, 1005, 2, '2025-10-04 04:22:27', '2025-10-05 04:22:27', NULL);
INSERT INTO User (UserID, Name, Email) VALUES (16, 'SpotifyUser_16', 'user16@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (106, 16, 1, 'I am so tired of this app. It gets more and more expensive. I had premium and it advertises audiobooks with your subscription, but only allows so many hours before it wants more money. cancelled premium bc I only listen to podcasts that have ads built in, forgot my alarm was set to my spotify Playlist. instead of a song, I woke up to 6 consecutive ads I had to listen to to get back to my podcast, to listen to more ads. Total garbage.', 2, '2025-10-13 18:11:46', 0.15, 3);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (106, 4);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1006, 'I am so tired of this app. It gets more ...', 'LLM Auto-Extracted Bug.', '2025-10-13 18:11:46', 'Review', 106, 1, 2, 1);
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5006, 1006, 3, '2025-10-13 18:11:46', '2025-10-14 18:11:46', NULL);
INSERT INTO User (UserID, Name, Email) VALUES (17, 'SpotifyUser_17', 'user17@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (107, 17, 1, 'At this point, just make Spotify a paid app cause instead of two ads, it''s three, sometimes even FOUR. says 30 mins without ads, but it''s like 5 mins, adds random songs in my Playlist, can only skip 6 songs each hour, and can''t see what song is up next. a little update!! I love listening to music!! but I got 5 ads in a row. And I am not paying for Spotify premium.', 1, '2025-10-21 16:26:11', 0.25, 4);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (107, 3);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1007, 'At this point, just make Spotify a paid ...', 'LLM Auto-Extracted Bug.', '2025-10-21 16:26:11', 'Review', 107, 1, 3, 1);
UPDATE Bug SET StatusID = 4 WHERE BugID = 1007;
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5007, 1007, 1, '2025-10-21 16:26:11', '2025-10-24 16:26:11', '2025-10-23 04:26:11');
INSERT INTO User (UserID, Name, Email) VALUES (18, 'SpotifyUser_18', 'user18@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (108, 18, 1, 'Great streaming app. 2 things I wish they would add, one, a "dislike" button to compliment the heart. Hiding songs isn''t the same. Makes playlists shorter by just not playing a song, and doesn''t solve the problem of a not liked song showing up on playlists. It just gets grayed out and skipped. Let me dislike the song and just don''t waste a spot on my Playlist with it. Secondly, the my DJ thing would be so much better if it didn''t consistently cut off 30 seconds to a minute of most songs', 3, '2025-10-29 06:01:20', 0.14, 1);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (108, 5);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1008, 'Great streaming app. 2 things I wish the...', 'LLM Auto-Extracted Bug.', '2025-10-29 06:01:20', 'Review', 108, 4, 1, 1);
UPDATE Bug SET StatusID = 4 WHERE BugID = 1008;
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5008, 1008, 4, '2025-10-29 06:01:20', '2025-10-29 10:01:20', '2025-10-29 13:01:20');
INSERT INTO User (UserID, Name, Email) VALUES (19, 'SpotifyUser_19', 'user19@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (109, 19, 1, 'Edit: The commercials have gotten somewhat better, and so have the random related songs being played. However, the app itself has crashed & refuses to open. Considering the trend continues, I''m reducing my review by a star since it won''t let me do 0. If you don''t mind hearing commercials netween every other song or ''random suggestions'' played instead of your curated song list, then this is the app for you. If you don''t like those things, I recommend going elsewhere for your listening needs', 3, '2025-11-19 11:57:25', 0.24, 2);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (109, 4);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1009, 'Edit: The commercials have gotten somewh...', 'LLM Auto-Extracted Bug.', '2025-11-19 11:57:25', 'Review', 109, 2, 2, 1);
UPDATE Bug SET StatusID = 4 WHERE BugID = 1009;
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5009, 1009, 2, '2025-11-19 11:57:25', '2025-11-20 11:57:25', '2025-11-20 10:57:25');
INSERT INTO User (UserID, Name, Email) VALUES (20, 'SpotifyUser_20', 'user20@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (110, 20, 1, 'This app is grate and vary easy to navigate. What I do not like about it is the ad''s; there are far to many and I can barely go 10 minutes with out an ad. Spotify premium is also over priced, it should not cost 11.99 to listen to ad free music. I also do not like that fact that it says I will have 30 minutes of ad free music after the ad, and then I will have an ad right after. Please fix these issues.', 1, '2024-09-08 01:34:25', 0.18, 3);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (110, 4);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1010, 'This app is grate and vary easy to navig...', 'LLM Auto-Extracted Bug.', '2024-09-08 01:34:25', 'Review', 110, 3, 2, 1);
UPDATE Bug SET StatusID = 4 WHERE BugID = 1010;
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5010, 1010, 4, '2024-09-08 01:34:25', '2024-09-09 01:34:25', '2024-09-09 10:34:25');
INSERT INTO User (UserID, Name, Email) VALUES (21, 'SpotifyUser_21', 'user21@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (111, 21, 1, 'Free version is almost unusable. Good grief! 4 ads in a row then it tells me I can enjoy 30 minutes ad free. 2 songs later here are 4 more ads. At first I figured maybe a weird glitch. Nope. It''s happens several times over the last few days. And on top of the that the ads are horrible. They''re louder than your music so it''s very jarring especially if you''re listening to something chill, and they''re repetitive. I can''t listen to specific songs, everything is behind a pay wall now.', 1, '2025-07-09 21:42:53', 0.15, 4);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (111, 3);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1011, 'Free version is almost unusable. Good gr...', 'LLM Auto-Extracted Bug.', '2025-07-09 21:42:53', 'Review', 111, 3, 3, 1);
UPDATE Bug SET StatusID = 4 WHERE BugID = 1011;
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5011, 1011, 1, '2025-07-09 21:42:53', '2025-07-12 21:42:53', '2025-07-11 06:42:53');
INSERT INTO User (UserID, Name, Email) VALUES (22, 'SpotifyUser_22', 'user22@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (112, 22, 1, 'Spotify used to be incredible! Now, it''s total trash! The connectivity is asteonomcally garbage - I could have 5G UC service, be playing downloaded songs, but Spotify will be constantly interrupted. I''m currently experiencing a complete blackout. I loved the way the queue was set-up, where you could see what was in the queue, & what was playing from the list - it was a large, legible set of tracks; now, it''s a "user-friendly" mess, where it''s impossible to see the queue, versus the list.', 1, '2025-04-16 19:31:43', 0.37, 1);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (112, 5);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1012, 'Spotify used to be incredible! Now, it''s...', 'LLM Auto-Extracted Bug.', '2025-04-16 19:31:43', 'Review', 112, 2, 1, 1);
UPDATE Bug SET StatusID = 4 WHERE BugID = 1012;
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5012, 1012, 4, '2025-04-16 19:31:43', '2025-04-16 23:31:43', '2025-04-16 22:31:43');
INSERT INTO User (UserID, Name, Email) VALUES (23, 'SpotifyUser_23', 'user23@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (113, 23, 1, 'there are multiple things wrong with it, though it does have a lot of music it''s hard to get to that music you want because of how it''s set up. When I try to get a song it plays a different song from "things we added" which is really just a way to get money so you get so annoyed that you pay for premium. It plays other songs before it plays your song and it only lets you skip five times, it also adds things to your own playlist when you try to create one. I won''t be using this app anymore.', 1, '2025-08-11 02:58:49', 0.2, 2);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (113, 5);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1013, 'there are multiple things wrong with it,...', 'LLM Auto-Extracted Bug.', '2025-08-11 02:58:49', 'Review', 113, 5, 1, 1);
UPDATE Bug SET StatusID = 4 WHERE BugID = 1013;
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5013, 1013, 4, '2025-08-11 02:58:49', '2025-08-11 06:58:49', '2025-08-11 11:58:49');
INSERT INTO User (UserID, Name, Email) VALUES (24, 'SpotifyUser_24', 'user24@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (114, 24, 1, 'Disappointing. I was enjoying the app for a while, and then I got kept getting messages saying, "Your premium preview is almost over" or something similar, even though I had never asked for a free trial; now that it''s over, I can''t even loop songs and there''s an unskippable ad after almost every song followed by another sort of ad that lies to you, saying, "Enjoy your next 30 mins of ad free listening" that you can''t skip either. Sadly, this is typical and I am not surprised, hence the 3 sta', 3, '2025-08-29 19:34:58', 0.34, 3);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (114, 5);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1014, 'Disappointing. I was enjoying the app fo...', 'LLM Auto-Extracted Bug.', '2025-08-29 19:34:58', 'Review', 114, 4, 1, 1);
UPDATE Bug SET StatusID = 4 WHERE BugID = 1014;
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5014, 1014, 2, '2025-08-29 19:34:58', '2025-08-29 23:34:58', '2025-08-30 01:34:58');
INSERT INTO User (UserID, Name, Email) VALUES (25, 'SpotifyUser_25', 'user25@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (115, 25, 1, 'The app is driving me crazy. For one, there''s an oversaturation of ads -- roughly 2-3 minutes of ads per 3-5 minutes of music. And the ads where it''s like "Watch this ad to get 30 minutes of ad-free listening" don''t work at all; I just get more normal ads within 5-10 minutes. I''m not buying a membership, Spotify, and your bugs, intentional or not, aren''t gonna force me to. Edit: Looked at community page. Solution was to keep the app in focus while the video plays. Problem: I ALREADY HAVE BE', 1, '2025-07-25 22:59:27', 0.25, 4);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (115, 5);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1015, 'The app is driving me crazy. For one, th...', 'LLM Auto-Extracted Bug.', '2025-07-25 22:59:27', 'Review', 115, 1, 1, 1);
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5015, 1015, 1, '2025-07-25 22:59:27', '2025-07-26 02:59:27', NULL);
INSERT INTO User (UserID, Name, Email) VALUES (26, 'SpotifyUser_26', 'user26@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (116, 26, 1, 'I have the free version right now because I can not afford premium. I will get the ad saying "listen for 30 minutes of ad free music" then it literally plays 1 3-4 minute song before I get another 2 minute set of ads. I habe time stamped screen shots to prove this. At this point, I feel as though im listening to more ads than I am music and highly considering switching streaming services. We''re getting to a point where I almost can''t listen to music unless I pay. Fix it!', 1, '2025-04-20 00:17:04', 0.15, 1);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (116, 3);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1016, 'I have the free version right now becaus...', 'LLM Auto-Extracted Bug.', '2025-04-20 00:17:04', 'Review', 116, 4, 3, 1);
UPDATE Bug SET StatusID = 4 WHERE BugID = 1016;
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5016, 1016, 4, '2025-04-20 00:17:04', '2025-04-23 00:17:04', '2025-04-20 06:17:04');
INSERT INTO User (UserID, Name, Email) VALUES (27, 'SpotifyUser_27', 'user27@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (117, 27, 1, 'Just keeps getting WORSE while charging us MORE! Premium service sucks now. You can''t add/delete/rearrange songs to the queue anymore. Takes an absolutely insane amount of time for playlists to load now. And it''s constantly adding the same songs to the queue... And now there''s no way to remove them. Bring back all the premium features and stop taking them away! And the free version is a joke, you use to get 3-4 songs after less than a min of ads, now it''s 3-4 min of ads for a song... RIDICUL', 1, '2025-03-25 19:54:36', 0.35, 2);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (117, 5);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1017, 'Just keeps getting WORSE while charging ...', 'LLM Auto-Extracted Bug.', '2025-03-25 19:54:36', 'Review', 117, 1, 1, 1);
UPDATE Bug SET StatusID = 4 WHERE BugID = 1017;
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5017, 1017, 4, '2025-03-25 19:54:36', '2025-03-25 23:54:36', '2025-03-26 04:54:36');
INSERT INTO User (UserID, Name, Email) VALUES (28, 'SpotifyUser_28', 'user28@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (118, 28, 1, 'I love Spotify, been using it for years but these recent changes have been extremely annoying. If I''m already a premium user why do I have to pay extra for audio books? Especially with how expensive things have gotten. Also the app crashes way too much,and I have to wait for my already downloaded songs to load. Spotify is focused on the wrong things which seems like a lot of the time. They''re definitely trying to have their cake and eat it too.', 2, '2025-09-04 01:40:57', 0.15, 3);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (118, 3);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1018, 'I love Spotify, been using it for years ...', 'LLM Auto-Extracted Bug.', '2025-09-04 01:40:57', 'Review', 118, 4, 3, 1);
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5018, 1018, 2, '2025-09-04 01:40:57', '2025-09-07 01:40:57', NULL);
INSERT INTO User (UserID, Name, Email) VALUES (29, 'SpotifyUser_29', 'user29@email.com');
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (119, 29, 1, 'I love having the music. I use spotify every day. Three stars because the app itself is absolute trash. It is constantly crashing, freezing, and randomly stopping. EDIT 03/22: don''t know what they did but they made it worse than ever. Spotify is trash, yall. Edit 08/24: Dear Spotify. Pay artists more. Also do something about the various versions of songs as it relates to the favorites list. Maybe like suggest the other versions when you add the song to a playlist or something.', 3, '2024-09-01 15:15:37', 0.21, 4);
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (119, 5);
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (1019, 'I love having the music. I use spotify e...', 'LLM Auto-Extracted Bug.', '2024-09-01 15:15:37', 'Review', 119, 3, 1, 1);
UPDATE Bug SET StatusID = 4 WHERE BugID = 1019;
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES (5019, 1019, 3, '2024-09-01 15:15:37', '2024-09-01 19:15:37', '2024-09-01 19:15:37');

-- Update final workloads
UPDATE Engineer SET CurrentWorkload = 2 WHERE EngineerID = 1;
UPDATE Engineer SET CurrentWorkload = 3 WHERE EngineerID = 2;
UPDATE Engineer SET CurrentWorkload = 1 WHERE EngineerID = 3;
UPDATE Engineer SET CurrentWorkload = 0 WHERE EngineerID = 4;
UPDATE Engineer SET CurrentWorkload = 0 WHERE EngineerID = 5;