## 6. Spatial Data Functions
**Purpose:** Work with geographic and geometric data for applications like mapping or spatial analysis.

**Example (PostGIS for PostgreSQL):**
```sql
SELECT ST_AsText(geom) AS geometry
FROM spatial_table;
```
*This converts spatial geometry data into a human-readable text format.*