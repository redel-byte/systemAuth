-- TalentHub Authentication System Database Schema
-- Enhanced version with proper relationships and additional features

CREATE DATABASE IF NOT EXISTS `talenthub_auth` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `talenthub_auth`;

-- Roles table
CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` text,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Users table with foreign key to roles
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `role_id` int(11) NOT NULL DEFAULT 1,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `email_verified` tinyint(1) NOT NULL DEFAULT 0,
  `last_login` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `users_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Login attempts table for security
CREATE TABLE `login_attempts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `user_agent` text,
  `success` tinyint(1) NOT NULL DEFAULT 0,
  `attempt_time` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `email` (`email`),
  KEY `attempt_time` (`attempt_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- User sessions table for enhanced session management
CREATE TABLE `user_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `session_id` varchar(255) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `user_agent` text,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `session_id` (`session_id`),
  KEY `user_id` (`user_id`),
  KEY `expires_at` (`expires_at`),
  CONSTRAINT `user_sessions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Insert default roles
INSERT INTO `roles` (`name`, `description`) VALUES
('candidate', 'Job seeker looking for opportunities'),
('recruiter', 'Employer posting jobs and reviewing candidates'),
('admin', 'System administrator with full access');

-- Insert sample admin user (password: admin123)
INSERT INTO `users` (`email`, `password`, `first_name`, `last_name`, `role_id`, `email_verified`) VALUES
('admin@talenthub.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'System', 'Administrator', 3, 1);

-- Insert sample users for testing
INSERT INTO `users` (`email`, `password`, `first_name`, `last_name`, `role_id`, `email_verified`) VALUES
('john.doe@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'John', 'Doe', 1, 1),
('jane.smith@company.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Jane', 'Smith', 2, 1),
('mike.wilson@startup.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Mike', 'Wilson', 2, 1);

-- Create indexes for better performance
CREATE INDEX `users_email_active` ON `users` (`email`, `is_active`);
CREATE INDEX `login_attempts_email_time` ON `login_attempts` (`email`, `attempt_time`);
CREATE INDEX `user_sessions_user_active` ON `user_sessions` (`user_id`, `is_active`);

-- Create view for active users with roles
CREATE VIEW `active_users_with_roles` AS
SELECT 
    u.id,
    u.email,
    u.first_name,
    u.last_name,
    u.is_active,
    u.email_verified,
    u.last_login,
    u.created_at,
    r.name as role_name,
    r.description as role_description
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE u.is_active = 1;
