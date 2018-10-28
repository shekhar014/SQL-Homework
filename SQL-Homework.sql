-- Use Sakila Database
use sakila;

-- Display the first and last names of all actors from the table actor
SELECT 
    first_name AS 'First Name', last_name AS 'Last Name'
FROM
    actor;
  
--  Display the first and last name of each actor in a single column in upper case letters. 
--  Name the column Actor Name
SELECT 
    UPPER(CONCAT(first_name, ' ', last_name)) AS 'Actor Name'
FROM
    actor;
  
-- You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information? 
SELECT 
    ACTOR_ID AS ID,
    FIRST_NAME AS 'First Name',
    LAST_NAME AS 'Last Name'
FROM
    ACTOR
WHERE
    FIRST_NAME = UPPER('Joe')
        OR first_name = LOWER('Joe');

-- Find all actors whose last name contain the letters GEN
-- COLLATE UTF8 GENERAL CI will take care of all upper and lower case
SELECT 
    *
FROM
    actor
WHERE
    last_name COLLATE UTF8_GENERAL_CI LIKE '%Gen%';

-- Find all actors whose last names contain the letters LI.
-- This time, order the rows by last name and first name, in that order

SELECT 
    last_name AS 'Last Name',
    first_name AS 'First Name',
    actor_id AS ID
FROM
    actor
WHERE
    last_name COLLATE UTF8_GENERAL_CI LIKE '%li%'
ORDER BY last_name , first_name;

-- Using IN, display the country_id and country columns of the following countries:
-- Afghanistan, Bangladesh, and China
SELECT 
    country_id, country
FROM
    country
WHERE
    country COLLATE UTF8_GENERAL_CI IN ('Afghanistan' , 'Bangladesh', 'China');
    
-- You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, so create a column in the table
-- actor named description and use the data type BLOB (Make sure to research the type BLOB, as the
-- difference between it and VARCHAR are significant).   

ALTER TABLE actor
ADD COLUMN description BLOB; 

-- Very quickly you realize that entering descriptions for each actor is too much effort.
-- Delete the description column.

ALTER TABLE actor
DROP COLUMN description;

--  List the last names of actors, as well as how many actors have that last name.
SELECT 
    last_name AS 'Last Name',
    COUNT(last_name) AS 'Number of Actors'
FROM
    actor
GROUP BY last_name;

--  List last names of actors and the number of actors who have that last name,
--  but only for names that are shared by at least two actors
SELECT 
    last_name AS 'Last Name',
    COUNT(last_name) AS 'Number of Actors'
FROM
    actor
GROUP BY last_name
HAVING COUNT(last_name) >= 2;

-- The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS.
-- Write a query to fix the record.
UPDATE actor 
SET 
    first_name = 'HARPO',
    last_name = 'WILLIAMS'
WHERE
    first_name = 'GROUCHO'
        AND last_name = 'WILLIAMS';	
        
-- Perhaps we were too hasty in changing GROUCHO to HARPO.
-- It turns out that GROUCHO was the correct name after all! In a single query,
-- if the first name of the actor is currently HARPO, change it to GROUCHO.   


UPDATE actor 
SET 
    first_name = 'GROUCHO'
WHERE
    actor_id = 172;
     
-- You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

CREATE TABLE IF NOT EXISTS `address` (
    `address_id` SMALLINT(5) UNSIGNED NOT NULL AUTO_INCREMENT,
    `address` VARCHAR(50) NOT NULL,
    `address2` VARCHAR(50) NULL DEFAULT NULL,
    `district` VARCHAR(20) NOT NULL,
    `city_id` SMALLINT(5) UNSIGNED NOT NULL,
    `postal_code` VARCHAR(10) NULL DEFAULT NULL,
    `phone` VARCHAR(20) NOT NULL,
    `location` GEOMETRY NOT NULL,
    `last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`address_id`),
    INDEX `idx_fk_city_id` (`city_id` ASC),
    SPATIAL INDEX `idx_location` ( `location` ASC ),
    CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`)
        REFERENCES `sakila`.`city` (`city_id`)
        ON UPDATE CASCADE
)  ENGINE=INNODB AUTO_INCREMENT=606 DEFAULT CHARACTER SET=UTF8;

-- Use JOIN to display the first and last names, as well as the address, of each staff member.
-- Use the tables staff and address
SELECT 
    a.first_name AS 'First Name',
    a.last_name AS 'Last Name',
    b.address AS 'Address'
FROM
    staff a
        JOIN
    address b ON a.address_id = b.address_id;
    
-- Use JOIN to display the total amount rung up by each staff member in August of 2005.
-- Use tables staff and payment.
SELECT 
    SUM(b.amount) AS 'Total Amount'
FROM
    staff a
        JOIN
    payment b
WHERE
    a.staff_id = b.staff_id
        AND MONTH(b.payment_date) = 8;

-- List each film and the number of actors who are listed for that film.
-- Use tables film_actor and film. Use inner join. 
SELECT 
    a.title AS 'Name of Film',
    count(b.actor_id) AS 'Number of Actors'
