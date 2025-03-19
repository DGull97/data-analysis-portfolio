/* Question 1
What does the forked connection from employee_id to reports_to mean?
*/

-- 1. View employees and their managers
SELECT 
    e.employee_id AS employee_id,                 -- Employee's unique ID
    e.first_name AS employee_first_name,          -- Employee's first name
    e.last_name AS employee_last_name,           -- Employee's last name
    m.first_name AS manager_first_name,          -- Manager's first name
    m.last_name AS manager_last_name             -- Manager's last name
FROM 
    employee e                                   -- Employee table aliased as 'e'
LEFT JOIN 
    employee m ON e.reports_to = m.employee_id   -- Self-join to link employees to their managers
ORDER BY 
    e.employee_id;                               -- Sort results by employee ID


-- 2. Find employees without a manager (Top-level managers)
SELECT 
    employee_id,                                  -- Employee's unique ID
    first_name,                                   -- Employee's first name
    last_name,                                    -- Employee's last name
    title                                         -- Employee's job title
FROM 
    employee
WHERE 
    reports_to IS NULL;                           -- Employees with no manager


-- 3. Find employees reporting to a specific manager (e.g., employee_id = 2)
SELECT 
    employee_id,                                  -- Employee's unique ID
    first_name,                                   -- Employee's first name
    last_name,                                    -- Employee's last name
    title                                         -- Employee's job title
FROM 
    employee
WHERE 
    reports_to = 2;                               -- Replace '2' with any manager's employee_id


-- 4. Count how many employees report to each manager
SELECT 
    m.first_name AS manager_first_name,           -- Manager's first name
    m.last_name AS manager_last_name,             -- Manager's last name
    COUNT(e.employee_id) AS number_of_reports     -- Number of direct reports
FROM 
    employee m                                    -- Manager table aliased as 'm'
LEFT JOIN 
    employee e ON e.reports_to = m.employee_id    -- Join to count how many report to each manager
GROUP BY 
    m.employee_id, m.first_name, m.last_name      -- Group by manager to count reports
ORDER BY 
    number_of_reports DESC;                       -- Sort by most reports


-- 5. Show the full reporting structure (Employee -> Manager -> Upper Manager)
SELECT 
    e.first_name AS employee_first_name,          -- Employee's first name
    e.last_name AS employee_last_name,           -- Employee's last name
    m.first_name AS manager_first_name,          -- Direct manager's first name
    m.last_name AS manager_last_name,            -- Direct manager's last name
    mm.first_name AS upper_manager_first_name,   -- Manager's manager first name
    mm.last_name AS upper_manager_last_name      -- Manager's manager last name
FROM 
    employee e                                    -- Employee table aliased as 'e'
LEFT JOIN 
    employee m ON e.reports_to = m.employee_id    -- First join to find direct manager
LEFT JOIN 
    employee mm ON m.reports_to = mm.employee_id  -- Second join to find manager's manager
ORDER BY 
    e.employee_id;                                -- Sort by employee ID





/* Question 3
Say we want to "denormalize" the data by including album and artist data in the track table, then discarding the album and artist tables. 
Would we be able to do this without transforming the format of the data or level of aggregation in the album and artist tables?
*/

-- Check how many artists are linked to each album
SELECT 
    a.album_id,                -- Selects the album ID from the track table
    al.title AS album_name,     -- Selects the album title, renaming it as 'album_name'
    ar.name AS artist_name,     -- Selects the artist's name, renaming it as 'artist_name'
    COUNT(*) AS track_count     -- Counts how many tracks are linked to each album-artist pair
FROM 
    track a                    -- Uses the 'track' table and aliases it as 'a'
JOIN 
    album al ON a.album_id = al.album_id  -- Joins 'album' table on matching 'album_id'
JOIN 
    artist ar ON al.artist_id = ar.artist_id  -- Joins 'artist' table on matching 'artist_id'
