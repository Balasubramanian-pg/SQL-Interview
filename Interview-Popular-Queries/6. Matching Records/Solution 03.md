# Using CROSS JOIN with Filter (Single Round Robin)
```sql
SELECT 
    t1.team_code AS team1,
    t1.team_name AS team1_name,
    t2.team_code AS team2,
    t2.team_name AS team2_name
FROM 
    teams t1
CROSS JOIN 
    teams t2
WHERE 
    t1.team_code < t2.team_code
ORDER BY 
    t1.team_code, t2.team_code;
```
