USE imdb;

-- Q1. Find the total number of rows in each table of the schema?

SELECT 
    COUNT(*) AS Total_Rows
FROM
    director_mapping;

SELECT 
    COUNT(*) AS Total_Rows
FROM
    genre;
    
SELECT 
    COUNT(*) AS Total_Rows
FROM
    movie;

SELECT 
    COUNT(*) AS Total_Rows
FROM
    names;
    
SELECT 
    COUNT(*) AS Total_Rows
FROM
    ratings;
    
SELECT 
    COUNT(*) AS Total_Rows
FROM
    ratings;

SELECT 
    COUNT(*) AS Total_Rows
FROM
    role_mapping;

-- Q2. Which columns in the movie table have null values?

SELECT 
    SUM(CASE
        WHEN id IS NULL THEN 1
        ELSE 0
    END) AS null_count_id,
    SUM(CASE
        WHEN title IS NULL THEN 1
        ELSE 0
    END) AS null_count_title,
    SUM(CASE
        WHEN year IS NULL THEN 1
        ELSE 0
    END) AS null_in_year,
    SUM(CASE
        WHEN date_published IS NULL THEN 1
        ELSE 0
    END) AS null_in_date_published,
    SUM(CASE
        WHEN duration IS NULL THEN 1
        ELSE 0
    END) AS null_in_duration,
    SUM(CASE
        WHEN country IS NULL THEN 1
        ELSE 0
    END) AS null_in_country,
    SUM(CASE
        WHEN worlwide_gross_income IS NULL THEN 1
        ELSE 0
    END) AS null_in_worlwide_gross_income,
    SUM(CASE
        WHEN languages IS NULL THEN 1
        ELSE 0
    END) AS null_in_languages,
    SUM(CASE
        WHEN production_company IS NULL THEN 1
        ELSE 0
    END) AS null_in_production_company
FROM
    movie;

-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

SELECT 
    year AS Year, COUNT(id) AS number_of_movies
FROM
    movie
GROUP BY Year;

SELECT 
    MONTH(date_published) AS month_num,
    COUNT(id) AS number_of_movies
FROM
    movie
GROUP BY MONTH(date_published)
ORDER BY COUNT(id) DESC;
  
-- Q4. How many movies were produced in the USA or India in the year 2019??

SELECT 
     COUNT(DISTINCT id) Count_of_Movie_Produced
FROM
    movie
WHERE
    country LIKE '%USA%'
        OR country LIKE '%India%' 
			AND year = 2019;

-- Q5. Find the unique list of the genres present in the data set?

SELECT DISTINCT
    genre
FROM
    genre;

-- Q6.Which genre had the highest number of movies produced overall?

WITH movie_details
     AS (SELECT genre,
                Count(movie_id) AS Count_Of_Movies
         FROM   genre
         GROUP  BY genre)
SELECT genre,
       Max(count_of_movies) AS Count_Of_Movies
FROM   movie_details; 

-- Q7. How many movies belong to only one genre?

SELECT 
    COUNT(a.mid)
FROM
    (SELECT 
        movie_id AS mid
    FROM
        genre
    GROUP BY movie_id
    HAVING COUNT(DISTINCT genre) = 1) a;

-- Q8.What is the average duration of movies in each genre? 

SELECT 
    g.genre AS genre, round(AVG(m.duration),2) AS avg_duration
FROM
    movie m
        INNER JOIN
    genre g ON g.Movie_id = m.id
GROUP BY g.genre
ORDER BY avg_duration DESC;

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 

-- Method 1:
SELECT genre,movie_count,genre_rank 
	FROM (SELECT genre,
		count(movie_id) AS movie_count,
        RANK() OVER(ORDER BY count(movie_id) desc) AS genre_rank
        FROM genre
        GROUP BY genre) a WHERE a.genre = 'THRILLER';

-- Method 2:
WITH genre_summ AS
(SELECT genre,
		count(movie_id) AS movie_count,
        RANK() OVER(ORDER BY count(movie_id) desc) AS genre_rank
        FROM genre
        GROUP BY genre
)
SELECT * 
FROM genre_summ 
WHERE genre='THRILLER';

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?

SELECT 
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM
    ratings;

-- Q11. Which are the top 10 movies based on average rating?

WITH movie_ranking AS
(
           SELECT     title,
                      avg_rating,
                      Rank () OVER (ORDER BY avg_rating DESC) AS movie_rank
           FROM       movie m
           INNER JOIN ratings r
           ON         m.id = r.movie_id )
SELECT *
FROM   movie_ranking
WHERE  movie_rank<=10 limit 10;