GROUP BY 
    a.album_id, al.title, ar.name  -- Groups results by album ID, album title, and artist name
ORDER BY 
    a.album_id;               -- Sorts the results by album ID in ascending order


-- Select track details along with associated album and artist information
SELECT 
    t.track_id,                      -- Unique identifier for each track
    t.name AS track_name,            -- Track name, renamed for clarity
    al.title AS album_name,          -- Album title, renamed for clarity
    ar.name AS artist_name,          -- Artist name, renamed for clarity
    t.composer,                      -- Composer of the track
    t.milliseconds,                  -- Duration of the track in milliseconds
    t.unit_price                     -- Price of the track
FROM 
    track t                         -- Start from the 'track' table, alias as 't'

-- Join the 'album' table to link each track to its album
JOIN 
    album al ON t.album_id = al.album_id  -- Match 'album_id' between 'track' and 'album'

-- Join the 'artist' table to link each album to its artist
JOIN 
    artist ar ON al.artist_id = ar.artist_id  -- Match 'artist_id' between 'album' and 'artist'

-- Sort the result by track ID for better readability
ORDER BY 
    t.track_id;


-- Create a new table to store the denormalized data
CREATE TABLE denormalized_tracks AS
SELECT 
    t.track_id,                      -- Unique identifier for each track
    t.name AS track_name,            -- Track name, renamed for clarity
    al.title AS album_name,          -- Album title, renamed for clarity
    STRING_AGG(ar.name, ', ') AS artist_names,  -- Combine multiple artists into one field (Do not have permission in this Database)
    t.composer,                      -- Composer of the track
    t.milliseconds,                  -- Duration of the track in milliseconds
    t.unit_price                     -- Price of the track
FROM 
    track t                         -- Start from the 'track' table, alias as 't'

-- Join the 'album' table to link each track to its album
JOIN 
    album al ON t.album_id = al.album_id  -- Match 'album_id' between 'track' and 'album'

-- Join the 'artist' table to link each album to its artist
JOIN 
    artist ar ON al.artist_id = ar.artist_id  -- Match 'artist_id' between 'album' and 'artist'

-- Group by track details to correctly aggregate artist names
GROUP BY 
    t.track_id, t.name, al.title, t.composer, t.milliseconds, t.unit_price

-- Sort the result by track ID for better readability
ORDER BY 
    t.track_id;





/* Question 4:
Suppose you want to know the names of playlists that artists have appeared on. How many tables do you need to join?
*/

SELECT 
    ar.name AS artist_name,        -- Artist's name
    p.name AS playlist_name        -- Playlist's name
FROM 
    artist ar
JOIN 
    album al ON ar.artist_id = al.artist_id    -- Artist to Album
JOIN 
    track t ON al.album_id = t.album_id        -- Album to Track
JOIN 
    playlist_track pt ON t.track_id = pt.track_id  -- Track to Playlist_Track
JOIN 
    playlist p ON pt.playlist_id = p.playlist_id   -- Playlist_Track to Playlist
ORDER BY 
    ar.name, p.name;





/* Question 5:
A manager is someone who has at least one direct report. How many Chinook employees are not managers?
*/

-- Find the total number of employees in the company
SELECT 
    COUNT(*) AS total_employees  -- Count all employees
FROM employee;

-- Find the total number of managers (employees who have at least one direct report)
SELECT 
    COUNT(DISTINCT reports_to) AS total_managers  -- Count unique managers
FROM employee
WHERE reports_to IS NOT NULL;  -- Ignore NULL values (top-level employees like the CEO)

-- Find the total number of employees who are NOT managers
SELECT 
    COUNT(*) AS non_managers  -- Count employees who are not in the managers' list
FROM employee
WHERE employee_id NOT IN (
    SELECT DISTINCT reports_to FROM employee WHERE reports_to IS NOT NULL  -- Get list of managers
);

