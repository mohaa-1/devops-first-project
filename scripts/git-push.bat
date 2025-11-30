@echo off
REM GitHub Push Script for Windows
REM Quick script to commit and push changes

echo.
echo ========================================
echo  Pushing to GitHub
echo ========================================
echo.

REM Check if git is initialized
git status >nul 2>&1
if errorlevel 1 (
    echo ERROR: Not a git repository. Run git-init.bat first.
    pause
    exit /b 1
)

REM Get commit message
set /p commit_msg="Enter commit message: "
if "%commit_msg%"=="" (
    echo ERROR: Commit message cannot be empty
    pause
    exit /b 1
)

REM Add all changes
echo.
echo Adding files...
git add .

REM Commit changes
echo.
echo Committing changes...
git commit -m "%commit_msg%"

REM Push to GitHub
echo.
echo Pushing to GitHub...
git push origin main

if errorlevel 1 (
    echo.
    echo ERROR: Failed to push to GitHub
    echo Make sure you have:
    echo 1. Created a GitHub repository
    echo 2. Added the remote: git remote add origin YOUR_REPO_URL
    echo 3. Authenticated with GitHub (use Personal Access Token)
    pause
    exit /b 1
)

echo.
echo ========================================
echo  Successfully pushed to GitHub!
echo ========================================
echo.
echo View your repository at:
echo https://github.com/YOUR_USERNAME/microservices-k8s-project
echo.
pause
