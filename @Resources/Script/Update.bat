@echo off
sqlite3.exe "%1" < query.sql > "%~dp0GameData.txt"