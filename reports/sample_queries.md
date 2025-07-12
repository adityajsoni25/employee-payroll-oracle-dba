# 📊 Sample Report Queries – Employee Payroll System

This file includes useful SQL queries to analyze payroll data in the system.

---

## 🧮 1. Department-wise Average Salary

SELECT d.dept_name, AVG(s.net_salary) AS average_salary
FROM salaries s
JOIN employees e ON s.emp_id = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name;


## 💼 2. Monthly Salary Summary

SELECT emp_id, month, year, net_salary
FROM salaries
ORDER BY year DESC, month DESC;


## 🔁 3. Promotion History

SELECT emp_id, old_position, new_position, changed_on
FROM promotion_audit
ORDER BY changed_on DESC;


## 📅 4. Year-wise Salary History (Partitioned Table)

SELECT emp_id, month, year, net_salary
FROM salary_history
WHERE year = 2025
ORDER BY emp_id;


## 📈 5. Employees with Highest Net Salary

SELECT emp_id, net_salary
FROM salaries
ORDER BY net_salary DESC
FETCH FIRST 5 ROWS ONLY;

