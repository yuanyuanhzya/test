/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80039 (8.0.39)
 Source Host           : localhost:3306
 Source Schema         : campus_opensource

 Target Server Type    : MySQL
 Target Server Version : 80039 (8.0.39)
 File Encoding         : 65001

 Date: 08/01/2026 12:45:59
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for contribution
-- ----------------------------
DROP TABLE IF EXISTS `contribution`;
CREATE TABLE `contribution`  (
  `contribution_id` bigint NOT NULL AUTO_INCREMENT,
  `project_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `commit_hash` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Git提交哈希',
  `commit_message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '提交信息',
  `contribution_type` enum('COMMIT','PR_MERGED','ISSUE_CLOSED','PR_REVIEWED') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'COMMIT',
  `score` int NULL DEFAULT 5 COMMENT '本次贡献得分',
  `contribution_time` datetime NULL DEFAULT NULL COMMENT 'Git提交时间',
  `sync_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '同步到平台的时间',
  `sync_task_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`contribution_id`) USING BTREE,
  UNIQUE INDEX `uk_project_commit`(`project_id` ASC, `commit_hash` ASC) USING BTREE COMMENT '防止重复提交',
  INDEX `idx_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_project_time`(`project_id` ASC, `contribution_time` ASC) USING BTREE,
  INDEX `idx_sync_task`(`sync_task_id` ASC) USING BTREE,
  CONSTRAINT `fk_contribution_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`project_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_contribution_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '贡献记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for issue_comment
