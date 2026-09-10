DROP TABLE IF EXISTS OLYMPICS_HISTORY;
CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY
(
id			INT,
name		VARCHAR,
sex			VARCHAR,
age			VARCHAR,
height		VARCHAR,
weight		VARCHAR,
team		VARCHAR,
noc			VARCHAR,
games		VARCHAR,
year		INT,
season		VARCHAR,
city		VARCHAR,
sport		VARCHAR,
event		VARCHAR,
medal		VARCHAR

);


DROP TABLE IF EXISTS OLYMPICS_HISTORY_NOC_REGIONS;
CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY_NOC_REGIONS
(
NOC			VARCHAR,
region		VARCHAR,
note		VARCHAR
);

select * from OLYMPICS_HISTORY;
select *from  OLYMPICS_HISTORY_NOC_REGIONS;

-- Write a query to identify which sport that was played in all summer olympics.
1. find the total number of summer olympic games
2. find for each sport, how many games where they played in.
3. compare 1 and 2

select sport, count(distinct games) as no_of_games
from OLYMPICS_HISTORY
where season = 'Summer'
group by sport
having count(distinct games) = 
(select count(distinct games)
from OLYMPICS_HISTORY
where season = 'Summer');

--or using cte

with T1 as 
	(select count(distinct games) as total_summer_games
	from olympics_history
	where season = 'Summer'),
T2 as
	(select distinct sport, games
	from olympics_history
	where season = 'Summer'),
T3 as
	(select sport, count(games) as no_of_games
	from T2
	group by sport)

select *
from T3
join T1 on T1.total_summer_games = T3.no_of_games;

-- fetch the top 5 athletes who have won the most golden medals
select * from OLYMPICS_HISTORY;

select distinct(medal)
from OLYMPICS_HISTORY;

select *
from olympics_history
where medal = 'Gold';

with t1 as
	(select name, count(1) as total_medals
	from olympics_history
	where medal = 'Gold'
	group by name
	order by count(1) desc),
t2 as
	(select *, rank() over(order by total_medals desc) as Rank
	from t1)
select *
from t2
where rank <= 5;

-- list down total gold, silver and bronze medals won by each country
select * from OLYMPICS_HISTORY;

select distinct team as country, medal, count(1) as count_medal
from OLYMPICS_HISTORY
where medal in ('Gold', 'Silver', 'Bronze')
group by team, medal
order by team, medal;

-- more complex approach

select nr.region as country, medal, count(1) as total_medals
from OLYMPICS_HISTORY oh
join olympics_history_noc_regions nr on nr.noc = oh.noc
where medal <> 'NA'
group by nr.region, medal
order by nr.region, medal;


--CREATE EXTENSION TABLEFUNC;

select country 
,	coalesce(gold, 0 ) as gold
,	coalesce(silver, 0 ) as silver
,	coalesce(bronze, 0 ) as bronze
from crosstab($$select nr.region as country, medal, count(1) as total_medals
			from OLYMPICS_HISTORY oh
			join olympics_history_noc_regions nr on nr.noc = oh.noc
			where medal <> 'NA' 
			group by nr.region, medal
			order by nr.region, medal$$,
			$$values ('Bronze'), ('Gold'), ('Silver')$$)
	as result(country varchar, bronze bigint, gold bigint, silver bigint)
order by gold desc, silver desc, bronze desc;

-- simpler query using filter 

select nr.region as country, 
count(1) filter (where medal = 'Gold') as gold,
count(1) filter (where medal = 'Silver') as Silver,
count(1) filter (where medal = 'Bronze') as Bronze
from OLYMPICS_HISTORY oh
join olympics_history_noc_regions nr on nr.noc = oh.noc
where medal <> 'NA'
group by nr.region
order by gold desc, silver desc, bronze desc;

-- Identify which country won the most gold, most silver and most bronze in each olympic game 
select * from OLYMPICS_HISTORY;

select games, medal, count(1) as no_of_medal
from OLYMPICS_HISTORY
where medal <> 'NA'
group by games, medal;


select games, 
count(1) filter (where medal = 'Gold') as gold,
count(1) filter (where medal = 'Silver') as Silver,
count(1) filter (where medal = 'Bronze') as Bronze
from OLYMPICS_HISTORY
where medal <> 'NA'
group by games
order by gold desc, silver desc, bronze desc
limit 10;

with medal_counts as ( 
select games, 
noc as country, 
count(1) filter (where medal = 'Gold') as gold,
count(1) filter (where medal = 'Silver') as Silver,
count(1) filter (where medal = 'Bronze') as Bronze
from OLYMPICS_HISTORY
where medal <> 'NA'
group by games, noc
)
		select distinct games,
		first_value(country) over(partition by games order by gold desc)
		|| '(' || first_value(gold) over(partition by games order by gold desc) || ')'
		as max_gold,
		first_value(country) over(partition by games order by silver desc)
		|| '(' || first_value(silver) over(partition by games order by silver desc) || ')'
		as max_silver,
		first_value(country) over(partition by games order by bronze desc)
		|| '(' || first_value(bronze) over(partition by games order by bronze desc) || ')'
		as max_bronze
from medal_counts
order by games desc;




















