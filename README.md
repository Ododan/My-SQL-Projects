# Olympic Games Performance Analysis
### Project Overview

This data analysis project provides historical insights into the performance, participation, and trends of athletes and countries across the modern Olympic Games. By leveraging historical dataset records, this project explores medal distributions, gender participation trends over time, and dominant nations across various sporting disciplines.

### Data Sources

- **Olympics History Data:** The primary dataset consists of historical records covering Olympic events, athlete attributes (age, height, weight), national team affiliations (NOC codes), and medal outcomes (`OLYMPICS_HISTORY` and `OLYMPICS_HISTORY_NOC_REGIONS`).

### Tools
- Microsoft Excel and Power Query - Data Cleaning [Download here](https://microsoft.com)
- SQL Server - Data Analysis & Querying

### Data Cleaning/Preparation

In the initial data preparation phase, we performed the following tasks:
- Data loading and inspection.
- Handling missing values (e.g., imputed missing athlete heights and weights using sports-specific medians, filtered out unrecorded medal attributes).
- Data cleaning and formatting (standardizing country NOC codes, dates, and event discipline names).

### Exploratory Data Analysis (EDA)

- EDA involved writing targeted SQL queries to answer specific historical questions, such as:
- Which sports have been played in every single Summer Olympic Games edition?
- Who are the top 5 most decorated gold medalists in Olympic history?
- - Which countries have won the highest total number of medals historically?
- What is the total breakdown of Gold, Silver, and Bronze medals won per country and per Olympic host year?
cross specific sports?

### Data Analysis

Include some interesting code/features worked with:
Identification of sport that was played in all summer olympics
```sql
select sport, count(distinct games) as no_of_games
from OLYMPICS_HISTORY
where season = 'Summer'
group by sport
having count(distinct games) = 
(select count(distinct games)
from OLYMPICS_HISTORY
where season = 'Summer');
```
Fetch the top 5 athletes who have won the most golden medals
```sql
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
```

Finding the total gold, silver and bronze medals won by each country

```sql
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
```
