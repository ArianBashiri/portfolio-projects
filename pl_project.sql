Select *
From pl.pl_results


-- checking to see if all records were imported

SELECT Count(*), season
FROM pl.pl_results
GROUP BY season
order by season

-- finding one missing record

SELECT DISTINCT away_team
FROM pl.pl_results
WHERE home_team = 'Brentford' AND season = '2021-22'

-- deleting records and importing again
DELETE FROM pl.pl_results WHERE season = '1992-93'

-- changing empty strings to null values
UPDATE pl.pl_results SET HTHG = NULL WHERE HTHG = '';
UPDATE pl.pl_results SET HTR = NULL WHERE HTR = '';
UPDATE pl.pl_results SET HTAG = NULL WHERE HTAG = '';
UPDATE pl.pl_results SET Referee = NULL WHERE Referee = '';
UPDATE pl.pl_results SET HS = NULL WHERE HS = '';
UPDATE pl.pl_results SET AS_ = NULL WHERE AS_  = '';
UPDATE pl.pl_results SET HST = NULL WHERE HST = '';
UPDATE pl.pl_results SET AST = NULL WHERE AST = '';
UPDATE pl.pl_results SET HC = NULL WHERE HC = '';
UPDATE pl.pl_results SET AC = NULL WHERE AC = '';
UPDATE pl.pl_results SET HF = NULL WHERE HF = '';
UPDATE pl.pl_results SET AF = NULL WHERE AF = '';
UPDATE pl.pl_results SET HY = NULL WHERE HY = '';
UPDATE pl.pl_results SET AY = NULL WHERE AY = '';
UPDATE pl.pl_results SET HR = NULL WHERE HR = '';
UPDATE pl.pl_results SET AR = NULL WHERE AR = '';

-- locating wrong data (after checking excel sheet)
Select HTAG, HTR
From pl.pl_results
WHERE home_team = 'Aston Villa' and away_team = 'Liverpool' and season = '2021-22'

-- updating data
UPDATE pl.pl_results SET HTAG = 1, HTR = 'D'
WHERE home_team = 'Aston Villa' and away_team = 'Liverpool' and season = '2021-22'

-- changing datatypes
ALTER TABLE `PL`.`pl_results` 
CHANGE COLUMN `Date` `Date` DATE NULL DEFAULT NULL,
CHANGE COLUMN `HTHG` `HTHG` INT NULL DEFAULT NULL,
CHANGE COLUMN `HTAG` `HTAG` INT NULL DEFAULT NULL,
CHANGE COLUMN `HS` `HS` INT NULL DEFAULT NULL,
CHANGE COLUMN `AS_` `AS_` INT NULL DEFAULT NULL,
CHANGE COLUMN `HST` `HST` INT NULL DEFAULT NULL,
CHANGE COLUMN `AST` `AST` INT NULL DEFAULT NULL,
CHANGE COLUMN `HC` `HC` INT NULL DEFAULT NULL,
CHANGE COLUMN `AC` `AC` INT NULL DEFAULT NULL,
CHANGE COLUMN `HF` `HF` INT NULL DEFAULT NULL,
CHANGE COLUMN `AF` `AF` INT NULL DEFAULT NULL,
CHANGE COLUMN `HY` `HY` INT NULL DEFAULT NULL,
CHANGE COLUMN `AY` `AY` INT NULL DEFAULT NULL,
CHANGE COLUMN `HR` `HR` INT NULL DEFAULT NULL,
CHANGE COLUMN `AR` `AR` INT NULL DEFAULT NULL;

-- Participation of every team in PL throughout history
SELECT DISTINCT home_team as team, count(DISTINCT season) as number_of_seasons
From pl.pl_results
GROUP BY home_team
ORDER BY number_of_seasons DESC


-- Record of home wins for each team
Create view pl.hw as
SELECT count(FTR) as home_wins, home_team as team
FROM pl.pl_results
WHERE FTR = 'H'
GROUP BY team
Order BY home_wins DESC

