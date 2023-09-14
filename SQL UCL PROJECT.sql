--q1 top scorers
select top 10 first_name,last_name,position,nationality,count(*) as num_of_goals
from players p join goals g 
on p.player_id=g.PID
group by first_name,last_name,position,nationality
order by count(*) desc

--q2 top assits
select top 10 first_name,last_name,position,count(*) as num_of_assist
from players p join goals g 
on p.player_id=g.ASSIST
group by first_name,last_name,position
order by count(*) desc

--q3 num of goals per goal_desc
select GOAL_DESC,count(*) as num_of_goals
from goals
where GOAL_DESC is not null
group by GOAL_DESC
order by count(*) desc

--q4 biggest capacity
select top 5 name,team_name,capacity
from stadiums s left join teams t
on t.home_stadium=s.name
order by capacity desc

--q5 smallest capacity
select top 5 name,t.country,team_name,capacity
from stadiums s left join teams t
on t.home_stadium=s.name
order by capacity 

--q6 num of games per stadium,home_team
select stadium,home_team,count(*) as num_of_games
from matches
group by stadium,home_team
order by count(*) desc

--q7 percent of attendence from capacity
select  top 10 stadium,capacity,avg(attendance) as avg_attendance,round(avg(attendance*1.0)/(capacity)*100,2) as percent_of_attendance
from matches m join stadiums s
on m.stadium=s.name
where season not in ('2020-2021') and stadium not in ('stade de france') and stadium not in ('arena khimki')
group by stadium,capacity 
order by round(avg(attendance*1.0)/(capacity)*100,2) desc

--q8 goals in differnent parts of the game
with tab_cte as(
select *,case when duration<45 then 'first_half'
			when duration between 45 and 90 then 'second_half'
			else 'overtime'
			end as part_of_game
from goals)

select part_of_game,count(*) as count_of_parts
from tab_cte
group by part_of_game

--q9 wins per (home,away,draw)
with tab_cte1 as(
select *,case when HOME_TEAM_SCORE<AWAY_TEAM_SCORE then 'AWAY_TEAM'
			when  HOME_TEAM_SCORE>AWAY_TEAM_SCORE then 'HOME_TEAM'
			else  'DRAW'
			end as WINER_STATUS
from matches)

select WINER_STATUS,count(*) as WINS
from tab_cte1
group by WINER_STATUS
order by count(*) desc

--q10 wins per team
WITH tab_cte2 AS (
  SELECT *,
    CASE
      WHEN HOME_TEAM_SCORE > AWAY_TEAM_SCORE THEN HOME_TEAM
      WHEN HOME_TEAM_SCORE < AWAY_TEAM_SCORE THEN AWAY_TEAM
      ELSE 'DRAW'
    END AS WINNER_TEAM
  FROM matches
)

SELECT WINNER_TEAM, COUNT(*) AS WINS
FROM tab_cte2
WHERE WINNER_TEAM <> 'DRAW'
GROUP BY WINNER_TEAM
ORDER BY COUNT(*) DESC

--q11
WITH GoalCategory AS (
  SELECT GOAL_DESC, FIRST_NAME, LAST_NAME, COUNT(*) AS num_of_goals,
         RANK() OVER(PARTITION BY GOAL_DESC ORDER BY COUNT(*) DESC) AS goal_rank
  FROM goals g
  JOIN players p ON g.PID = p.PLAYER_ID
  WHERE GOAL_DESC IS NOT NULL
  GROUP BY GOAL_DESC, FIRST_NAME, LAST_NAME
)

SELECT GOAL_DESC, FIRST_NAME, LAST_NAME, num_of_goals
FROM GoalCategory
WHERE goal_rank = 1

--q12 num of players per nationality
select nationality,count(*) as num_of_players
from players 
group by nationality
order by count(*) desc

--q14 sum of goals per season
select season,sum(amount_of_goals) as sum_of_goals
from(
select *,(home_team_score+ away_team_score) as amount_of_goals
from matches) as tab1
group by season

--q15 the best scorer per season
select first_name,last_name,season,num_of_goals
from(
select first_name,last_name,season,count(*) as num_of_goals,
rank() over(partition by season order by count(*) desc) as ranking
from(
select *
from goals g join players p
on g.pid=p.player_id) as tab1 join matches m
on tab1.match_id=m.match_id
group by first_name,last_name,season
)as tab2
where ranking=1

--q16 Home success rate
WITH tab_cte2 AS (
  SELECT *,
    CASE
      WHEN HOME_TEAM_SCORE > AWAY_TEAM_SCORE THEN HOME_TEAM
      WHEN HOME_TEAM_SCORE < AWAY_TEAM_SCORE THEN AWAY_TEAM
      ELSE 'DRAW'
    END AS WINNER_TEAM
  FROM matches
)

SELECT  top 10 home_team,stadium,(count(case when winner_team=home_team then 1 end)*1.0 /COUNT(*)*100) AS WINS
FROM tab_cte2
GROUP BY home_TEAM,stadium
ORDER BY COUNT(*) DESC

--q17 goals per stadium
select stadium,sum(amount_of_goals) as sum_of_goals
from(
select *,(home_team_score+ away_team_score) as amount_of_goals
from matches) as tab1
group by stadium
order by sum_of_goals desc

--q18 goals per country
select country,sum(amount_of_goals) as sum_of_goals
from(
select *,(home_team_score+ away_team_score) as amount_of_goals
from matches m join teams t
on m.stadium=t.home_stadium) as tab1
group by country
order by sum_of_goals desc
