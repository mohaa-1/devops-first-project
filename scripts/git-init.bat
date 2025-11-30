@echo off
REM Git Initialization Script for Windows

echo.
echo ========================================
echo  Git Initialization Script
echo ========================================
echo.

REM Check if git is installed
git --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Git is not installed
    echo Please install Git from: https://git-scm.com/download/win
    pause
    exit /b 1
)

REM Check if already a git repository
if exist .git (
    echo Git repository already initialized.
    echo.
    git status
    pause
    exit /b 0
)

REM Get user information
set /p git_name="Enter your name: "
set /p git_email="Enter your email: "

REM Initialize git
echo.
echo Initializing git repository...
git init

REM Configure user
echo.
echo Configuring git user...
git config user.name "%git_name%"
git config user.email "%git_email%"

REM Add all files
echo.
echo Adding files to git...
git add .

REM Make initial commit
echo.
echo Making initial commit...
git commit -m "Initial commit: Production microservices app with K8s, monitoring, and CI/CD"

REM Instructions for GitHub
echo.
echo ========================================
echo  Git Initialized Successfully!
echo ========================================
echo.
echo Next steps:
echo.
echo 1. Create a repository on GitHub:
echo    https://github.com/new
echo    Name: microservices-k8s-project
echo    Do NOT initialize with README or .gitignore
echo.
echo 2. Add GitHub as remote (replace YOUR_USERNAME):
echo    git remote add origin https://github.com/YOUR_USERNAME/microservices-k8s-project.git
echo.
echo 3. Push to GitHub:
echo    git push -u origin main
echo.
echo Or use the git-push.bat script after setting up remote
echo.
pause
