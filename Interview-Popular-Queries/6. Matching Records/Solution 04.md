### Using Self-Join with CASE (Double Round Robin)
```sql
SELECT 
    t1.team_code AS team1,
    t1.team_name AS team1_name,
    t2.team_code AS team2,
    t2.team_name AS team2_name,
    CASE WHEN t1.team_code < t2.team_code THEN 'Home' ELSE 'Away' END AS match_type
FROM 
    teams t1
JOIN 
    teams t2 ON t1.team_code != t2.team_code
ORDER BY 
    LEAST(t1.team_code, t2.team_code),
    GREATEST(t1.team_code, t2.team_code),
    match_type;
```

These queries will generate:
1. 45 matches (10 teams × 9 opponents / 2) for single round robin
2. 90 matches (45 × 2) for double round robin (home and away)

The key technique is using a self-join with appropriate join conditions to avoid:
- Teams playing against themselves
- Duplicate matches (e.g., RCB vs MI and MI vs RCB counting as the same match in single round robin)
