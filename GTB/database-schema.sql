
## Banking Database Schema

```sql
-- Create the banking database
CREATE DATABASE gtb;
\c gtb;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Customers Table
CREATE TABLE customers (
    customer_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE NOT NULL,
    ssn VARCHAR(11) UNIQUE NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Account Types Table
CREATE TABLE account_types (
    account_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    interest_rate DECIMAL(5,3) DEFAULT 0.0,
    minimum_balance DECIMAL(15,2) DEFAULT 0.0
);

-- 3. Accounts Table
CREATE TABLE accounts (
    account_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL,
    account_type_id INTEGER NOT NULL,
    account_number VARCHAR(20) UNIQUE NOT NULL,
    routing_number VARCHAR(20) NOT NULL,
    current_balance DECIMAL(15,2) DEFAULT 0.0,
    available_balance DECIMAL(15,2) DEFAULT 0.0,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'FROZEN', 'CLOSED')),
    opened_date DATE DEFAULT CURRENT_DATE,
    closed_date DATE,
    last_activity_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (account_type_id) REFERENCES account_types(account_type_id)
);

-- 4. Transaction Types Table
CREATE TABLE transaction_types (
    transaction_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    is_debit BOOLEAN NOT NULL
);

-- 5. Transactions Table
CREATE TABLE transactions (
    transaction_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID NOT NULL,
    transaction_type_id INTEGER NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    description TEXT,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reference_number VARCHAR(50),
    status VARCHAR(20) DEFAULT 'COMPLETED' CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED', 'CANCELLED')),
    balance_after_transaction DECIMAL(15,2),
    merchant_info TEXT,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    FOREIGN KEY (transaction_type_id) REFERENCES transaction_types(transaction_type_id)
);

-- 6. Loans Table
CREATE TABLE loans (
    loan_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL,
    account_id UUID NOT NULL,
    loan_type VARCHAR(50) NOT NULL,
    loan_amount DECIMAL(15,2) NOT NULL,
    interest_rate DECIMAL(5,3) NOT NULL,
    term_months INTEGER NOT NULL,
    monthly_payment DECIMAL(15,2) NOT NULL,
    remaining_balance DECIMAL(15,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'PAID_OFF', 'DEFAULTED', 'DELINQUENT')),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- 7. Employees Table
CREATE TABLE employees (
    employee_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    position VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2),
    manager_id UUID,
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- 8. Branches Table
CREATE TABLE branches (
    branch_id SERIAL PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    phone VARCHAR(20),
    manager_id UUID,
    opened_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- 9. Customer Support Tickets Table
CREATE TABLE support_tickets (
    ticket_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL,
    account_id UUID,
    employee_id UUID,
    subject VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    priority VARCHAR(20) DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT')),
    status VARCHAR(20) DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    resolution_notes TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Create indexes for better performance
CREATE INDEX idx_accounts_customer_id ON accounts(customer_id);
CREATE INDEX idx_transactions_account_id ON transactions(account_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_loans_customer_id ON loans(customer_id);
CREATE INDEX idx_support_tickets_customer_id ON support_tickets(customer_id);
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_employees_department ON employees(department);

-- Default B-tree index
CREATE INDEX idx_salary ON employees(salary);

-- Hash index (use for equality search only)
CREATE INDEX idx_email_hash ON employees USING hash(email);

CLUSTER employees USING idx_emp_id;



-- Insert sample data

-- Insert Account Types
INSERT INTO account_types (type_name, description, interest_rate, minimum_balance) VALUES
('CHECKING', 'Standard checking account for everyday transactions', 0.01, 25.00),
('SAVINGS', 'Savings account with competitive interest rates', 1.25, 100.00),
('MONEY_MARKET', 'High-yield money market account', 2.15, 2500.00),
('CD', 'Certificate of Deposit with fixed term', 3.50, 1000.00),
('BUSINESS', 'Business checking account', 0.05, 500.00);

-- Insert Transaction Types
INSERT INTO transaction_types (type_name, description, is_debit) VALUES
('DEPOSIT', 'Cash or check deposit', false),
('WITHDRAWAL', 'Cash withdrawal', true),
('TRANSFER_OUT', 'Outgoing transfer', true),
('TRANSFER_IN', 'Incoming transfer', false),
('DEBIT_CARD', 'Debit card purchase', true),
('ONLINE_PAYMENT', 'Online bill payment', true),
('FEE', 'Account fee', true),
('INTEREST', 'Interest earned', false),
('CHECK', 'Check transaction', true);

-- Insert Employees (30 records)
INSERT INTO employees (employee_id, first_name, last_name, email, phone, position, department, hire_date, salary, manager_id) VALUES
(uuid_generate_v4(), 'John', 'Smith', 'john.smith@bank.com', '555-0101', 'Branch Manager', 'Management', '2018-03-15', 85000, NULL),
(uuid_generate_v4(), 'Sarah', 'Johnson', 'sarah.johnson@bank.com', '555-0102', 'Assistant Manager', 'Management', '2019-06-20', 65000, (SELECT employee_id FROM employees WHERE email = 'john.smith@bank.com')),
(uuid_generate_v4(), 'Michael', 'Brown', 'michael.brown@bank.com', '555-0103', 'Loan Officer', 'Lending', '2020-01-10', 60000, (SELECT employee_id FROM employees WHERE email = 'john.smith@bank.com')),
(uuid_generate_v4(), 'Emily', 'Davis', 'emily.davis@bank.com', '555-0104', 'Teller', 'Operations', '2021-03-22', 35000, (SELECT employee_id FROM employees WHERE email = 'sarah.johnson@bank.com')),
(uuid_generate_v4(), 'David', 'Wilson', 'david.wilson@bank.com', '555-0105', 'Teller', 'Operations', '2021-05-15', 35000, (SELECT employee_id FROM employees WHERE email = 'sarah.johnson@bank.com')),
(uuid_generate_v4(), 'Jennifer', 'Miller', 'jennifer.miller@bank.com', '555-0106', 'Personal Banker', 'Retail Banking', '2019-11-30', 52000, (SELECT employee_id FROM employees WHERE email = 'sarah.johnson@bank.com')),
(uuid_generate_v4(), 'Christopher', 'Moore', 'christopher.moore@bank.com', '555-0107', 'Mortgage Specialist', 'Lending', '2018-08-12', 68000, (SELECT employee_id FROM employees WHERE email = 'john.smith@bank.com')),
(uuid_generate_v4(), 'Amanda', 'Taylor', 'amanda.taylor@bank.com', '555-0108', 'Customer Service Rep', 'Customer Service', '2022-02-14', 38000, (SELECT employee_id FROM employees WHERE email = 'sarah.johnson@bank.com')),
(uuid_generate_v4(), 'James', 'Anderson', 'james.anderson@bank.com', '555-0109', 'IT Specialist', 'IT', '2017-09-05', 72000, NULL),
(uuid_generate_v4(), 'Lisa', 'Thomas', 'lisa.thomas@bank.com', '555-0110', 'Operations Manager', 'Operations', '2018-04-18', 78000, NULL);

-- Insert 20 more employees...
INSERT INTO employees (
    employee_id, first_name, last_name, email, phone, position, department, hire_date, salary, manager_id
)
SELECT 
    uuid_generate_v4(),
    first_names.first_name,
    last_names.last_name,
    LOWER(first_names.first_name) || '.' || LOWER(last_names.last_name) || '@bank.com',
    '555-' || LPAD((ROW_NUMBER() OVER() + 10)::TEXT, 4, '0'),
    positions.position,
    departments.department,
    CURRENT_DATE - (FLOOR(RANDOM() * 3650) || ' days')::INTERVAL,
    30000 + (FLOOR(RANDOM() * 60000))::DECIMAL,
    CASE 
        WHEN RANDOM() > 0.7 THEN NULL 
        ELSE (SELECT employee_id FROM employees ORDER BY RANDOM() LIMIT 1) 
    END
FROM 
    (VALUES 
        ('Robert'), ('Mary'), ('Patricia'), ('William'), ('Linda'), 
        ('Richard'), ('Barbara'), ('Paul'), ('Susan'), ('Steven')
    ) AS first_names(first_name),
    (VALUES 
        ('Jackson'), ('White'), ('Harris'), ('Martin'), ('Thompson'), 
        ('Garcia'), ('Martinez'), ('Robinson'), ('Clark'), ('Rodriguez')
    ) AS last_names(last_name),
    (VALUES 
        ('Teller'), ('Loan Processor'), ('Financial Analyst'), 
        ('Compliance Officer'), ('Auditor'), ('Marketing Specialist')
    ) AS positions(position),
    (VALUES 
        ('Operations'), ('Lending'), ('Compliance'), ('Marketing'), ('Finance')
    ) AS departments(department)
LIMIT 20;

-- Insert Branches
INSERT INTO branches (branch_name, address, city, state, zip_code, phone, manager_id, opened_date) VALUES
('Main Downtown', '123 Main Street', 'New York', 'NY', '10001', '555-0201', (SELECT employee_id FROM employees WHERE position = 'Branch Manager' LIMIT 1), '1995-01-15'),
('Westside Branch', '456 Oak Avenue', 'New York', 'NY', '10002', '555-0202', (SELECT employee_id FROM employees WHERE position = 'Branch Manager' LIMIT 1 OFFSET 1), '2005-08-22'),
('North Hills', '789 Pine Road', 'New York', 'NY', '10003', '555-0203', (SELECT employee_id FROM employees WHERE position = 'Assistant Manager' LIMIT 1), '2010-03-10');

-- Insert Customers (40 records)
INSERT INTO customers (customer_id, first_name, last_name, email, phone, date_of_birth, ssn, address, city, state, zip_code) VALUES
(uuid_generate_v4(), 'Alice', 'Johnson', 'alice.johnson@email.com', '555-1001', '1985-03-15', '123-45-6789', '123 Maple Street', 'New York', 'NY', '10001'),
(uuid_generate_v4(), 'Bob', 'Williams', 'bob.williams@email.com', '555-1002', '1990-07-22', '234-56-7890', '456 Oak Avenue', 'New York', 'NY', '10002'),
(uuid_generate_v4(), 'Carol', 'Martinez', 'carol.martinez@email.com', '555-1003', '1978-11-30', '345-67-8901', '789 Pine Road', 'New York', 'NY', '10003'),
(uuid_generate_v4(), 'Daniel', 'Garcia', 'daniel.garcia@email.com', '555-1004', '1982-05-14', '456-78-9012', '321 Elm Street', 'New York', 'NY', '10004'),
(uuid_generate_v4(), 'Eva', 'Rodriguez', 'eva.rodriguez@email.com', '555-1005', '1995-09-08', '567-89-0123', '654 Birch Lane', 'New York', 'NY', '10005');

-- Insert 35 more customers...
INSERT INTO customers (customer_id, first_name, last_name, email, phone, date_of_birth, ssn, address, city, state, zip_code)
SELECT 
    uuid_generate_v4(),
    first_names.first_name,
    last_names.last_name,
    LOWER(first_names.first_name) || '.' || LOWER(last_names.last_name) || '@email.com',
    '555-1' || LPAD((ROW_NUMBER() OVER() + 5)::TEXT, 3, '0'),
    (DATE '1950-01-01' + (FLOOR(RANDOM() * 18250) || ' days')::INTERVAL)::DATE,
    LPAD((ROW_NUMBER() OVER() + 5)::TEXT, 3, '0') || '-'
    || LPAD((FLOOR(RANDOM() * 89) + 10)::TEXT, 2, '0') || '-'
    || LPAD((FLOOR(RANDOM() * 8999) + 1000)::TEXT, 4, '0'),
    (FLOOR(RANDOM() * 9999) + 1)::TEXT || ' ' || 
    (ARRAY['Maple', 'Oak', 'Pine', 'Cedar', 'Elm', 'Birch', 'Willow', 'Aspen'])[FLOOR(RANDOM() * 8) + 1] || ' ' ||
    (ARRAY['Street', 'Avenue', 'Road', 'Lane', 'Drive', 'Court', 'Boulevard'])[FLOOR(RANDOM() * 7) + 1],
    'New York',
    'NY',
    '100' || LPAD((FLOOR(RANDOM() * 20) + 6)::TEXT, 2, '0')
FROM 
    (VALUES ('Sophia'), ('Liam'), ('Olivia'), ('Noah'), ('Emma'), ('Jackson'), ('Ava'), ('Lucas'), ('Isabella'), ('Mia')) AS first_names(first_name),
    (VALUES ('Johnson'), ('Williams'), ('Brown'), ('Jones'), ('Garcia'), ('Miller'), ('Davis'), ('Rodriguez'), ('Martinez'), ('Hernandez')) AS last_names(last_name)
LIMIT 35;

-- Insert Accounts (60 records - varying per customer)
INSERT INTO accounts (account_id, customer_id, account_type_id, account_number, routing_number, current_balance, available_balance, status, opened_date)
SELECT 
    uuid_generate_v4(),
    c.customer_id,
    at.account_type_id,
    'ACCT' || LPAD(ROW_NUMBER() OVER()::TEXT, 6, '0'),
    '021000021', -- Sample routing number
    (FLOOR(RANDOM() * 100000) + 1000)::DECIMAL,
    (FLOOR(RANDOM() * 100000) + 1000)::DECIMAL,
    (ARRAY['ACTIVE', 'ACTIVE', 'ACTIVE', 'INACTIVE'])[FLOOR(RANDOM() * 4) + 1],
    CURRENT_DATE - (FLOOR(RANDOM() * 3650) || ' days')::INTERVAL
FROM 
    customers c
CROSS JOIN 
    account_types at
ORDER BY 
    RANDOM()
LIMIT 60;

-- Insert Transactions (150 records - varying per account)
INSERT INTO transactions (transaction_id, account_id, transaction_type_id, amount, description, transaction_date, reference_number, status, balance_after_transaction, merchant_info)
SELECT 
    uuid_generate_v4(),
    a.account_id,
    tt.transaction_type_id,
    CASE 
        WHEN tt.is_debit THEN (FLOOR(RANDOM() * 1000) + 1)::DECIMAL * -1
        ELSE (FLOOR(RANDOM() * 2000) + 1)::DECIMAL
    END,
    CASE tt.type_name
        WHEN 'DEPOSIT' THEN 'Cash deposit'
        WHEN 'WITHDRAWAL' THEN 'ATM withdrawal'
        WHEN 'DEBIT_CARD' THEN (ARRAY['Amazon', 'Walmart', 'Starbucks', 'Target', 'Gas Station'])[FLOOR(RANDOM() * 5) + 1]
        WHEN 'ONLINE_PAYMENT' THEN (ARRAY['Electric Bill', 'Internet Bill', 'Credit Card Payment', 'Mortgage Payment'])[FLOOR(RANDOM() * 4) + 1]
        ELSE tt.type_name || ' transaction'
    END,
    CURRENT_TIMESTAMP - (FLOOR(RANDOM() * 90) || ' days ' || FLOOR(RANDOM() * 24) || ' hours ' || FLOOR(RANDOM() * 60) || ' minutes')::INTERVAL,
    'REF' || LPAD(ROW_NUMBER() OVER()::TEXT, 8, '0'),
    'COMPLETED',
    a.current_balance + (CASE WHEN tt.is_debit THEN (FLOOR(RANDOM() * 1000) + 1)::DECIMAL * -1 ELSE (FLOOR(RANDOM() * 2000) + 1)::DECIMAL END),
    CASE 
        WHEN tt.type_name = 'DEBIT_CARD' THEN (ARRAY['Amazon.com', 'Walmart Store', 'Starbucks', 'Target', 'Shell Gas'])[FLOOR(RANDOM() * 5) + 1]
        ELSE NULL
    END
FROM 
    accounts a
CROSS JOIN 
    transaction_types tt
ORDER BY 
    RANDOM()
LIMIT 150;

-- Insert Loans (20 records)
INSERT INTO loans (loan_id, customer_id, account_id, loan_type, loan_amount, interest_rate, term_months, monthly_payment, remaining_balance, start_date, end_date, status)
SELECT 
    uuid_generate_v4(),
    c.customer_id,
    a.account_id,
    (ARRAY['PERSONAL', 'AUTO', 'MORTGAGE', 'HOME_EQUITY'])[FLOOR(RANDOM() * 4) + 1],
    (FLOOR(RANDOM() * 50000) + 5000)::DECIMAL,
    (FLOOR(RANDOM() * 800) + 200)::DECIMAL / 100,
    (FLOOR(RANDOM() * 60) + 12),
    (FLOOR(RANDOM() * 1000) + 100)::DECIMAL,
    (FLOOR(RANDOM() * 40000) + 1000)::DECIMAL,
    CURRENT_DATE - (FLOOR(RANDOM() * 365) || ' days')::INTERVAL,
    CURRENT_DATE + ((FLOOR(RANDOM() * 48) + 12) || ' months')::INTERVAL,
    (ARRAY['ACTIVE', 'ACTIVE', 'ACTIVE', 'PAID_OFF', 'DELINQUENT'])[FLOOR(RANDOM() * 5) + 1]
FROM 
    customers c
JOIN 
    accounts a ON c.customer_id = a.customer_id
ORDER BY 
    RANDOM()
LIMIT 20;

-- Insert Support Tickets (30 records)
INSERT INTO support_tickets (ticket_id, customer_id, account_id, employee_id, subject, description, priority, status, created_at, resolved_at, resolution_notes)
SELECT 
    uuid_generate_v4(),
    c.customer_id,
    a.account_id,
    e.employee_id,
    (ARRAY['Lost Debit Card', 'Online Banking Issue', 'Unauthorized Transaction', 'Account Statement Question', 'Loan Application Status'])[FLOOR(RANDOM() * 5) + 1],
    'Customer reported issue regarding: ' || (ARRAY['lost card', 'login problems', 'suspicious activity', 'statement discrepancy', 'loan status'])[FLOOR(RANDOM() * 5) + 1],
    (ARRAY['LOW', 'MEDIUM', 'HIGH', 'URGENT'])[FLOOR(RANDOM() * 4) + 1],
    (ARRAY['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED'])[FLOOR(RANDOM() * 4) + 1],
    CURRENT_TIMESTAMP - (FLOOR(RANDOM() * 30) || ' days')::INTERVAL,
    CASE WHEN RANDOM() > 0.3 THEN CURRENT_TIMESTAMP - (FLOOR(RANDOM() * 10) || ' days')::INTERVAL ELSE NULL END,
    CASE WHEN RANDOM() > 0.3 THEN 'Issue resolved by providing ' || (ARRAY['new card', 'password reset', 'transaction reversal', 'statement correction', 'status update'])[FLOOR(RANDOM() * 5) + 1] ELSE NULL END
FROM 
    customers c
JOIN 
    accounts a ON c.customer_id = a.customer_id
JOIN 
    employees e ON e.department = 'Customer Service'
ORDER BY 
    RANDOM()
LIMIT 30;

-- Create a view for customer account summary
CREATE VIEW customer_account_summary AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(a.account_id) as total_accounts,
    SUM(a.current_balance) as total_balance,
    MAX(a.last_activity_date) as last_activity
FROM 
    customers c
LEFT JOIN 
    accounts a ON c.customer_id = a.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.email;

-- Create a function to calculate customer net worth
CREATE OR REPLACE FUNCTION calculate_customer_net_worth(p_customer_id UUID)
RETURNS DECIMAL AS $$
DECLARE
    total_balance DECIMAL;
    total_loans DECIMAL;
BEGIN
    -- Sum all account balances
    SELECT COALESCE(SUM(current_balance), 0)
    INTO total_balance
    FROM accounts
    WHERE customer_id = p_customer_id AND status = 'ACTIVE';
    
    -- Sum all outstanding loans
    SELECT COALESCE(SUM(remaining_balance), 0)
    INTO total_loans
    FROM loans
    WHERE customer_id = p_customer_id AND status = 'ACTIVE';
    
    RETURN total_balance - total_loans;
END;
$$ LANGUAGE plpgsql;

-- Create a stored procedure for money transfer
CREATE OR REPLACE PROCEDURE transfer_money(
    from_account_id UUID,
    to_account_id UUID,
    transfer_amount DECIMAL,
    description TEXT DEFAULT 'Account Transfer'
)
LANGUAGE plpgsql
AS $$
DECLARE
    from_balance DECIMAL;
    to_balance DECIMAL;
BEGIN
    -- Check if from_account has sufficient funds
    SELECT current_balance INTO from_balance
    FROM accounts WHERE account_id = from_account_id;
    
    IF from_balance < transfer_amount THEN
        RAISE EXCEPTION 'Insufficient funds in source account';
    END IF;
    
    -- Start transaction
    BEGIN
        -- Deduct from source account
        UPDATE accounts 
        SET current_balance = current_balance - transfer_amount,
            available_balance = available_balance - transfer_amount,
            last_activity_date = CURRENT_TIMESTAMP
        WHERE account_id = from_account_id;
        
        -- Add to destination account
        UPDATE accounts 
        SET current_balance = current_balance + transfer_amount,
            available_balance = available_balance + transfer_amount,
            last_activity_date = CURRENT_TIMESTAMP
        WHERE account_id = to_account_id;
        
        -- Record outgoing transaction
        INSERT INTO transactions (transaction_id, account_id, transaction_type_id, amount, description, balance_after_transaction)
        VALUES (
            uuid_generate_v4(),
            from_account_id,
            (SELECT transaction_type_id FROM transaction_types WHERE type_name = 'TRANSFER_OUT'),
            -transfer_amount,
            description || ' to ' || (SELECT account_number FROM accounts WHERE account_id = to_account_id),
            from_balance - transfer_amount
        );
        
        -- Record incoming transaction
        INSERT INTO transactions (transaction_id, account_id, transaction_type_id, amount, description, balance_after_transaction)
        VALUES (
            uuid_generate_v4(),
            to_account_id,
            (SELECT transaction_type_id FROM transaction_types WHERE type_name = 'TRANSFER_IN'),
            transfer_amount,
            description || ' from ' || (SELECT account_number FROM accounts WHERE account_id = from_account_id),
            (SELECT current_balance FROM accounts WHERE account_id = to_account_id)
        );
        
    EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION 'Transfer failed: %', SQLERRM;
    END;
    
END;
$$;

-- Display table counts for verification
SELECT 
    'customers' as table_name, 
    COUNT(*) as record_count 
FROM customers
UNION ALL
SELECT 'accounts', COUNT(*) FROM accounts
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL
SELECT 'employees', COUNT(*) FROM employees
UNION ALL
SELECT 'loans', COUNT(*) FROM loans
UNION ALL
SELECT 'support_tickets', COUNT(*) FROM support_tickets
ORDER BY table_name;
```

