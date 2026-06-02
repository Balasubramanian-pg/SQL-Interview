### Key Patterns to Remember:
- **Consecutive Days**: Use `DATEDIFF` with offsets (e.g., `DATEDIFF(a.date, b.date) = 1`).
- **Time-Based Filtering**: `BETWEEN`, `DATE_SUB`, or `INTERVAL`.
- **Group by Time Units**: `DATE_FORMAT` for custom grouping (e.g., `%Y-%W` for week).
- **Date Validation**: Check `LAST_DAY` for month-end edge cases.

**Pro Tip**: Always handle `NULL` dates with `COALESCE` and validate date ranges (e.g., `BETWEEN` vs `>= AND <`).