-- Q12. Summarise the ratings table based on the movie counts by median ratings.

SELECT 
    median_rating, 
	COUNT(movie_id) AS Movie_count
FROM
    ratings
GROUP BY median_rating
ORDER BY COUNT(movie_id) DESC;

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??

WITH production_summary
     AS (SELECT m.production_company,
                Count(r.movie_id)                  AS movie_count,
                Rank()
                  OVER (
                    ORDER BY Count(movie_id) DESC) AS prod_company_rank
         FROM   ratings AS r
                INNER JOIN movie m
                        ON m.id = r.movie_id
         WHERE  r.avg_rating > 8
                AND m.production_company IS NOT NULL
         GROUP  BY m.production_company)
SELECT *
FROM   production_summary
WHERE  prod_company_rank = 1; 

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?

SELECT g.genre,
       Count(m.id) AS movie_count
FROM   movie m
       INNER JOIN genre g
               ON m.id = g.movie_id
       INNER JOIN ratings r
               ON r.movie_id = m.id
WHERE  m.year = 2017
       AND Month(m.date_published) = 3
       AND m.country LIKE 'USA'
       AND r.total_votes > 1000
GROUP  BY g.genre
ORDER  BY movie_count DESC; 

-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?

SELECT title,
       avg_rating,
       genre
FROM   movie AS m
       INNER JOIN genre AS g
               ON g.movie_id = m.id
       INNER JOIN ratings AS r
               ON r.movie_id = m.id
WHERE  avg_rating > 8
       AND title LIKE 'THE%'
GROUP  BY genre; 

-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

SELECT Count(m.id) AS MOVIES_WITH_8_MEDIAN_RATING
FROM   movie m
       INNER JOIN ratings r
               ON m.id = r.movie_id
WHERE  m.date_published BETWEEN '2018-04-01' AND '2019-04-01'
       AND median_rating = 8; 

-- Q17. Do German movies get more votes than Italian movies? 

SELECT m.country,
       Sum(r.total_votes) AS Total_number_of_votes
FROM   movie m
       INNER JOIN ratings r
               ON m.id = r.movie_id
WHERE  m.country IN( 'Germany', 'Italy' )
GROUP  BY m.country; 

-- Q18. Which columns in the names table have null values??

SELECT Sum(CASE
             WHEN NAME IS NULL THEN 1
             ELSE 0
           END) AS name_nulls,
       Sum(CASE
             WHEN height IS NULL THEN 1
             ELSE 0
           END) AS height_nulls,
       Sum(CASE
             WHEN date_of_birth IS NULL THEN 1
             ELSE 0
           END) AS date_of_birth_nulls,
       Sum(CASE
             WHEN known_for_movies IS NULL THEN 1
             ELSE 0
           END) AS known_for_movies_nulls
FROM   names; 

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?

WITH top3_genre AS
(
           SELECT     g.genre,
                      Rank() OVER(ORDER BY Count(m.id) DESC) AS movie_rank
           FROM       movie m
           INNER JOIN genre g
           ON         m.id=g.movie_id
           INNER JOIN ratings r
           ON         r.movie_id = m.id
           WHERE      r.avg_rating >8
           GROUP BY   g.genre
           ORDER BY   Count(m.id) DESC limit 3), top3_director AS
(
           SELECT     n.NAME                                       AS director_name,
                      Count(d.movie_id)                               movie_count,
                      Rank() OVER(ORDER BY Count(d.movie_id) DESC)    director_rank
           FROM       names n
           INNER JOIN director_mapping d
           ON         n.id = d.name_id
           INNER JOIN ratings r
           ON         r.movie_id = d.movie_id
           INNER JOIN genre g
           ON         g.movie_id = d.movie_id,
                      top3_genre
           WHERE      r.avg_rating > 8
           AND        g.genre IN (top3_genre.genre)
           GROUP BY   n.NAME
           ORDER BY   Count(d.movie_id) DESC )
SELECT director_name,
       movie_count
FROM   top3_director
WHERE  director_rank <= 3 limit 3;

-- Q20. Who are the top two actors whose movies have a median rating >= 8?

SELECT n.name             AS actor_name,
       Count(rm.movie_id) movie_count
FROM   role_mapping rm
       INNER JOIN names n
               ON n.id = rm.name_id
       INNER JOIN ratings r
               ON r.movie_id = rm.movie_id
WHERE  category = 'actor'
       AND r.median_rating >= 8
GROUP  BY n.name
ORDER  BY Count(rm.movie_id) DESC
LIMIT  2; 

-- Q21. Which are the top three production houses based on the number of votes received by their movies?