-- Full query to retrieve all counts in one result set
SELECT 
    (SELECT COUNT(*) FROM employee) AS total_employees,  -- Total number of employees
    (SELECT COUNT(DISTINCT reports_to) FROM employee WHERE reports_to IS NOT NULL) AS total_managers,  -- Total managers
    (SELECT COUNT(*) FROM employee 
     WHERE employee_id NOT IN (SELECT DISTINCT reports_to FROM employee WHERE reports_to IS NOT NULL)) AS non_managers;  -- Total non-managers





/* Question 6:
Which tables are required in a query that counts the number of tracks sold?
*/

-- Count total number of tracks sold
SELECT 
    COUNT(*) AS total_tracks_sold  -- Count all rows in 'invoice_line' to get total tracks sold
FROM 
    invoice_line;  -- Each row represents a track sold in an invoice


-- Count the number of times each track has been sold
SELECT 
    t.name AS track_name,               -- Select the track name for readability
    COUNT(il.track_id) AS total_sold    -- Count occurrences of each track in 'invoice_line' to get total sales
FROM 
    invoice_line il                      -- Sales transactions stored in 'invoice_line'
JOIN 
    track t ON il.track_id = t.track_id  -- Join to get track names from 'track' table
GROUP BY 
    t.name   -- Group by track name to count sales for each track separately
ORDER BY 
    total_sold DESC;   -- Sort by most sold tracks first





/* Question 7:
Which media type has the lowest number of tracks sold?
*/

-- Find the media type with the lowest number of tracks sold
SELECT 
    mt.name AS media_type,          -- Select the media type name for readability
    COUNT(il.track_id) AS total_sold  -- Count occurrences of each track in 'invoice_line' to get total sales
FROM 
    invoice_line il                  -- Sales transactions stored in 'invoice_line'
JOIN 
    track t ON il.track_id = t.track_id  -- Join to get track details from 'track' table
JOIN 
    media_type mt ON t.media_type_id = mt.media_type_id  -- Join to get media type information
GROUP BY 
    mt.name  -- Group by media type to count sales for each type separately
ORDER BY 
    total_sold ASC  -- Order by the lowest sales first
LIMIT 1;  -- Select only the media type with the fewest tracks sold





/* Question 8:
Count the number of tracks sold grouped by genre name. Then compare the average of these numbers to the median. How do they compare?
*/

-- Count the number of tracks sold grouped by genre
SELECT 
    g.name AS genre_name,          -- Retrieve the name of each genre for readability
    COUNT(il.track_id) AS total_sold  -- Count how many times each track appears in 'invoice_line', representing total sales per genre
FROM 
    invoice_line il                 -- Sales transactions are recorded in the 'invoice_line' table
JOIN 
    track t ON il.track_id = t.track_id  -- Join with 'track' table to link each sold track to its genre
JOIN 
    genre g ON t.genre_id = g.genre_id  -- Join with 'genre' table to retrieve genre names
GROUP BY 
    g.name  -- Group by genre to get the total number of tracks sold per genre
ORDER BY 
    total_sold DESC;  -- Order results in descending order to show the most popular genres first


-- Calculate the average (mean) number of tracks sold per genre
SELECT AVG(total_sold) AS average_sold  -- Calculate the average number of tracks sold across all genres
FROM (
    SELECT 
        g.name AS genre_name, 
        COUNT(il.track_id) AS total_sold  -- Count total sales per genre
    FROM 
        invoice_line il  -- Sales transactions stored in 'invoice_line'
    JOIN 
        track t ON il.track_id = t.track_id  -- Join with 'track' table to link each track to its genre
    JOIN 
        genre g ON t.genre_id = g.genre_id  -- Join with 'genre' table to retrieve genre names
    GROUP BY 
        g.name  -- Group by genre to get total track sales per genre
) AS genre_sales;  -- Subquery aggregates total sales per genre before calculating the average


