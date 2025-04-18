Here's the complete output:
Question:
Given two tables containing data about Facebook Pages and their respective likes, write a query to return the IDs of the Facebook pages that have zero likes. The output should be sorted in ascending order based on the page IDs.
Table Schema:
pages Table:
Column Name: page_id (integer)
Column Name: page_name (varchar)
page_likes Table:
Column Name: user_id (integer)
Column Name: page_id (integer)
Column Name: liked_date (datetime)
Example Input:
pages Table:
page_id: 20001, page_name: SQL Solutions
page_id: 20045, page_name: Brain Exercises
page_id: 20701, page_name: Tips for Data Analysts
page_likes Table:
user_id: 111, page_id: 20001, liked_date: 04/08/2022 00:00:00
user_id: 121, page_id: 20045, liked_date: 03/12/2022 00:00:00
user_id: 156, page_id: 20001, liked_date: 07/25/2022 00:00:00
Example Output:
page_id
20701
Approach/ Procedural Decomposition:
Identify the tables involved: pages and page_likes.
Determine the condition for a page to have zero likes: a page has zero likes if its page_id does not exist in the page_likes table.
Choose a suitable SQL method to find the page_ids that meet this condition: LEFT JOIN, NOT IN, or NOT EXISTS.
Sort the result in ascending order based on page_id.
Solution:
SQL
SELECT p.page_id
FROM pages p
LEFT JOIN page_likes pl
ON p.page_id = pl.page_id
WHERE pl.page_id IS NULL
ORDER BY p.page_id ASC;
Alternatively, you can use:
SQL
SELECT page_id
FROM pages
WHERE page_id NOT IN (SELECT page_id FROM page_likes)
ORDER BY page_id ASC;
Or:
SQL
SELECT p.page_id
FROM pages p
WHERE NOT EXISTS (
  SELECT 1
  FROM page_likes pl
  WHERE pl.page_id = p.page_id
)
ORDER BY p.page_id ASC;
Explanation of Solution Proposed:
The solution uses one of three methods to find the page_ids with zero likes:
LEFT JOIN: Joins the pages table with the page_likes table on page_id. If a page has no likes, the page_id will be NULL in the page_likes table, so we select page_ids where pl.page_id IS NULL.
NOT IN: Selects page_ids from the pages table where the page_id does not exist in the page_likes table.
NOT EXISTS: Selects page_ids from the pages table where there does not exist a row in the page_likes table with the same page_id.
In all cases, the result is sorted in ascending order based on page_id.
Meta AI response: Here's the complete output: Question: Given two tables containing data about Facebook Pages and their respective likes, write a query to return the IDs of the Facebook pages that have zero likes. The output should be sorted in ascending order based on the page IDs. Table Schema: pages Table: Column Name: page_id (integer) Column Name: page_name (varchar) page_likes Table: Column Name: user_id (integer) Column Name: page_id (integer) Column Name: liked_date (datetime) Example Input: pages Table: page_id: 20001, page_name: SQL Solutions page_id: 20045, page_name: Brain Exercises page_id: 20701, page_name: Tips for Data Analysts page_likes Table: user_id: 111, page_id: 20001, liked_date: 04/08/2022 00:00:00 user_id: 121, page_id: 20045, liked_date: 03/12/2022 00:00:00 user_id: 156, page_id: 20001, liked_date: 07/25/2022 00:00:00 Example Output: page_id 20701 Approach/ Procedural Decomposition: Identify the tables involved: pages and page_likes. Determine the condition for a page to have zero likes: a page has zero likes if its page_id does not exist in the page_likes table. Choose a suitable SQL method to find the page_ids that meet this condition: LEFT JOIN, NOT IN, or NOT EXISTS. Sort the result in ascending order based on page_id. Solution: SELECT p.page_id FROM pages p LEFT JOIN page_likes pl ON p.page_id = pl.page_id WHERE pl.page_id IS NULL ORDER BY p.page_id ASC; Alternatively, you can use: SELECT page_id FROM pages WHERE page_id NOT IN (SELECT page_id FROM page_likes) ORDER BY page_id ASC; Or: SELECT p.page_id FROM pages p WHERE NOT EXISTS ( SELECT 1 FROM page_likes pl WHERE pl.page_id = p.page_id ) ORDER BY p.page_id ASC; Explanation of Solution Proposed: The solution uses one of three methods to find the page_ids with zero likes: LEFT JOIN: Joins the pages table with the page_likes table on page_id. If a page has no likes, the page_id will be NULL in the page_likes table, so we select page_ids where pl.page_id IS NULL. NOT IN: Selects page_ids from the pages table where the page_id does not exist in the page_likes table. NOT EXISTS: Selects page_ids from the pages table where there does not exist a row in the page_likes table with the same page_id. In all cases, the result is sorted in ascending order based on page_id.
