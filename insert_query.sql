-- Insert 200 Customers
INSERT INTO customers (first_name, last_name, email, phone_number, address, city, state, country)
SELECT 
    'First' || i, 
    'Last' || i, 
    'email' || i || '@example.com', 
    '123-456-' || LPAD(i::text, 4, '0'),
    'Address ' || i, 
    'City ' || i, 
    'State ' || (CASE WHEN i % 2 = 0 THEN 'NY' ELSE 'CA' END), 
    'USA'
FROM generate_series(1, 200) AS s(i);

-- Insert 200 Products
INSERT INTO products (product_name, category, price, stock_quantity)
SELECT 
    'Product ' || i, 
    CASE WHEN i % 2 = 0 THEN 'Electronics' ELSE 'Furniture' END, 
    ROUND((100 + (RANDOM() * 500))::numeric, 2), 
    FLOOR(RANDOM() * 100) + 1
FROM generate_series(1, 200) AS s(i);

-- Insert 200 Orders
INSERT INTO orders (customer_id, total_amount)
SELECT 
    FLOOR(RANDOM() * 200) + 1, 
    ROUND((100 + (RANDOM() * 1000))::numeric, 2)
FROM generate_series(1, 200) AS s(i);

-- Insert 200 Order Items
INSERT INTO order_items (order_id, product_id, quantity, item_price)
SELECT 
    FLOOR(RANDOM() * 200) + 1, 
    FLOOR(RANDOM() * 200) + 1, 
    FLOOR(RANDOM() * 5) + 1, 
    ROUND((50 + (RANDOM() * 500))::numeric, 2)
FROM generate_series(1, 200) AS s(i);