-- ----------------------------
DROP TABLE IF EXISTS `issue_comment`;
CREATE TABLE `issue_comment`  (
  `comment_id` bigint NOT NULL AUTO_INCREMENT,
  `issue_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '评论内容',
  `is_technical` tinyint(1) NULL DEFAULT 0 COMMENT '是否为技术性评论',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`comment_id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_issue`(`issue_id` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE,
  CONSTRAINT `issue_comment_ibfk_1` FOREIGN KEY (`issue_id`) REFERENCES `project_issue` (`issue_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `issue_comment_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Issue评论表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for project
-- ----------------------------
DROP TABLE IF EXISTS `project`;
CREATE TABLE `project`  (
  `project_id` bigint NOT NULL AUTO_INCREMENT,
  `project_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '项目名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '项目描述（Markdown格式）',
  `category` enum('WEB','ALGORITHM','AI','MOBILE','OTHER') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'OTHER' COMMENT '分类',
  `git_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Git仓库地址',
  `owner_id` bigint NOT NULL COMMENT '创建者ID',
  `star_count` int NULL DEFAULT 0 COMMENT '星标数',
  `status` enum('ACTIVE','SEEKING_SUCCESSION','ARCHIVED') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'ACTIVE' COMMENT '项目状态',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `last_activity_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '最后活动时间',
  `is_deleted` tinyint(1) NULL DEFAULT (0) COMMENT '逻辑删除 0-正常 1-删除',
  `is_private` tinyint(1) NULL DEFAULT (0) COMMENT '是否私有 0-公开 1-私有',
  PRIMARY KEY (`project_id`) USING BTREE,
  INDEX `idx_owner`(`owner_id` ASC) USING BTREE,
  CONSTRAINT `fk_project_owner` FOREIGN KEY (`owner_id`) REFERENCES `sys_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '开源项目表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for project_issue
-- ----------------------------
DROP TABLE IF EXISTS `project_issue`;
CREATE TABLE `project_issue`  (
  `issue_id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Issue ID',
  `project_id` bigint NOT NULL COMMENT '所属项目ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '详细描述',
  `issue_type` enum('BUG','FEATURE','TASK','QUESTION') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'TASK' COMMENT '类型',
  `status` enum('OPEN','IN_PROGRESS','RESOLVED','CLOSED') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'OPEN' COMMENT '状态',
  `priority` enum('LOW','MEDIUM','HIGH') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'MEDIUM' COMMENT '优先级',
  `creator_id` bigint NOT NULL COMMENT '创建者ID',
  `assignee_id` bigint NULL DEFAULT NULL COMMENT '负责人ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `tags` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '标签，逗号分隔',
  `resolution` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '解决方式（如：已修复、重复问题等）',
  `resolve_time` datetime NULL DEFAULT NULL COMMENT '解决时间',
  `comment_count` int NULL DEFAULT 0 COMMENT '评论数',
  `view_count` int NULL DEFAULT 0 COMMENT '查看次数',
  PRIMARY KEY (`issue_id`) USING BTREE,
  INDEX `idx_project_status`(`project_id` ASC, `status` ASC) USING BTREE,
  INDEX `idx_creator`(`creator_id` ASC) USING BTREE,
  INDEX `idx_assignee`(`assignee_id` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE,
  CONSTRAINT `project_issue_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `project` (`project_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `project_issue_ibfk_2` FOREIGN KEY (`creator_id`) REFERENCES `sys_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `project_issue_ibfk_3` FOREIGN KEY (`assignee_id`) REFERENCES `sys_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目问题表（简化版）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for project_member
-- ----------------------------
DROP TABLE IF EXISTS `project_member`;
CREATE TABLE `project_member`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `project_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `role` enum('OWNER','ADMIN','MEMBER') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'MEMBER' COMMENT '角色',
  `join_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_project_user`(`project_id` ASC, `user_id` ASC) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_member_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`project_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_member_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目成员表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for project_tag
-- ----------------------------
DROP TABLE IF EXISTS `project_tag`;
CREATE TABLE `project_tag`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `tag_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标签名称',
  `tag_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'TECH' COMMENT '标签类型：TECH(技术)、TOPIC(主题)、LEVEL(难度)',
  `usage_count` int NULL DEFAULT 1 COMMENT '该标签被使用的次数',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_project_tag`(`project_id` ASC, `tag_name` ASC) USING BTREE COMMENT '一个项目不能有重复标签',
  INDEX `idx_tag_name`(`tag_name` ASC) USING BTREE,
  INDEX `idx_tag_type`(`tag_type` ASC) USING BTREE,
  CONSTRAINT `fk_tag_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`project_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目标签表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for recruitment_apply
-- ----------------------------
DROP TABLE IF EXISTS `recruitment_apply`;
CREATE TABLE `recruitment_apply`  (
  `apply_id` bigint NOT NULL AUTO_INCREMENT,
  `project_id` bigint NOT NULL,
  `applicant_id` bigint NOT NULL,
  `application_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '申请理由',
  `status` enum('PENDING','ACCEPTED','REJECTED') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'PENDING',
  `apply_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `handle_time` datetime NULL DEFAULT NULL COMMENT '处理时间',
  PRIMARY KEY (`apply_id`) USING BTREE,
  INDEX `idx_project_status`(`project_id` ASC, `status` ASC) USING BTREE,
  INDEX `fk_apply_user`(`applicant_id` ASC) USING BTREE,
  CONSTRAINT `fk_apply_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`project_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_apply_user` FOREIGN KEY (`applicant_id`) REFERENCES `sys_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '招募申请记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for star_record
-- ----------------------------
DROP TABLE IF EXISTS `star_record`;
CREATE TABLE `star_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `project_id` bigint NOT NULL,
  `star_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_project`(`user_id` ASC, `project_id` ASC) USING BTREE,
  INDEX `idx_project`(`project_id` ASC) USING BTREE,
  CONSTRAINT `fk_star_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`project_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_star_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '星标记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sync_task
-- ----------------------------
DROP TABLE IF EXISTS `sync_task`;
CREATE TABLE `sync_task`  (
  `task_id` bigint NOT NULL AUTO_INCREMENT,
  `project_id` bigint NOT NULL,
  `sync_type` enum('COMMIT','PR','ISSUE','FULL') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'COMMIT',
  `status` enum('PENDING','PROCESSING','SUCCESS','FAILED') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'PENDING',
  `total_count` int NULL DEFAULT 0,
  `success_count` int NULL DEFAULT 0,
  `fail_count` int NULL DEFAULT 0,
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `start_time` datetime NULL DEFAULT NULL,
  `end_time` datetime NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`task_id`) USING BTREE,
  INDEX `idx_project_status`(`project_id` ASC, `status` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE,
  CONSTRAINT `fk_sync_task_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`project_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '同步任务记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名/学号',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '加密密码',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '昵称',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱（用于Git贡献匹配）',
  `college` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '学院',
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像链接',
  `total_score` int NULL DEFAULT 0 COMMENT '总贡献分',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for user_git_binding
-- ----------------------------
DROP TABLE IF EXISTS `user_git_binding`;
CREATE TABLE `user_git_binding`  (
  `binding_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `git_platform` enum('GITHUB','GITEE','GITLAB') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'GITHUB',
  `git_username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `git_email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `is_primary` tinyint(1) NULL DEFAULT 0 COMMENT '是否为主要绑定',
  `is_verified` tinyint(1) NULL DEFAULT 0 COMMENT '是否已验证',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`binding_id`) USING BTREE,
  UNIQUE INDEX `uk_user_platform`(`user_id` ASC, `git_platform` ASC, `git_email` ASC) USING BTREE,
  INDEX `idx_git_email`(`git_email` ASC) USING BTREE,
  INDEX `idx_git_username`(`git_username` ASC) USING BTREE,
  CONSTRAINT `fk_binding_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户Git账号绑定表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- View structure for hot_tags_view
-- ----------------------------
DROP VIEW IF EXISTS `hot_tags_view`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `hot_tags_view` AS select `project_tag`.`tag_name` AS `tag_name`,count(0) AS `usage_count`,group_concat(distinct `project_tag`.`tag_type` separator ',') AS `tag_types` from `project_tag` group by `project_tag`.`tag_name` order by `usage_count` desc;

SET FOREIGN_KEY_CHECKS = 1;
