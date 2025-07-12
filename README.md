# employee-payroll-oracle-dba
An advanced Oracle SQL and PL/SQL-based payroll management system for handling employee records, monthly salary calculations, departmental analytics, auditing promotions, and automating backups. Designed to showcase real-world DBA concepts like partitioning, triggers, views, procedures, and performance tuning.

# Employee Payroll System (Oracle DBA Project)

![ER Diagram](./ERD/employee_payroll_erd.png)

## 📌 Project Overview

An advanced Oracle SQL and PL/SQL-based payroll management system for handling employee data, salary calculations, department-based analytics, deductions, and performance tuning features. Designed with real-world DBA concepts including auditing, partitioning, triggers, and automated backup setup.

---

## 🏗️ Project Structure
<img width="1024" height="1024" alt="image" src="https://github.com/user-attachments/assets/8b2c68ed-b648-45c3-ab51-00a60563ae67" />




---

## ✅ Key Features

| Feature                 | Description                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| 🛡️ Constraints           | Primary Keys, Foreign Keys, and Check Constraints                          |
| 🧠 Stored Procedures      | `calc_monthly_salary()` procedure for salary calculation                   |
| 🔁 Triggers              | Audit triggers for salary updates and promotions                           |
| 📁 Partitioning           | `salary_history` table partitioned by `year`                               |
| 🔍 Views                 | `dept_salary_view` for average salary by department                        |
| 🧾 Auditing              | Track employee promotions via `promotion_audit`                            |
| 📊 Reports               | Weekly salary summaries and departmental analysis                          |
| 💾 Backup Scheduler      | `DBMS_SCHEDULER` job for daily logical backup (Data Pump)                   |
| ⚡ Indexing              | Indexed `salaries` on `emp_id`, `month`, `year` for performance             |

---

## 📊 Report Queries

- Monthly salary details  
- Department-wise salary average  
- Promotion logs  
- Salary history by year (partitioned)

(See: `reports/sample_queries.md`)

---

## 🛠️ Technologies Used

- Oracle SQL / PL/SQL  
- Oracle Data Pump  
- DBMS_SCHEDULER  
- SQL Developer

---

## 🧑‍💻 Author

**Aditya Soni**  
GitHub: [@adityajsoni25](https://github.com/adityajsoni25)  
Computer Engineering Student

---