-- Calculate the median number of tracks sold per genre
SELECT total_sold
FROM (
    SELECT 
        g.name AS genre_name, 
        COUNT(il.track_id) AS total_sold  -- Count total sales per genre to determine the median
    FROM 
        invoice_line il  -- Sales transactions stored in 'invoice_line'
    JOIN 
        track t ON il.track_id = t.track_id  -- Join with 'track' table to associate each track with its genre
    JOIN 
        genre g ON t.genre_id = g.genre_id  -- Join with 'genre' table to retrieve genre names
    GROUP BY 
        g.name  -- Group by genre to obtain total track sales per genre
    ORDER BY total_sold  -- Order results in ascending order to facilitate median calculation
) AS genre_sales
LIMIT 1 OFFSET (SELECT COUNT(*)/2 FROM genre);  -- Retrieve the middle value in the ordered list, approximating the median





/* Question 10:
What's the name of the playlist with the second greatest number of tracks?
*/

-- Find the playlist with the second greatest number of tracks
SELECT 
    p.name AS playlist_name,  -- Retrieve the playlist name for readability
    COUNT(pt.track_id) AS track_count  -- Count how many tracks are in each playlist
FROM 
    playlist p  -- Base playlist table
JOIN 
    playlist_track pt ON p.playlist_id = pt.playlist_id  -- Join to associate playlists with tracks
GROUP BY 
    p.name  -- Group by playlist name to calculate track counts per playlist
ORDER BY 
    track_count DESC  -- Order by track count in descending order to rank playlists from most to least tracks
LIMIT 1 OFFSET 1;  -- Skip the most populated playlist (OFFSET 1) and retrieve the second greatest (LIMIT 1)





/* Question 11:
How many unique songs are there across all playlists?
*/

-- Count the number of unique songs across all playlists
SELECT 
    COUNT(DISTINCT track_id) AS unique_songs  -- Count distinct track IDs to get the number of unique songs
FROM 
    playlist_track;  -- This table links tracks to playlists, where tracks can appear multiple times in different playlists





/*
Question 12: 
What percentage of the tracks in Chinooks catalog appear in at least one playlist?
*/

-- Calculate the percentage of tracks that appear in at least one playlist
SELECT 
    (COUNT(DISTINCT pt.track_id) * 100.0 / COUNT(DISTINCT t.track_id)) AS percentage_in_playlists  -- Compute percentage
FROM 
    track t  -- Base table containing all available tracks
LEFT JOIN 
    playlist_track pt ON t.track_id = pt.track_id;  -- Left join to check which tracks exist in at least one playlist





/* Question 13:
Note that composer is sometimes NULL. Ignoring these cases, which composer appears the most times across all playlists?
*/

-- Find the composer who appears the most across all playlists
SELECT 
    t.composer,  -- Retrieve the composer's name
    COUNT(pt.track_id) AS appearances  -- Count how many times the composer's tracks appear in playlists
FROM 
    playlist_track pt  -- Tracks associated with playlists
JOIN 
    track t ON pt.track_id = t.track_id  -- Join to get composer details for each track
WHERE 
    t.composer IS NOT NULL  -- Exclude NULL values since some tracks may not have a listed composer
GROUP BY 
    t.composer  -- Group results by composer to count their occurrences across playlists
ORDER BY 
    appearances DESC  -- Sort results by the highest number of appearances first
LIMIT 1;  -- Retrieve only the composer with the highest occurrence





/* Question 14:
Which artist/composer combination have the most number of tracks together? Do not ignore cases with NULL composer. When composer is null, overwrite the null value with the artist associated with the track
*/ 

-- Find the most frequent artist/composer combination, replacing NULL composers with the artist name
SELECT 
    ar.name AS artist_name,  -- Retrieve the artist's name
    COALESCE(t.composer, ar.name) AS composer_name,  -- Replace NULL composers with the artist's name
    COUNT(t.track_id) AS track_count  -- Count the number of tracks associated with each artist/composer pair
