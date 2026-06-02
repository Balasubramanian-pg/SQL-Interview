
## 2. Each team plays every other team twice (Double Round Robin - Home & Away)

```sql
SELECT 
    t1.team_code AS team1,
    t1.team_name AS team1_name,
    t2.team_code AS team2,
    t2.team_name AS team2_name,
    'Home' AS match_type
FROM 
    teams t1
JOIN 
    teams t2 ON t1.team_code != t2.team_code
WHERE 
    t1.team_code < t2.team_code

UNION ALL

SELECT 
    t2.team_code AS team1,
    t2.team_name AS team1_name,
    t1.team_code AS team2,
    t1.team_name AS team2_name,
    'Away' AS match_type
FROM 
    teams t1
JOIN 
    teams t2 ON t1.team_code != t2.team_code
WHERE 
    t1.team_code < t2.team_code

ORDER BY 
    team1, team2, match_type;
```
