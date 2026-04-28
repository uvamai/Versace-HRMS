# Versace HRMS - Local Development Guide

Welcome to the Versace HRMS project. This guide covers how to set up your local development environment using our automated tools.

## 🚀 One-Click Setup & Start

We have provided a unified script that handles database creation, dependency installation, migrations, data seeding, and application startup in one go.

### **In PowerShell (Recommended)**

Open a PowerShell window in the project root and run:

```powershell
.\setup-and-run.ps1
```

### **In Command Prompt (CMD)**

If you prefer the traditional command prompt:

```cmd
setup-and-run.bat
```

---

## 🛠 What Happens Under the Hood?

The automated script performs the following steps:

1.  **Config Generation**: Creates or updates your `.env` file with stable local defaults.
2.  **Database Creation**: Automatically creates the `hrms_db` PostgreSQL database if it's missing.
3.  **Backend Setup**: Sets up a Python Virtual Environment (`venv`) and installs all required packages.
4.  **Frontend Setup**: Installs Node.js dependencies via `npm install`.
5.  **Migrations**: Uses Alembic to ensure your database schema is up-to-date.
6.  **Seeding**: Seeds the database with default roles and your Super Admin account.
7.  **Startup**: Launches two background windows for the Backend and Frontend.

---

## 🌐 Dashboard & URLs

Once the script finishes its **Self-Diagnostic** check, you can access the app at:

| Component       | URL                                                      | Description                       |
| :-------------- | :------------------------------------------------------- | :-------------------------------- |
| **Frontend UI** | [http://127.0.0.1:3000](http://127.0.0.1:3000)           | Main User Interface               |
| **Backend API** | [http://127.0.0.1:8080/docs](http://127.0.0.1:8080/docs) | Interactive Swagger Documentation |

### **Default Admin Credentials**

- **Email:** `admin@versace.com`
- **Password:** `admin@1234`

---

## 💡 Maintenance Commands

| Action                   | Command                                                                                     |
| :----------------------- | :------------------------------------------------------------------------------------------ |
| **Start without Setup**  | `.\start-dev.ps1`                                                                           |
| **Reset Database**       | Delete the `hrms_db` in pgAdmin and run `.\setup-and-run.ps1`                               |
| **Create New Migration** | `cd backend; .\venv\Scripts\python.exe -m alembic revision --autogenerate -m "description"` |

## ⚠️ Troubleshooting

- **Port in use**: If the script says "FAILURE", close all existing PowerShell/CMD windows and try again.
- **Database connection**: Ensure your PostgreSQL service is running on Port 5432.
- **Login fails**: If your password doesn't work, re-run the setup script to re-seed the admin account.