FROM 
    track t  -- Track table contains track details, including composer
JOIN 
    album al ON t.album_id = al.album_id  -- Join to get album details, which links tracks to artists
JOIN 
    artist ar ON al.artist_id = ar.artist_id  -- Join to get artist names associated with each album
GROUP BY 
    ar.name, composer_name  -- Group by both artist name and adjusted composer name to count occurrences
ORDER BY 
    track_count DESC  -- Sort by the highest number of tracks first
LIMIT 1;  -- Retrieve only the most frequent artist/composer combination





/* Question 15:
How can we determine which employee gets credit for helping a customer with a purchase?
*/

-- Determine which employee gets credit for helping a customer with a purchase
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,  -- Retrieve the full name of the employee
    c.first_name || ' ' || c.last_name AS customer_name,  -- Retrieve the full name of the customer
    i.invoice_id,  -- Display the invoice ID to reference the transaction
    i.total AS sale_amount  -- Display the total sale amount for the invoice
FROM 
    invoice i  -- Base table containing sales transaction data
JOIN 
    customer c ON i.customer_id = c.customer_id  -- Join with 'customer' to link invoices to customers
JOIN 
    employee e ON c.support_rep_id = e.employee_id  -- Join with 'employee' to find which employee is assigned to the customer
ORDER BY 
    e.employee_id, i.invoice_id;  -- Sort by employee ID and invoice ID for better organization





/* Question 16:
How much more revenue is the employee with the most sales responsible for compared to the employee with the least sales? Answer in percentage terms.
*/

-- Calculate the percentage difference between the highest and lowest revenue-generating employees
WITH EmployeeSales AS (
    SELECT 
        e.employee_id,  -- Unique identifier for each employee
        e.first_name || ' ' || e.last_name AS employee_name,  -- Concatenate first and last name for readability
        SUM(i.total) AS total_revenue  -- Sum of total revenue generated by each employee
    FROM 
        invoice i  -- Invoice table containing sales transactions
    JOIN 
        customer c ON i.customer_id = c.customer_id  -- Join to associate invoices with customers
    JOIN 
        employee e ON c.support_rep_id = e.employee_id  -- Join to associate customers with their assigned employees
    GROUP BY 
        e.employee_id, employee_name  -- Group by employee to calculate their total revenue
)
SELECT 
    ((MAX(total_revenue) - MIN(total_revenue)) * 100.0 / MIN(total_revenue)) AS revenue_difference_percentage  -- Calculate percentage difference relative to the lowest revenue employee
FROM 
    EmployeeSales;





/* Question 17:
In what year-month's (YYYY-MM) was total revenue at Chinook greater than it was in the previous month by at least 40%?
*/

-- Identify months where total revenue increased by at least 40% compared to the previous month (PostgreSQL version)
WITH MonthlyRevenue AS (
    SELECT 
        TO_CHAR(i.invoice_date, 'YYYY-MM') AS year_month,  -- Convert invoice_date to YYYY-MM format (PostgreSQL function)
        SUM(i.total) AS total_revenue  -- Calculate total revenue for each month
    FROM 
        invoice i
    GROUP BY 
        year_month  -- Group data by year and month to aggregate revenue
), 
RevenueGrowth AS (
    SELECT 
        mr.year_month,  -- Year and month of revenue calculation
        mr.total_revenue,  -- Current month's total revenue
        LAG(mr.total_revenue) OVER (ORDER BY mr.year_month) AS previous_month_revenue,  -- Retrieve previous month's revenue
        ((mr.total_revenue - LAG(mr.total_revenue) OVER (ORDER BY mr.year_month)) * 100.0 / LAG(mr.total_revenue) OVER (ORDER BY mr.year_month)) AS revenue_growth_percentage  -- Calculate revenue growth percentage
    FROM 
        MonthlyRevenue mr
)
SELECT 
    year_month  -- Output year-months where revenue increased by at least 40%
