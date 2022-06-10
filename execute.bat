@echo off
cd /d %~dp0

powershell -ExecutionPolicy Unrestricted .\excel_automation.ps1 summary.xlsx list.txt