FROM
    film a
        INNER JOIN
    film_actor b ON a.film_id = b.film_id
    group by a.title
    order by a.title;

-- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT 
    b.title AS Title, COUNT(*)
FROM
    inventory a
        JOIN
    film b ON a.film_id = b.film_id
        AND b.title COLLATE UTF8_GENERAL_CI = 'Hunchback Impossible';
        
    

-- Using the tables payment and customer and the JOIN command,
-- list the total paid by each customer. List the customers alphabetically by last name:
SELECT 
    a.first_name AS 'First Name',
    a.last_name AS 'Last Name',
    SUM(b.amount) AS 'Total Amount Paid'
FROM
    customer a
        JOIN
    payment b
WHERE
    a.customer_id = b.customer_id
GROUP BY b.customer_id
ORDER BY a.last_name ASC;

-- The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters K and Q have also soared 
-- in popularity. Use subqueries to display the titles of movies starting with the letters K and Q 
-- whose language is English.

SELECT 
    title as "Movie Name"
FROM
    film
WHERE
    title COLLATE UTF8_GENERAL_CI LIKE  'Q%'
        OR title COLLATE UTF8_GENERAL_CI LIKE 'K%'
        AND language_id IN (SELECT 
            language_id
        FROM
            language
        WHERE
            name = 'English');

--  Use subqueries to display all actors who appear in the film Alone Trip
SELECT 
    first_name, last_name
FROM
    actor
WHERE
    actor_id IN (SELECT 
            actor_id
        FROM
            film_actor
        WHERE
            film_id IN (SELECT 
                    film_id
                FROM
                    film
                WHERE
                    title = 'Alone Trip'));

-- You want to run an email marketing campaign in Canada,
-- for which you will need the names and email addresses of all Canadian customers.
-- Use joins to retrieve this information.   
 SELECT 
    a.first_name, a.last_name, a.email
FROM
    customer a
        JOIN
    address b ON a.address_id = b.address_id
        JOIN
    city c ON b.city_id = c.city_id
        JOIN
    country d ON c.country_id = d.country_id
WHERE
    d.country = 'Canada'; 
    

-- Sales have been lagging among young families, and you wish to target all family movies
-- for a promotion. Identify all movies categorized as family films.
SELECT 
    a.title AS 'Movie Name', c.name AS 'Category'
FROM
    film a
        JOIN
    film_category b ON a.film_id = b.film_id
        JOIN
    category c ON b.category_id = c.category_id
WHERE
    c.name COLLATE UTF8_GENERAL_CI LIKE '%family%';

-- Display the most frequently rented movies in descending order.
SELECT 
    f.title AS Title, COUNT(rental_id) AS 'Times Rented'
FROM
    rental r
        JOIN
    inventory i ON (r.inventory_id = i.inventory_id)
        JOIN
    film f ON (i.film_id = f.film_id)
GROUP BY f.title
ORDER BY `Times Rented` DESC;

--  Write a query to display how much business, in dollars, each store brought in.

SELECT 
    s.store_id, SUM(amount) AS business_in_dollars
FROM
    store s
        INNER JOIN
    staff st ON s.store_id = st.store_id
        INNER JOIN
    payment p ON p.staff_id = st.staff_id
GROUP BY s.store_id
ORDER BY business_in_dollars ASC;

-- Write a query to display for each store its store ID, city, and country.
SELECT 
    store_id, city, country
FROM
    store s
        JOIN
    address a ON (s.address_id = a.address_id)
        JOIN
    city c ON (a.city_id = c.city_id)
        JOIN
    country ctry ON (c.country_id = ctry.country_id);
    
--  List the top five genres in gross revenue in descending order.
-- (Hint: you may need to use the following tables: category, film_category, inventory,
-- payment, and rental.)   

SELECT 
    name AS top_five, SUM(amount) AS gross_revenue
FROM
    category c
        INNER JOIN
    film_category fc ON c.category_id = fc.category_id
        INNER JOIN
    inventory i ON fc.film_id = i.film_id
        INNER JOIN
    rental r ON i.inventory_id = r.inventory_id
        INNER JOIN
    payment p ON r.rental_id = p.rental_id
GROUP BY top_five
ORDER BY gross_revenue
LIMIT 5;   

-- In your new role as an executive, you would like to have an easy way of viewing the Top 
-- five genres by gross revenue. Use the solution from the problem above to create a view.
-- If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_grossing_genres AS
    SELECT 
        name AS top_five, SUM(amount) AS gross_revenue
    FROM
        category c
            INNER JOIN
        film_category fc ON c.category_id = fc.category_id
            INNER JOIN
        inventory i ON fc.film_id = i.film_id
            INNER JOIN
        rental r ON i.inventory_id = r.inventory_id
            INNER JOIN
        payment p ON r.rental_id = p.rental_id
    GROUP BY top_five
    ORDER BY gross_revenue
    LIMIT 5;
-- How would you display the view that you created in 8a?
SELECT * FROM top_five_grossing_genres;

--  You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_grossing_genres;