FROM 
    RevenueGrowth
WHERE 
    revenue_growth_percentage >= 40;  -- Filter only those months where growth is at least 40%
	
	
	
	
	
	/* Question 18:
Every year Chinook employees compete to see who can bring in the most revenue. Who has won this competition the most times?
*/

-- Identify the employee who won the most revenue competitions per year
WITH YearlyEmployeeRevenue AS (
    SELECT 
        EXTRACT(YEAR FROM i.invoice_date) AS year,  -- Extract year from invoice_date
        e.first_name || ' ' || e.last_name AS employee_name,  -- Concatenate first and last name for readability
        SUM(i.total) AS total_revenue  -- Calculate total revenue generated by each employee per year
    FROM 
        invoice i  -- Invoice table containing sales transactions
    JOIN 
        customer c ON i.customer_id = c.customer_id  -- Join to associate invoices with customers
    JOIN 
        employee e ON c.support_rep_id = e.employee_id  -- Join to associate customers with their assigned employees
    GROUP BY 
        year, employee_name  -- Group revenue data by year and employee
), 
YearlyTopEmployee AS (
    SELECT 
        year,  -- Year of revenue calculation
        employee_name,  -- Employee who earned revenue that year
        RANK() OVER (PARTITION BY year ORDER BY total_revenue DESC) AS rank  -- Rank employees by revenue within each year
    FROM 
        YearlyEmployeeRevenue
)
SELECT 
    employee_name, 
    COUNT(*) AS times_won  -- Count how many times each employee ranked #1 in a given year
FROM 
    YearlyTopEmployee
WHERE 
    rank = 1  -- Only consider employees who ranked #1 in their respective years
GROUP BY 
    employee_name  -- Group by employee name to count the number of times they won
ORDER BY 
    times_won DESC;  -- Sort to see who won the most times





/* Question 19:
Suppose you want to calculate the ratio between the number of tracks sold in year X and year X + 1 to determine year over year growth. However, there were no tracks sold in year X. What is an acceptable approach to this issue?
*/

-- Calculate year-over-year track sales growth while handling cases where year X has zero sales
WITH YearlyTrackSales AS (
    SELECT 
        EXTRACT(YEAR FROM i.invoice_date) AS year,  -- Extract year from invoice date
        COUNT(t.track_id) AS tracks_sold  -- Count the number of tracks sold in that year
    FROM 
        invoice i
    JOIN 
        invoice_line il ON i.invoice_id = il.invoice_id  -- Link invoices to invoice_line
    JOIN 
        track t ON il.track_id = t.track_id  -- Link invoice_line to track table
    GROUP BY 
        year  -- Group data by year to calculate yearly sales
),
YearlyGrowth AS (
    SELECT 
        yt.year,
        yt.tracks_sold,
        LAG(yt.tracks_sold) OVER (ORDER BY yt.year) AS previous_year_tracks,  -- Get previous year's sales
        CASE 
            WHEN LAG(yt.tracks_sold) OVER (ORDER BY yt.year) = 0 THEN NULL  -- If previous year's sales are 0, set growth as NULL (undefined)
            ELSE ((yt.tracks_sold - LAG(yt.tracks_sold) OVER (ORDER BY yt.year)) * 100.0 / LAG(yt.tracks_sold) OVER (ORDER BY yt.year))
        END AS growth_percentage  -- Calculate growth only when previous year sales > 0
    FROM 
        YearlyTrackSales yt
)
SELECT * FROM YearlyGrowth;





/* Question 20:
What percentage growth did the Metal genre experience in terms of number of tracks sold between 2023 and 2024?
*/

