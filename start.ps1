& "C:\pgsql\pgsql\bin\pg_ctl.exe" -D "C:\pgsql\data" start
Start-Sleep -Seconds 3
cd C:\Users\hp\fittrack-backend
.\venv\Scripts\activate
uvicorn main:app --reload