SELECT     production_company,
           Sum(total_votes)                                  AS vote_count ,
           Dense_rank() OVER(ORDER BY Sum(total_votes) DESC) AS production_company_rank
FROM       movie m
INNER JOIN ratings r
ON         m.id = r.movie_id
GROUP BY   production_company
ORDER BY   vote_count DESC limit 3;

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?

WITH indianactor
     AS (WITH actors
              AS (SELECT n.NAME,
                         rm.movie_id
                  FROM   role_mapping rm
                         INNER JOIN names n
                                 ON n.id = rm.name_id
                  WHERE  rm.category = 'actor')
         SELECT a.NAME,
                a.movie_id,
                m.country
          FROM   actors a
                 INNER JOIN movie m
                         ON m.id = a.movie_id
          WHERE  country = 'India')
SELECT i.NAME                          AS actor_name,
       Sum(r.total_votes)              AS total_votes,
       Count(i.movie_id)               AS movie_count,
       Round(Avg(r.avg_rating), 2)     AS actor_avg_rating,
       Row_number()
         OVER(
           ORDER BY r.avg_rating DESC) AS actor_rank
FROM   indianactor i
       INNER JOIN ratings r using(movie_id)
GROUP  BY i.NAME
HAVING Count(i.movie_id) >= 5; 

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 

WITH indian_actress
     AS (WITH actress
              AS (SELECT n.NAME,
                         rm.movie_id
                  FROM   role_mapping rm
                         INNER JOIN names n
                                 ON n.id = rm.name_id
                  WHERE  rm.category = 'actress')
         SELECT a.NAME,
                a.movie_id
          FROM   actress a
                 INNER JOIN movie m
                         ON m.id = a.movie_id
          WHERE  languages = 'HINDI')
SELECT i.NAME                                                     AS
       actress_name,
       Sum(r.total_votes)                                         AS total_votes
       ,
       Count(i.movie_id)                                          AS
       movie_count,
       Round(Sum(avg_rating * total_votes) / Sum(total_votes), 2) AS
       actress_avg_rating,
       Row_number()
         OVER(
           ORDER BY r.avg_rating DESC)                            AS
       Actress_rank
FROM   indian_actress i
       INNER JOIN ratings r using(movie_id)
GROUP  BY i.NAME
HAVING Count(i.movie_id) >= 3; 

--Q24. Select thriller movies as per avg rating and classify them in the following category: 

WITH movie_performance AS
(
SELECT 
    g.movie_id,
    title,
    g.genre,
    r.avg_rating,
    CASE
        WHEN r.avg_rating > 8 THEN 'Superhit movies'
        WHEN r.avg_rating > 7 AND r.avg_rating <= 8 THEN 'Hit movies'
        WHEN r.avg_rating >= 5 AND r.avg_rating <= 7 THEN 'One-time-watch movies'
        ELSE 'Flop Movies'
    END AS Movie_category
FROM
    genre g
        INNER JOIN
    ratings r USING (movie_id)
    inner join movie m 
    on m.id = r.movie_id
WHERE
    g.genre = 'Thriller'
)
SELECT title, avg_rating,Movie_category
 FROM movie_performance;

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 

WITH duration AS
(
           SELECT     g.genre,
                      Round(Avg(m.duration)) AS avg_duration
           FROM       genre g
           INNER JOIN movie m
           ON         m.id = g.movie_id
           GROUP BY   g.genre )
SELECT   *,
         sum(avg_duration) OVER w1 AS running_total_duration,
         avg(avg_duration) OVER w2 AS moving_total_duration
FROM     duration window w1        AS (ORDER BY avg_duration rows UNBOUNDED PRECEDING),
         w2                        AS (ORDER BY avg_duration rows 6 PRECEDING);

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 

WITH top_genre AS
(
           SELECT     genre,
                      Count(movie_id) AS number_of_movie
           FROM       genre g
           INNER JOIN movie m
           ON         g.movie_id = m.id
           GROUP BY   genre
           ORDER BY   Count(movie_id) DESC limit 3 ), top_movie AS
(
           SELECT     genre,
                      year,
                      title AS movie_name, 
                      CASE
                                 WHEN Instr(worlwide_gross_income,'INR') > 0 THEN (Replace(worlwide_gross_income,'INR ','')) /80
                                 WHEN Instr(worlwide_gross_income,'$ ') > 0 THEN Replace(worlwide_gross_income,'$ ','')
                                 ELSE NULL
                      END                                                                                        AS worlwide_gross_income1 ,
                      Rank() OVER (partition BY year ORDER BY Cast(worlwide_gross_income1 AS SIGNED) DESC)       AS movie_rank,
                      Row_number() OVER (partition BY year ORDER BY Cast(worlwide_gross_income1 AS SIGNED) DESC) AS movie_row
           FROM       genre g
           INNER JOIN movie m
           ON         g.movie_id = m.id
           WHERE      genre IN
                      (
                             SELECT genre
                             FROM   top_genre) )
