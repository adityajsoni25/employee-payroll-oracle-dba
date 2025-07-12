
-- Author: Aditya Soni

-- ==================================================
-- Employee Payroll System (Oracle DBA Project)
-- ===================================================

-- Drop existing tables (for reset)
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE salary_log PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE salary_history PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE salaries PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE deductions PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE employees PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE departments PURGE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- 1. DEPARTMENTS Table
CREATE TABLE departments (
    dept_id     NUMBER PRIMARY KEY,
    dept_name   VARCHAR2(100) NOT NULL,
    location    VARCHAR2(100)
);

-- 2. EMPLOYEES Table
CREATE TABLE employees (
    emp_id      NUMBER PRIMARY KEY,
    name        VARCHAR2(100) NOT NULL,
    dept_id     NUMBER,
    position    VARCHAR2(50),
    hire_date   DATE,
    basic_salary NUMBER(10, 2) CHECK (basic_salary > 0),
    CONSTRAINT fk_dept FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- 3. DEDUCTIONS Table
CREATE TABLE deductions (
    deduction_id    NUMBER PRIMARY KEY,
    emp_id          NUMBER,
    reason          VARCHAR2(100),
    amount          NUMBER(10, 2) CHECK (amount >= 0),
    deduction_date  DATE,
    CONSTRAINT fk_deduct_emp FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

-- 4. SALARIES Table
CREATE TABLE salaries (
    salary_id   NUMBER PRIMARY KEY,
    emp_id      NUMBER,
    month       VARCHAR2(15),
    year        NUMBER,
    bonus       NUMBER(10, 2),
    deduction   NUMBER(10, 2),
    net_salary  NUMBER(10, 2),
    CONSTRAINT fk_salary_emp FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

-- 5. SALARY_HISTORY Table (Partitioned by year)
CREATE TABLE salary_history (
    hist_id     NUMBER PRIMARY KEY,
    emp_id      NUMBER,
    month       VARCHAR2(15),
    year        NUMBER,
    net_salary  NUMBER(10,2)
)
PARTITION BY RANGE (year) (
    PARTITION p_2023 VALUES LESS THAN (2024),
    PARTITION p_2024 VALUES LESS THAN (2025),
    PARTITION p_2025 VALUES LESS THAN (2026),
    PARTITION future  VALUES LESS THAN (MAXVALUE)
);

-- Sample Departments
INSERT INTO departments VALUES (1, 'HR', 'Head Office');
INSERT INTO departments VALUES (2, 'IT', 'Tech Park');

-- Sample Employees
INSERT INTO employees VALUES (101, 'Rahul Sharma', 1, 'HR Executive', TO_DATE('2022-06-01', 'YYYY-MM-DD'), 50000);
INSERT INTO employees VALUES (102, 'Priya Mehta', 2, 'Software Engineer', TO_DATE('2021-09-15', 'YYYY-MM-DD'), 70000);

-- Sample Deductions
INSERT INTO deductions VALUES (1, 101, 'Late Arrival', 500, SYSDATE);
INSERT INTO deductions VALUES (2, 102, 'Leave Without Pay', 1000, SYSDATE);

-- Sample Salaries
INSERT INTO salaries VALUES (1, 101, 'July', 2025, 2000, 500, 51500);
INSERT INTO salaries VALUES (2, 102, 'July', 2025, 3000, 1000, 72000);

-- Trigger: Log salary updates
CREATE TABLE salary_log (
    log_id        NUMBER GENERATED ALWAYS AS IDENTITY,
    emp_id        NUMBER,
    old_salary    NUMBER(10,2),
    new_salary    NUMBER(10,2),
    updated_on    TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE OR REPLACE TRIGGER trg_salary_update
BEFORE UPDATE ON salaries
FOR EACH ROW
WHEN (OLD.net_salary != NEW.net_salary)
BEGIN
    INSERT INTO salary_log(emp_id, old_salary, new_salary)
    VALUES (:OLD.emp_id, :OLD.net_salary, :NEW.net_salary);
END;
/

-- Trigger: Audit employee promotion (position change)
CREATE TABLE promotion_audit (
    audit_id      NUMBER GENERATED ALWAYS AS IDENTITY,
    emp_id        NUMBER,
    old_position  VARCHAR2(50),
    new_position  VARCHAR2(50),
    changed_on    TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE OR REPLACE TRIGGER trg_employee_promotion
BEFORE UPDATE OF position ON employees
FOR EACH ROW
WHEN (OLD.position != NEW.position)
BEGIN
    INSERT INTO promotion_audit(emp_id, old_position, new_position)
    VALUES (:OLD.emp_id, :OLD.position, :NEW.position);
END;
/

-- Procedure: Calculate Monthly Salary
CREATE SEQUENCE salary_history_seq START WITH 1;

CREATE OR REPLACE PROCEDURE calc_monthly_salary (
    p_emp_id IN NUMBER,
    p_bonus IN NUMBER,
    p_deduction IN NUMBER
) IS
    v_salary NUMBER;
BEGIN
    SELECT basic_salary INTO v_salary FROM employees WHERE emp_id = p_emp_id;
    v_salary := v_salary + p_bonus - p_deduction;

    INSERT INTO salary_history (hist_id, emp_id, month, year, net_salary)
    VALUES (salary_history_seq.NEXTVAL, p_emp_id, TO_CHAR(SYSDATE, 'Month'), EXTRACT(YEAR FROM SYSDATE), v_salary);

    DBMS_OUTPUT.PUT_LINE('Salary calculated: ' || v_salary);
END;
/

-- View: Department-wise salary summary
CREATE OR REPLACE VIEW dept_salary_view AS
SELECT d.dept_name, COUNT(e.emp_id) AS total_employees, AVG(s.net_salary) AS avg_salary
FROM salaries s
JOIN employees e ON s.emp_id = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name;

-- Index for performance
CREATE INDEX idx_emp_salary ON salaries(emp_id, year, month);