-- Calculate the percentage growth of Metal genre track sales from 2023 to 2024
WITH GenreSales AS (
    SELECT 
        EXTRACT(YEAR FROM i.invoice_date) AS year,  -- Extract year from invoice_date
        g.name AS genre_name,  -- Retrieve genre name
        COUNT(il.track_id) AS total_tracks_sold  -- Count number of tracks sold per year per genre
    FROM 
        invoice i  -- Invoice table containing sales transactions
    JOIN 
        invoice_line il ON i.invoice_id = il.invoice_id  -- Join to get track sales
    JOIN 
        track t ON il.track_id = t.track_id  -- Join track to get genre_id
    JOIN 
        genre g ON t.genre_id = g.genre_id  -- Join genre to get genre name
    WHERE 
        g.name = 'Metal'  -- Filter only for Metal genre
    GROUP BY 
        year, genre_name  -- Group data by year and genre
),
YearlyGrowth AS (
    SELECT 
        gs.year,  -- Year of revenue calculation
        gs.total_tracks_sold,  -- Number of tracks sold in that year
        LAG(gs.total_tracks_sold) OVER (ORDER BY gs.year) AS previous_year_tracks,  -- Get previous year's sales
        ((gs.total_tracks_sold - LAG(gs.total_tracks_sold) OVER (ORDER BY gs.year)) * 100.0 / LAG(gs.total_tracks_sold) OVER (ORDER BY gs.year)) AS growth_percentage  -- Calculate growth percentage
    FROM 
        GenreSales gs
)
SELECT 
    year,  -- Year for which we calculate growth
    total_tracks_sold,  -- Number of tracks sold in that year
    growth_percentage  -- Percentage growth compared to the previous year
FROM 
    YearlyGrowth
WHERE 
    year = 2024;  -- Get growth percentage for 2024
	




/* Question 21:
Amongst Genre's that sold at least 10 tracks in 2023, which one experienced the greatest decrease in sales from the previous year?
*/

-- Identify the genre that experienced the greatest decrease in sales from 2022 to 2023
WITH GenreSales AS (
    SELECT 
        EXTRACT(YEAR FROM i.invoice_date) AS year,  -- Extract year from invoice_date
        g.name AS genre_name,  -- Retrieve genre name
        COUNT(il.track_id) AS total_tracks_sold  -- Count number of tracks sold per year per genre
    FROM 
        invoice i  -- Invoice table containing sales transactions
    JOIN 
        invoice_line il ON i.invoice_id = il.invoice_id  -- Join to get track sales
    JOIN 
        track t ON il.track_id = t.track_id  -- Join track to get genre_id
    JOIN 
        genre g ON t.genre_id = g.genre_id  -- Join genre to get genre name
    GROUP BY 
        year, genre_name  -- Group by year and genre
), 
YearlyGrowth AS (
    SELECT 
        gs.year,  -- Year of revenue calculation
        gs.genre_name,  -- Genre name
        gs.total_tracks_sold,  -- Number of tracks sold in that year
        LAG(gs.total_tracks_sold) OVER (PARTITION BY gs.genre_name ORDER BY gs.year) AS previous_year_tracks,  -- Get previous year's sales
        ((gs.total_tracks_sold - LAG(gs.total_tracks_sold) OVER (PARTITION BY gs.genre_name ORDER BY gs.year)) * 100.0 / LAG(gs.total_tracks_sold) OVER (PARTITION BY gs.genre_name ORDER BY gs.year)) AS growth_percentage  -- Calculate growth percentage
    FROM 
        GenreSales gs
)
SELECT 
    genre_name,  -- Name of the genre
    total_tracks_sold,  -- Number of tracks sold in 2023
    growth_percentage  -- Percentage growth compared to 2022 (negative means decline)
FROM 
    YearlyGrowth
WHERE 
    year = 2023  -- Focus on sales decline in 2023
    AND total_tracks_sold >= 10  -- Ensure at least 10 tracks were sold in 2023 to be considered