SELECT   genre,
         year,
         movie_name ,
         
                  Concat('$' , Cast(worlwide_gross_income1 AS CHAR)) AS worldwide_gross_income,
         movie_rank
        
FROM     top_movie
WHERE    movie_row <= 5
ORDER BY year,
         movie_row ;

-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?

WITH company_ranking
     AS (SELECT production_company,
                Count(id)                    AS movie_count,
                Rank()
                  over (
                    ORDER BY Count(id) DESC) AS prod_comp_rank
         FROM   movie m
                inner join ratings r
                        ON m.id = r.movie_id
         WHERE  median_rating >= 8
                AND production_company IS NOT NULL
                AND Position(',' IN languages) > 0
         GROUP  BY production_company)
SELECT *
FROM   company_ranking
WHERE  prod_comp_rank <= 2; 

-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?

WITH actress_summ AS
(
           SELECT     n.NAME AS actress_name,
                      SUM(total_votes) AS total_votes,
                      Count(r.movie_id)                                     AS movie_count,
                      Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) AS actress_avg_rating
           FROM       movie                                                 AS m
           INNER JOIN ratings                                               AS r
           ON         m.id=r.movie_id
           INNER JOIN role_mapping AS rm
           ON         m.id = rm.movie_id
           INNER JOIN names AS n
           ON         rm.name_id = n.id
           INNER JOIN GENRE AS g
           ON g.movie_id = m.id
           WHERE      category = 'ACTRESS'
           AND        avg_rating>8
           AND genre = "Drama"
           GROUP BY   NAME )
SELECT   *,
         Rank() OVER(ORDER BY movie_count DESC) AS actress_rank
FROM     actress_summ LIMIT 3;

--Q29. Get the following details for top 9 directors (based on number of movies)

WITH director_1 AS
(
           SELECT     name_id AS director_id,
                      n.NAME  AS director_name,
                      r.movie_id ,
                      date_published,
                      Lead (date_published,1) OVER( partition BY NAME ORDER BY date_published, NAME) AS next_published_date,
                      avg_rating,
                      avg_rating * total_votes AS total_rating,
                      total_votes,
                      duration
           FROM       movie m
           INNER JOIN director_mapping d
           ON         m.id = d.movie_id
           INNER JOIN names n
           ON         n.id = d.name_id
           INNER JOIN ratings r
           ON         r.movie_id = m.id )
SELECT   director_id,
         director_name,
         Count(movie_id)                                                                   AS number_of_movies,
         Round(Sum(Datediff(next_published_date, date_published)) / (Count(movie_id) - 1)) AS avg_inter_movie_days,
         Round(Sum(total_rating)                                  / Sum(total_votes), 2)   AS avg_rating,
         Sum(total_votes)                                                                  AS total_votes,
         Min(avg_rating)                                                                   AS min_rating,
         Max(avg_rating)                                                                   AS max_rating,
         Sum(duration)                                                                     AS total_duration
FROM     director_1
GROUP BY director_id
ORDER BY Count(movie_id) DESC limit 9;WITH top_directors AS
(
           SELECT     name_id AS director_id,
                      NAME    AS director_name,
                      d.movie_id,
                      duration,
                      avg_rating               AS avg_rating,
                      total_votes              AS total_votes,
                      avg_rating * total_votes AS rating_count,
                      date_published,
                      Lead(date_published, 1) OVER (partition BY NAME ORDER BY date_published, NAME) AS next_publish_date
           FROM       director_mapping d
           INNER JOIN names nm
           ON         d.name_id = nm.id
           INNER JOIN movie m
           ON         d.movie_id = m.id
           INNER JOIN ratings r
           ON         m.id = r.movie_id)
SELECT   director_id,
         director_name,
         Count(movie_id)                                                             AS number_of_movies,
         Round(Sum(Datediff(next_publish_date, date_published))/(Count(movie_id)-1)) AS avg_inter_movie_days,
         Round(Sum(rating_count)                               /Sum(total_votes),2)  AS avg_rating,
         Sum(total_votes)                                                            AS total_votes,
         Min(avg_rating)                                                             AS min_rating,
         Max(avg_rating)                                                             AS max_rating,
         Sum(duration)                                                               AS total_duration
FROM     top_directors
GROUP BY director_id
ORDER BY number_of_movies DESC limit 9;

