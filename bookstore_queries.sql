-- ========================================================
-- Student Name : NGUYỄN THỊ MAI ANH
-- Student ID   : 23070612
-- Assignment   : Homework 07 - Advanced SQL Queries
-- Date         : 2026-10-25
-- Database     : MySQL 8.0+
-- ========================================================

-- Query 1: Books with Authors
-- Description: List all books with their authors (title, ISBN, author name). 
-- Books with multiple authors appear multiple times.
SELECT 
    b.title AS book_title,
    b.isbn AS isbn,
    a.full_name AS author_name
FROM books b
INNER JOIN book_authors ba ON b.book_id = ba.book_id
INNER JOIN authors a ON ba.author_id = a.author_id;

/* Expected Output:
+-------------------------------+---------------+-------------------+
| book_title                    | isbn          | author_name       |
+-------------------------------+---------------+-------------------+
| Cơ sở dữ liệu nâng cao        | 978604000001  | Nguyễn Minh An    |
| Lập trình Python căn bản      | 978604000002  | Trần Thu Hà       |
| Phân tích dữ liệu kinh doanh  | 978604000003  | Lê Hoàng Nam      |
+-------------------------------+---------------+-------------------+
*/

-- Query 2: Order Details
-- Description: List all orders with customer name, order date, book title, 
-- quantity, and line total (quantity * unit_price), ordered by date descending.
SELECT 
    c.full_name AS customer_name,
    o.order_date AS order_date,
    b.title AS book_title,
    oi.quantity AS quantity,
    (oi.quantity * oi.unit_price) AS line_total
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN books b ON oi.book_id = b.book_id
ORDER BY o.order_date DESC;

/* Expected Output:
+---------------+---------------------+------------------------+----------+------------+
| customer_name | order_date          | book_title             | quantity | line_total |
+---------------+---------------------+------------------------+----------+------------+
| Nguyễn Văn A  | 2026-10-20 14:30:00 | Cơ sở dữ liệu nâng cao | 2        | 160000.00  |
| Trần Thị B    | 2026-10-18 09:15:00 | Lập trình Python       | 1        | 120000.00  |
+---------------+---------------------+------------------------+----------+------------+
*/

-- Query 3: Books with Publisher and Categories
-- Description: List each book's title, publisher name, and category name(s) across at least 3 tables.
SELECT 
    b.title AS book_title,
    p.publisher_name AS publisher_name,
    c.category_name AS category_name
FROM books b
INNER JOIN publishers p ON b.publisher_id = p.publisher_id
INNER JOIN book_categories bc ON b.book_id = bc.book_id
INNER JOIN categories c ON bc.category_id = c.category_id;

/* Expected Output:
+------------------------+-------------------+---------------+
| book_title             | publisher_name    | category_name |
+------------------------+-------------------+---------------+
| Cơ sở dữ liệu nâng cao | NXB Giáo Dục      | Công nghệ TT  |
| Cơ sở dữ liệu nâng cao | NXB Giáo Dục      | Cơ sở dữ liệu |
| Lập trình Python       | NXB Thông Tin     | Lập trình     |
+------------------------+-------------------+---------------+
*/

-- Query 4: Sales by Book
-- Description: Total quantity sold and total revenue for each book, ordered by revenue descending.
SELECT 
    b.title AS book_title,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM books b
INNER JOIN order_items oi ON b.book_id = oi.book_id
GROUP BY b.book_id, b.title
ORDER BY total_revenue DESC;

/* Expected Output:
+------------------------+---------------------+---------------+
| book_title             | total_quantity_sold | total_revenue |
+------------------------+---------------------+---------------+
| Cơ sở dữ liệu nâng cao | 15                  | 1200000.00    |
| Lập trình Python       | 10                  | 950000.00     |
+------------------------+---------------------+---------------+
*/

-- Query 5: Customer Order Summary
-- Description: Number of orders placed and total amount spent per customer. 
-- Includes customers with zero orders via LEFT JOIN.
SELECT 
    c.full_name AS customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.full_name;

/* Expected Output:
+---------------+--------------+-------------+
| customer_name | total_orders | total_spent |
+---------------+--------------+-------------+
| Nguyễn Văn A  | 3            | 380000.00   |
| Lê Văn C      | 0            | 0.00        |
+---------------+--------------+-------------+
*/

-- Query 6: Books Above Average Price
-- Description: List all books whose price is higher than the overall average price.
SELECT 
    b.title AS book_title,
    b.price AS price
FROM books b
WHERE b.price > (
    SELECT AVG(price) 
    FROM books
);

/* Expected Output:
+------------------------+-----------+
| book_title             | price     |
+------------------------+-----------+
| Cơ sở dữ liệu nâng cao | 120000.00 |
| Thiết kế hệ thống lớn  | 185000.00 |
+------------------------+-----------+
*/

-- Query 7: Best-Selling Author
-- Description: Find author(s) with the highest total sold quantity. 
-- Handles ties using a subquery (no LIMIT clause).
SELECT 
    a.full_name AS author_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM authors a