-- Record of away wins for each team
Create view pl.aw as
SELECT count(FTR) as away_wins, away_team as team
FROM pl.pl_results
WHERE FTR = 'A'
GROUP BY team
Order BY away_wins DESC

-- Total wins for each team
Select (hw.home_wins + aw.away_wins) as total_wins, hw.team
From pl.hw as hw
Join pl.aw as aw
on hw.team = aw.team
Group by team
Order by total_wins DESC

-- Total goals scored at home by each team
Create view pl.tgsh as
SELECT SUM(FTHG) as home_goals, home_team as team
FROM pl.pl_results
GROUP BY team
ORDER BY home_goals DESC

-- Total goals scored away by each team
Create view pl.tgsa as
SELECT SUM(FTAG) as away_goals, away_team as team
FROM pl.pl_results
GROUP BY team
ORDER BY away_goals DESC

-- Total goals scored by each team
Select tgsh.home_goals + tgsa.away_goals as total_goals, tgsh.team
From pl.tgsh as tgsh
Join pl.tgsa as tgsa
on tgsh.team = tgsa.team
Group by team
Order by total_goals DESC

-- Total goals conceded at home by each team 
Create view pl.tgch as
SELECT SUM(FTAG) as goals_conceded, home_team as team
FROM pl.pl_results
GROUP BY team
ORDER BY goals_conceded DESC

-- Total goals conceded away by each team 
Create view pl.tgca as
Select SUM(FTHG) as goals_conceded, away_team as team
From pl.pl_results
Group by team
Order by goals_conceded DESC

-- Total goals conceded by each team
Select tgch.goals_conceded + tgca.goals_conceded as goals_conceded, tgch.team
From pl.tgch as tgch
Join pl.tgca as tgca
on tgch.team = tgca.team
Group by team
Order by goals_conceded DESC

-- Goal-scoring teams at home by season
CREATE VIEW pl.gsh as
SELECT SUM(FTHG) as goals_scored, home_team as team, season
FROM pl.pl_results
GROUP BY team, season
ORDER BY goals_scored DESC, season

-- Goal-scoring teams away by season
CREATE VIEW pl.gsa as
SELECT SUM(FTAG) as goals_scored, away_team as team, season
FROM pl.pl_results
GROUP BY team, season
ORDER BY goals_scored DESC, season

-- Goal-conceding teams at home by season
CREATE VIEW pl.GCH as
SELECT SUM(FTHG) as goals_conceded, away_team as team, season
FROM pl.pl_results
GROUP BY team, season
ORDER BY goals_conceded DESC, season

-- Goal-conceding teams away by season
Create view pl.GCA as
Select SUM(FTAG) as goals_conceded, home_team as team, season
From pl.pl_results
Group by team, season
Order by goals_conceded DESC, season

-- Total goal-scoring team by season
Select gsh.goals_scored + gsa.goals_scored as total_goals_scored, gsh.team, gsh.season
From pl.gsh as gsh
Join pl.gsa as gsa
on gsh.team = gsa.team and gsh.season = gsa.season
Group by gsh.team, gsh.season
Order by total_goals_scored DESC

-- Total goal-conceding team by season
Select gch.goals_conceded + gca.goals_conceded as total_goals_conceded, gch.team, gch.season
From pl.gch as gch
Join pl.gca as gca
on gch.team = gca.team and gch.season = gca.season
Group by gch.team, gch.season
Order by total_goals_conceded DESC


-- Referees total games in charge (from 2000/01 - 2021/22 season)
Select count(referee) as games, referee, min(season) as first_season, max(season) as last_season
From pl.pl_results
Where referee is not null
Group by referee
Order by games DESC

-- Referees games in charge each season (from 2001/01 - 2021/22 season)
Select season, referee, count(referee) as games
From pl.pl_results
Where referee is not null
Group by season, referee
Order by season, games DESC, referee


