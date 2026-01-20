<?php

require_once "../app/core/router.php";
require_once "../app/core/AuthMiddleware.php";
require_once __DIR__ . '/../app/controllers/AuthController.php';
require_once __DIR__ . '/../app/controllers/HomeController.php';
require_once __DIR__ . '/../app/controllers/CandidateController.php';
require_once __DIR__ . '/../app/controllers/RecruiterController.php';
require_once __DIR__ . '/../app/controllers/AdminController.php';

// Initialize middleware
$authMiddleware = new AuthMiddleware();

// Get current request info
$uri = str_replace("/Auth", "", rtrim(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH), "/"));
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
if ($uri === "") $uri = "/";

// Apply middleware protection
if (!$authMiddleware->handle($uri, $method)) {
    exit(); // Middleware handled redirect
}

$router = new Router();

// Public Routes - Main Home Page
$router->addRouter('GET', '/', ['HomeController', 'index']);
$router->addRouter('GET', '/home', ['HomeController', 'index']);
$router->addRouter('GET', '/find-talent', ['HomeController', 'findTalent']);
$router->addRouter('GET', '/find-jobs', ['HomeController', 'findJobs']);

// Authentication Routes
$router->addRouter('GET', '/login', ['AuthController', 'loginForm']);
$router->addRouter('POST', '/login', ['AuthController', 'login']);
$router->addRouter('GET', '/register', ['AuthController', 'registerForm']);
$router->addRouter('POST', '/register', ['AuthController', 'register']);
$router->addRouter('GET', '/logout', ['AuthController', 'logout']);

// Candidate Routes
$router->addRouter('GET', '/candidate', ['CandidateController', 'dashboard']);
$router->addRouter('GET', '/candidate/dashboard', ['CandidateController', 'dashboard']);
$router->addRouter('GET', '/candidate/profile', ['CandidateController', 'profile']);
$router->addRouter('GET', '/candidate/applications', ['CandidateController', 'applications']);
$router->addRouter('GET', '/candidate/settings', ['CandidateController', 'settings']);

// Recruiter Routes
$router->addRouter('GET', '/recruiter', ['RecruiterController', 'dashboard']);
$router->addRouter('GET', '/recruiter/dashboard', ['RecruiterController', 'dashboard']);
$router->addRouter('GET', '/recruiter/jobs', ['RecruiterController', 'jobs']);
$router->addRouter('GET', '/recruiter/candidates', ['RecruiterController', 'candidates']);
$router->addRouter('GET', '/recruiter/company', ['RecruiterController', 'company']);
$router->addRouter('GET', '/recruiter/settings', ['RecruiterController', 'settings']);

// Admin Routes
$router->addRouter('GET', '/admin', ['AdminController', 'dashboard']);
$router->addRouter('GET', '/admin/dashboard', ['AdminController', 'dashboard']);
$router->addRouter('GET', '/admin/users', ['AdminController', 'users']);
$router->addRouter('GET', '/admin/roles', ['AdminController', 'roles']);
$router->addRouter('GET', '/admin/system', ['AdminController', 'system']);
$router->addRouter('GET', '/admin/logs', ['AdminController', 'logs']);

// Error Routes
$router->addRouter('GET', '/403', function() {
    http_response_code(403);
    require_once __DIR__ . '/../app/views/errors/403.php';
});

$router->addRouter('GET', '/404', function() {
    http_response_code(404);
    require_once __DIR__ . '/../app/views/errors/404.php';
});

$router->dispatch();
