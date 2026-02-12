-- create tables
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

select count(*) as total_count
from netflix

select * 
from netflix

-- Questions

1. Count the Number of Movies vs TV Shows
select distinct type, count(*) as total_content
from netflix
group by 1

-- 2. Find the most common rating for movies and TV shows
select 
		type, 
		rating,
		ranking
from		
	(select 
		type,
		rating,
		count(*) as total_rate,
		rank() over(partition by type order by count(*) desc) as ranking
	from netflix
	group by 1, 2
	)
where ranking = 1

-- 3. List all movies released in a specific year (e.g., 2020)
select
		type,
		title,
		release_year
from netflix
where type = 'Movie' and release_year = 2020

-- 4. Find the top 5 countries with the most content on Netflix
select
		unnest (string_to_array(country,',')) as new_country,
		count(show_id) as total_content
from netflix
group by 1
order by 2 desc
limit 5

-- 5. Identify the longest movie
select 	*
from netflix
where type ='movie' and duration = (select max(duration) from netflix)

-- 6. Find content added in the last 5 years
select *
from netflix
where TO_DATE(date_added, 'Month, DD, YYYY') >= current_date - Interval '5 years'

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select 
		title, 
		type,
		director
from netflix
where director ILIKE '%Rajiv Chilaka%' -- ILIKE take the all capital and small letters.

-- 8. List all TV shows with more than 5 seasons
select *
		-- split_part(duration, ' ',1) as season
from netflix
where type = 'TV Show'
			AND
			split_part(duration, ' ',1)::numeric > 5

-- 9. Count the number of content items in each genre
select 
		unnest(string_to_array(listed_in, ',')) as genre,
		count(show_id) as total_content
from netflix
group by 1 

-- 10. Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release !
select 
		extract (year from to_date(date_added, 'Month DD YYYY')) as year,
		count(*) as yearly_content,
		Round(
		count(*)::numeric/(select count(*) from netflix where country = 'India')::numeric*100,2) as avg_content_per_year
from netflix
where country ='India'
group by 1
order by 1

-- 11. List all movies that are documentaries
select 
	*
from netflix
where listed_in ilike '%Documentaries%'

-- 12. Find all content without a director
select *
from netflix
where director is null

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * FROM netflix
WHERE 
	casts ILIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select
		unnest(string_to_array (casts, ',')) as actors,
		count(*) 
from netflix
where country ilike '%India%' AND type = 'Movie'
group by 1
order by 2 desc
limit 10

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
With new_table
as
(
select *,
		CASE 
		WHEN 
				description ilike '%kill%' OR 
				description ilike '%violence%' 
			THEN 'Bad Content'
		ELSE 'Good Content'
		END category
	
from netflix
)
select 
		category,
		count(*) as total_content
from new_table
group by 1