-- Finding and correcting errors in the list of referee names
Select DISTINCT referee
from pl.pl_results
where referee like '%D e%' 

Update pl.pl_results
Set referee = 'N Yates'
Where referee like '%yates%'

Update pl.pl_results
Set referee = 'R Burton'
Where referee like '%burton%'

Update pl.pl_results
Set referee = 'A Hall'
Where referee like '%hall%'

Update pl.pl_results
Set referee = 'P Dowd'
Where referee like '%dowd%'

Update pl.pl_results
Set referee = 'C Foy'
Where referee like '%foy%'

Update pl.pl_results
Set referee = 'M Messias'
Where referee like '%messias%'

Update pl.pl_results
Set referee = 'D Pugh'
Where referee like '%pugh%'

Update pl.pl_results
Set referee = 'C Wilkes'
Where referee like '%wilkes%'

Update pl.pl_results
Set referee = 'E Wolstenholme'
Where referee like '%wolsten%'

Update pl.pl_results
Set referee = 'D Elleray'
Where referee like '%ell%' and referee not like '%attwell%'

Update pl.pl_results
Set referee = 'U Rennie'
Where referee like '%rennie%'

Update pl.pl_results
Set referee = 'P Taylor'
Where referee like '%paul taylor%'

Update pl.pl_results
Set referee = 'I Harris'
Where referee like '%ian Harris%'

Update pl.pl_results
Set referee = 'R Harris'
Where referee like '%Rob Harris%'

Update pl.pl_results
Set referee = 'P Jones'
Where referee like '%jones%' and not (referee = 'm jones' or referee = 'r jones')

Update pl.pl_results
Set referee = 'M Halsey'
Where referee like '%halsey%'

Update pl.pl_results
Set referee = 'B Knight'
Where referee like '%knight%'

Update pl.pl_results
Set referee = 'N Barry'
Where referee like '%barry%' and referee not like '%barry knight%'

Update pl.pl_results
Set referee = 'S Bennet'
Where referee like '%bennet%'

Update pl.pl_results
Set referee = 'R Styles'
Where referee like '%styles%' 

Update pl.pl_results
Set referee = 'M Dean'
Where referee like '%dean%' 

Update pl.pl_results
Set referee = 'S Lodge'
Where referee like '%lodge%' 

Update pl.pl_results
Set referee = 'S Dunn'
Where referee like '%dunn%' 

Update pl.pl_results
Set referee = 'M Riley'
Where referee like '%riley%' 

Update pl.pl_results
Set referee = "A D'Urso"
Where referee like '%urso%' 

Update pl.pl_results
Set referee = 'G Barber'
Where referee like '%barber%' 

Update pl.pl_results
Set referee = 'P Durkin'
Where referee like '%durkin%' 

Update pl.pl_results
Set referee = 'G Poll'
Where referee like '%poll%' 

Update pl.pl_results
Set referee = 'D Gallagher'
Where referee like '%galla%' 

Update pl.pl_results
Set referee = 'J Moss'
Where referee like '%moss%' 

Update pl.pl_results
Set referee = 'J Winter'
Where referee like '%winter%'

Update pl.pl_results
Set referee = 'A Wiley'
Where referee like '%wiley%'

Update pl.pl_results
Set referee = 'M Atkinson'
Where referee like '%atkinson%'

-- Games with the highest amount of yellow cards being showed
Select season, date, home_team, away_team, HY + AY as total_y
From pl.pl_results
Order by total_y DESC

-- Games with the highest amount of red cards being showed
Select season, date, home_team, away_team, HR + AR as total_r
From pl.pl_results
Order by total_r DESC

-- Games with the highest amount of cards being showed
Select season, date, home_team, away_team, HY + AY as total_y, HR + AR as total_r, HY + AY + HR + AR as total_cards
From pl.pl_results
Order by total_cards DESC, total_r DESC











