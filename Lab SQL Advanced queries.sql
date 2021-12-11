-- Lab | SQL Advanced queries
-- 1. List each pair of actors that have worked together.
with cte1 as (
	select a.actor_id, a.first_name, a.last_name, c.film_id, c.title from sakila.actor a
	left join sakila.film_actor b on a.actor_id=b.actor_id
	join sakila.film c on b.film_id = c.film_id
	) -- cte for the actor/film_actor/film join
select a1.first_name, a1.last_name, a2.first_name, a2.last_name, a1.title from cte1 a1
join cte1 a2
on a1.actor_id <> a2.actor_id
and a1.film_id = a2.film_id
where a1.actor_id > a2.actor_id
order by a1.film_id;


-- 2. For each film, list actor that has acted in more films.
with cte1 as (select actor_id, count(film_id) as movies_in from sakila.film_actor
group by actor_id), /* First, I created a cte (cte1) to count how many movies each actor has starred in, naming the column "movies_in"*/
cte2 as (
select a1.film_id, a1.actor_id, a2.movies_in,
dense_rank() over (partition by a1.film_id order by a2.movies_in desc) as rank_actor
from sakila.film_actor a1
left join cte1 a2 on a1.actor_id=a2.actor_id) /*Next, I created a second cte (cte2). 
Here, I joined the cte1 with the film_actor table and ranked the actors by number of films they star in, i.e., by "movies_in"*/
select film.title, actor.first_name, actor.last_name, cte2.movies_in as starred_in_movies
from sakila.film 
join cte2 on film.film_id=cte2.film_id
join sakila.actor on cte2.actor_id=actor.actor_id
where rank_actor=1; /*Lastly, I joined the tables "film" and "actor" to the cte2, to display the title of the movie, and the name and lastname of the actor who acted in 
more films that stars in that movie. To select only the first actor, I filtered with the WHERE clause.*/