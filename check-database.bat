@echo off
echo ========================================
echo Database Verification Tool
echo ========================================
echo.

mysql -u root -pviper professional_network < backend\sql-schema\verify-database.sql

echo.
echo ========================================
echo Verification Complete!
echo ========================================
echo.
echo Check the output above for:
echo - Trigger count (should be 8)
echo - Procedure count (should be 4)
echo - PHONE field status
echo - USER_ACTIVITY table status
echo.
pause