## Practice Queries to Get You Started

Here are some sample queries to practice with this database:

### Basic SELECT Queries
```sql
-- 1. Find all active customers in New York
SELECT * FROM customers WHERE city = 'New York' AND state = 'NY';

-- 2. Get account balances for a specific customer
SELECT a.account_number, at.type_name, a.current_balance
FROM accounts a
JOIN account_types at ON a.account_type_id = at.account_type_id
WHERE a.customer_id = (SELECT customer_id FROM customers WHERE email = 'alice.johnson@email.com');

-- 3. Find recent transactions for an account
SELECT t.transaction_date, tt.type_name, t.amount, t.description, t.balance_after_transaction
FROM transactions t
JOIN transaction_types tt ON t.transaction_type_id = tt.transaction_type_id
WHERE t.account_id = (SELECT account_id FROM accounts WHERE account_number = 'ACCT000001')
ORDER BY t.transaction_date DESC;
```

### JOIN Practice Queries
```sql
-- 4. Customer with their accounts and balances (INNER JOIN)
SELECT c.first_name, c.last_name, a.account_number, at.type_name, a.current_balance
FROM customers c
INNER JOIN accounts a ON c.customer_id = a.customer_id
INNER JOIN account_types at ON a.account_type_id = at.account_type_id;

-- 5. All customers with or without accounts (LEFT JOIN)
SELECT c.first_name, c.last_name, COUNT(a.account_id) as account_count
FROM customers c
LEFT JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- 6. Employees and their managers (SELF JOIN)
SELECT e.first_name, e.last_name, e.position, 
       m.first_name as manager_first, m.last_name as manager_last
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id;
```

### Advanced Queries
```sql
-- 7. Monthly transaction summary using CTE
WITH monthly_summary AS (
    SELECT 
        DATE_TRUNC('month', transaction_date) as month,
        transaction_type_id,
        COUNT(*) as transaction_count,
        SUM(amount) as total_amount
    FROM transactions
    GROUP BY DATE_TRUNC('month', transaction_date), transaction_type_id
)
SELECT 
    TO_CHAR(ms.month, 'YYYY-MM') as month,
    tt.type_name,
    ms.transaction_count,
    ms.total_amount
FROM monthly_summary ms
JOIN transaction_types tt ON ms.transaction_type_id = tt.transaction_type_id
ORDER BY ms.month DESC, ms.total_amount DESC;

-- 8. Customers with high net worth using function
SELECT 
    first_name,
    last_name,
    calculate_customer_net_worth(customer_id) as net_worth
FROM customers
WHERE calculate_customer_net_worth(customer_id) > 50000
ORDER BY net_worth DESC;
```

Server=localhost;Database=master;Trusted_Connection=True;