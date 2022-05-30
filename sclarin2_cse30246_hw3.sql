/* SARA CLARIN
netid<sclarin2> 
Homework03 CSE 30426 */
 
/* Q1*/
SELECT SUM(attendance) from cfb_game_stats;

/* Q2*/
select down, count(down) as occurences from cfb_play where play_type='Penalty' group by down order by occurences desc limit 4;


/* Q3*/
SELECT denom.name, num.TotalReds / denom.TotalReds as successrate from
(select cfb_team.name, sum(red_zone_attempt) as TotalReds from cfb_drive, cfb_team where cfb_drive.team_id = cfb_team.team_id group by cfb_team.name having TotalReds >10) as denom,
(select cfb_team.name, sum(red_zone_attempt) as TotalReds from cfb_drive, cfb_team where cfb_drive.team_id = cfb_team.team_id and cfb_drive.end_reason = 'TOUCHDOWN' group by cfb_team.name having TotalReds >10) as num WHERE denom.name = num.name ORDER BY successrate desc limit 5;

/* Q4 */
SELECT cfb_conference.conference_id, cfb_conference.name, avg(duration)
FROM cfb_conference, cfb_game, cfb_game_stats, cfb_team
WHERE 
cfb_team.conference_id = cfb_conference.conference_id and 
cfb_game.game_id = cfb_game_stats.game_id  and 
(cfb_team.team_id = cfb_game.visit_team_id  or cfb_team.team_id = cfb_game.home_team_id)
GROUP BY cfb_conference.name, cfb_conference.conference_id
ORDER BY avg(duration) desc limit 1;


/* Q5*/

SELECT rush.first_name, rush.last_name, rush.player_id, (receiveyards + passyards + rushyards) as totalyards from  
(select first_name, last_name, sum(yards) as rushyards, cfb_rush.player_id from cfb_rush, cfb_game, cfb_player, cfb_play Where cfb_game.game_id = cfb_rush.game_id and cfb_player.player_id = cfb_rush.player_id and cfb_game.game_id = cfb_play.game_id and cfb_rush.first_down = TRUE and month(game_date)=10 Group by cfb_rush.player_id,first_name, last_name Order by rushyards) as rush, 
(select first_name, last_name, sum(yards) as passyards, cfb_pass.passer_player_id from cfb_pass, cfb_game, cfb_player, cfb_play Where cfb_game.game_id = cfb_pass.game_id and cfb_player.player_id = cfb_pass.passer_player_id and cfb_game.game_id = cfb_play.game_id and cfb_pass.first_down = TRUE and month(game_date)=10 group by cfb_pass.passer_player_id,first_name, last_name order by passyards) as pass,
(select first_name, last_name, sum(yards) as receiveyards, cfb_reception.player_id from cfb_reception, cfb_game, cfb_player, cfb_play Where cfb_game.game_id = cfb_reception.game_id and cfb_player.player_id = cfb_reception.player_id and cfb_game.game_id = cfb_play.game_id and cfb_reception.first_down = TRUE and month(game_date)=10 Group by cfb_reception.player_id,first_name, last_name Order by receiveyards) as reception
where reception.player_id = pass.passer_player_id and rush.player_id = reception.player_id
Order by totalyards desc limit 1;

/* Q6*/
select topstate as number,  homestate, topstate/totalND as percentage From 
(select count(*) as topstate, homestate, name, year from cfb_team, cfb_player where cfb_player.team_id = cfb_team.team_id and cfb_team.name = 'Notre Dame' and cfb_player.homestate is not NULL group by homestate, name, year order by topstate desc, year desc limit 1) as stat,
 (select count(*) as totalND, year from cfb_team, cfb_player where cfb_player.team_id = cfb_team.team_id and cfb_team.name = 'Notre Dame' and cfb_player.homestate is not NULL group by year order by year desc) as totalstat limit 1;

/* Q7 */
select count(*) as players from (select count(*) as playercount from cfb_player group by player_id having playercount >2 ) as thisplayer having count(*) > 2;

 /* Q8 */
Select name, yards, last_name, bestplayers.year, first_name from (select last_name, first_name, yards, cfb_player.team_id, year(game_date) as year 
From cfb_reception, cfb_play, cfb_game, cfb_player Where cfb_reception.player_id = cfb_player.player_id and cfb_reception.game_id = cfb_game.game_id and cfb_play.game_id = cfb_game.game_id and cfb_play.period=4 
 Group by last_name, first_name, yards, year, cfb_player.team_id
  Order by yards desc limit 100) as bestplayers, 
cfb_team
Where cfb_team.team_id = bestplayers.team_id
And yards >= ALL (select yards
From cfb_reception, cfb_play, cfb_game, cfb_player
 Where cfb_reception.player_id = cfb_player.player_id and cfb_reception.game_id = cfb_game.game_id and cfb_play.game_id = cfb_game.game_id and cfb_play.period=4
    )
Group by name, yards, last_name, first_name, bestplayers.year
Order by yards desc ;


/* Q9 */
SELECT name, year(game_date), sum(attendance)
from cfb_game, cfb_game_stats, cfb_team
WHERE cfb_game_stats.game_id = cfb_game.game_id and cfb_game.home_team_id = cfb_team.team_id and cfb_team.year = year(cfb_game.game_date)
GROUP BY year(game_date), name 
ORDER BY sum(attendance) desc limit 5;