ORDER BY 
    growth_percentage ASC  -- Sort to find the greatest decrease (most negative percentage)
LIMIT 1;  -- Get the genre with the greatest decline





/* Question 23:
Consider a customer "loyal" if their average invoice total in the last 6 months exceeds their average invoice total prior to the last 6 months. Suppose that the current date is 2024-05-07. How many customers are loyal?
*/

-- Identify the number of loyal customers based on their average invoice total increase
WITH InvoiceAverages AS (
    SELECT 
        i.customer_id,  -- Identify each customer
        
        -- Compute the average invoice total for the last 6 months
        AVG(CASE WHEN i.invoice_date >= '2023-11-07' THEN i.total END) AS avg_last_6_months,
        
        -- Compute the average invoice total for the period before the last 6 months
        AVG(CASE WHEN i.invoice_date < '2023-11-07' THEN i.total END) AS avg_prior_period
    FROM 
        invoice i  -- Base table containing sales transaction data
    GROUP BY 
        i.customer_id  -- Group by customer to get averages for each one
)
SELECT 
    COUNT(*) AS loyal_customers  -- Count customers who qualify as loyal
FROM 
    InvoiceAverages
WHERE 
    avg_last_6_months > avg_prior_period;  -- Customers whose recent average spending is higher than the previous period





/* Question 24:
The Chinook database is to some extent "normalized". In fact it meets most of the requirements of the first normal form i.e. 1NF. Which is an aspect of 1NF that is not satisfied by Chinook?
*/

-- Identify columns in Chinook database that contain non-atomic values
SELECT 
    column_name,  -- Name of the column
    table_name,  -- Table where the column exists
    data_type  -- Data type of the column
FROM 
    information_schema.columns  -- System table listing all columns
WHERE 
    table_schema = 'public'  -- Filter for the public schema (default in PostgreSQL)
    AND (
        column_name ILIKE '%composer%'  -- Look for common multi-value columns like 'composer'
        OR column_name ILIKE '%tags%'  -- Look for potential non-atomic values like tags
        OR column_name ILIKE '%list%'  -- Look for columns that might store lists of values
    );

-- Alternative query to check for non-atomic data in specific columns
SELECT 
    track_id,  -- Unique identifier for the track
    composer  -- Column suspected of containing multiple values
FROM 
    track
WHERE 
    composer LIKE '%,%';  -- Find rows where composer contains multiple values (comma-separated)





/* Question 25:
The composer field is not atomic because it can hold multiple names separated by a comma. How can we atomize this data?
*/

-- Step 1: Create the 'composer' table to store individual composers
CREATE TABLE composer (
    composer_id SERIAL PRIMARY KEY,  -- Unique ID for each composer
    name TEXT NOT NULL UNIQUE  -- Composer's name (must be unique)
);

-- Step 2: Create the 'track_composer' table to manage the many-to-many relationship
CREATE TABLE track_composer (
    track_id INTEGER REFERENCES track(track_id) ON DELETE CASCADE,  -- Foreign key referencing 'track'
    composer_id INTEGER REFERENCES composer(composer_id) ON DELETE CASCADE,  -- Foreign key referencing 'composer'
    PRIMARY KEY (track_id, composer_id)  -- Composite primary key to avoid duplicates
);

-- Step 3: Populate the 'composer' table with distinct composer names
INSERT INTO composer (name)
SELECT DISTINCT UNNEST(string_to_array(composer, ', ')) FROM track  -- Split multiple composer names
WHERE composer IS NOT NULL;

-- Step 4: Populate the 'track_composer' table with relationships
INSERT INTO track_composer (track_id, composer_id)
SELECT t.track_id, c.composer_id
FROM track t
JOIN composer c ON c.name = ANY(string_to_array(t.composer, ', '));  -- Match composers to tracks

-- Step 5: Remove the old 'composer' column from 'track' (optional, after verification)
ALTER TABLE track DROP COLUMN composer;