INNER JOIN book_authors ba ON a.author_id = ba.author_id
INNER JOIN order_items oi ON ba.book_id = oi.book_id
GROUP BY a.author_id, a.full_name
HAVING SUM(oi.quantity) = (
    SELECT MAX(author_sales.total_qty)
    FROM (
        SELECT SUM(oi2.quantity) AS total_qty
        FROM authors a2
        INNER JOIN book_authors ba2 ON a2.author_id = ba2.author_id
        INNER JOIN order_items oi2 ON ba2.book_id = oi2.book_id
        GROUP BY a2.author_id
    ) AS author_sales
);

/* Expected Output:
+----------------+---------------------+
| author_name    | total_quantity_sold |
+----------------+---------------------+
| Nguyễn Minh An | 25                  |
+----------------+---------------------+
*/

-- Query 8: Prolific Reviewers
-- Description: Customers who wrote more than 2 reviews rated 3 stars or higher.
SELECT 
    c.full_name AS customer_name,
    COUNT(r.review_id) AS qualified_review_count
FROM customers c
INNER JOIN reviews r ON c.customer_id = r.customer_id
WHERE r.rating >= 3
GROUP BY c.customer_id, c.full_name
HAVING COUNT(r.review_id) > 2;

/* Expected Output:
+---------------+------------------------+
| customer_name | qualified_review_count |
+---------------+------------------------+
| Nguyễn Văn A  | 4                      |
+---------------+------------------------+
*/

-- Query 9: Create a Book Sales Summary View
-- Description: Create view v_book_sales_summary showing title, ISBN, publisher name, 
-- sales statistics, and review metrics.

DROP VIEW IF EXISTS v_book_sales_summary;

CREATE VIEW v_book_sales_summary AS
SELECT 
    b.title AS book_title,
    b.isbn AS isbn,
    p.publisher_name AS publisher_name,
    COALESCE(sales.total_quantity_sold, 0) AS total_quantity_sold,
    COALESCE(sales.total_revenue, 0.00) AS total_revenue,
    rev.avg_rating AS average_rating,
    COALESCE(rev.review_count, 0) AS number_of_reviews
FROM books b
LEFT JOIN publishers p ON b.publisher_id = p.publisher_id
LEFT JOIN (
    SELECT 
        book_id,
        SUM(quantity) AS total_quantity_sold,
        SUM(quantity * unit_price) AS total_revenue
    FROM order_items
    GROUP BY book_id
) sales ON b.book_id = sales.book_id
LEFT JOIN (
    SELECT 
        book_id,
        ROUND(AVG(rating), 2) AS avg_rating,
        COUNT(review_id) AS review_count
    FROM reviews
    GROUP BY book_id
) rev ON b.book_id = rev.book_id;

-- Demonstration of Query 9:
SELECT 
    book_title, 
    isbn, 
    publisher_name, 
    total_quantity_sold, 
    total_revenue, 
    average_rating, 
    number_of_reviews
FROM v_book_sales_summary;

/* Expected Output:
+------------------------+---------------+----------------+---------------------+---------------+----------------+-------------------+
| book_title             | isbn          | publisher_name | total_quantity_sold | total_revenue | average_rating | number_of_reviews |
+------------------------+---------------+----------------+---------------------+---------------+----------------+-------------------+
| Cơ sở dữ liệu nâng cao | 978604000001  | NXB Giáo Dục   | 15                  | 1200000.00    | 4.67           | 3                 |
| Sách chưa bán          | 978604000099  | NXB Kim Đồng   | 0                   | 0.00          | NULL           | 0                 |
+------------------------+---------------+----------------+---------------------+---------------+----------------+-------------------+
*/

-- Query 10: Monthly Revenue Report
-- Description: Monthly revenue report for each month of the current year (months 1-12).
-- Includes months with zero orders/revenue using UNION/derived calendar table.
SELECT 
    cal.month_num AS month_number,
    cal.month_name AS month_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(oi.quantity), 0) AS total_items_sold,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS total_revenue
FROM (
    SELECT 1 AS month_num, 'January' AS month_name UNION ALL
    SELECT 2, 'February' UNION ALL
    SELECT 3, 'March' UNION ALL
    SELECT 4, 'April' UNION ALL
    SELECT 5, 'May' UNION ALL
    SELECT 6, 'June' UNION ALL
    SELECT 7, 'July' UNION ALL
    SELECT 8, 'August' UNION ALL
    SELECT 9, 'September' UNION ALL
    SELECT 10, 'October' UNION ALL
    SELECT 11, 'November' UNION ALL
    SELECT 12, 'December'
) cal
LEFT JOIN orders o 
    ON cal.month_num = MONTH(o.order_date) 
    AND YEAR(o.order_date) = YEAR(CURRENT_DATE)
LEFT JOIN order_items oi 
    ON o.order_id = oi.order_id
GROUP BY cal.month_num, cal.month_name
ORDER BY cal.month_num ASC;

/* Expected Output:
+--------------+------------+--------------+------------------+---------------+
| month_number | month_name | total_orders | total_items_sold | total_revenue |
+--------------+------------+--------------+------------------+---------------+
| 1            | January    | 5            | 12               | 410000.00     |
| 2            | February   | 0            | 0                | 0.00          |
...
| 10           | October    | 8            | 19               | 730000.00     |
+--------------+------------+--------------+------------------+---------------+
*/