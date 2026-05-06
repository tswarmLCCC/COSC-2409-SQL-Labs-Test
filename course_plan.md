# **COSC 2409: Relational Data Engineering (8-Unit Intensive)**

This course is an intensive sprint through enterprise PostgreSQL. We use the **Neon PostgreSQL Tutorial** as the primary technical anchor and the LCCC "Eagle AI" Nutanix cluster for production-level labs.

**Primary Resource:** [Neon PostgreSQL Tutorial](https://neon.com/postgresql/tutorial)


**Environment:** GitHub Codespaces & [FreeCodeCamp.org - Learn PostgreSQL Tutorial - Full Course for Beginners](https://www.youtube.com/watch?v=qw--VYLpxG4)

## **Course Philosophy: The "AI Practitioner" Model**

Based on industry feedback, this course moves away from legacy "office productivity" database training. We are training **AI Practitioners**—the engineers who build and maintain the data "plumbing" that powers modern AI.

* **The Hook:** AI won't take your job, but someone who knows how to use AI will.  
* **The Core Principle:** "Human in the Loop." AI is an augmentation tool; the database is its factual grounding.

## **Unit 1: Selection & Fundamentals**

**Theme:** Retrieval, Relational Theory, & The AI Context.

* **Required Neon Readings:**  
  * [PostgreSQL Tutorial](https://neon.com/postgresql/tutorial/) (Introduction)  
  * [SELECT](https://neon.com/postgresql/tutorial/postgresql-select/)  
  * [ORDER BY](https://neon.com/postgresql/tutorial/postgresql-order-by/)  
  * [SELECT DISTINCT](https://neon.com/postgresql/tutorial/postgresql-select-distinct/)  
  * [PostgreSQL Syntax](https://neon.com/postgresql/tutorial/postgresql-syntax/)  
* **Reference Reading (Official PostgreSQL Docs):**  
  * [The SELECT Statement](https://www.postgresql.org/docs/current/sql-select.html)  
  * [Sorting Rows (ORDER BY)](https://www.postgresql.org/docs/current/queries-order.html)  
  * [The DISTINCT Clause](https://www.postgresql.org/docs/current/queries-select-lists.html#QUERIES-DISTINCT)  
* **Technical Focus:** *Introduction to Postgres, Relational Algebra basics, SELECT, ORDER BY, SELECT DISTINCT, GitHub Codespaces Setup.*  
* **Detailed Competencies:**  
  * **AI Data Grounding:** Understand the role of structured databases in Retrieval-Augmented Generation (RAG). Learn why AI models require "grounding" in a database to prevent hallucinations and provide factual, real-time responses.  
  * **Structured vs. Unstructured:** Distinguish between the unstructured data used to train LLMs and the structured relational data used to run businesses.  
  * **Relational Algebra:** Master the mathematical foundations of data selection—Projection, Selection, and Renaming—before writing SQL.  
  * **Cloud-Based Development:** Launch and configure a **GitHub Codespaces** instance. Understand how to manage a browser-based VS Code environment pre-configured with a PostgreSQL client.  
  * **Client Connectivity:** Establish secure connections to the Eagle AI Nutanix cluster from within the GitHub Codespace environment using both CLI (psql) and the VS Code SQL extension.  
  * **Syntax Order of Operations:** Understand that the database processes queries in a different order than they are written (FROM → SELECT → ORDER BY).  
* **Bonus: Practical Applications**  
  * **AI Chatbot Knowledge Base:** Use SELECT DISTINCT to pull unique category labels from a dataset to build a "quick-reply" menu for a campus navigation bot.  
  * **Automated Data Auditing:** Write basic select scripts that run periodically to find empty or improperly formatted rows in an intake spreadsheet.  
* **Assignment:** 1\. Initialize your personal **GitHub Codespace**. 2\. Connect to the Eagle AI database and generate a list of all unique departments. 3\. Write a reflection on how this data could be used to "ground" a campus chatbot and the ethical implications of automated data collection.

## **Unit 2: Advanced Filtering & Logic**

**Theme:** Data Slicing, Three-Valued Logic, and Expressions.

* **Required Neon Readings:**  
  * [WHERE](https://neon.com/postgresql/tutorial/postgresql-where/)  
  * [LIMIT](https://neon.com/postgresql/tutorial/postgresql-limit/)  
  * [FETCH](https://neon.com/postgresql/tutorial/postgresql-fetch/)  
  * [IN](https://neon.com/postgresql/tutorial/postgresql-in/)  
  * [BETWEEN](https://neon.com/postgresql/tutorial/postgresql-between/)  
  * [LIKE](https://neon.com/postgresql/tutorial/postgresql-like/)  
  * [IS NULL](https://neon.com/postgresql/tutorial/postgresql-is-null/)  
  * [PostgreSQL Expressions](https://neon.com/postgresql/tutorial/postgresql-expressions/)  
  * [Column Aliases](https://neon.com/postgresql/tutorial/postgresql-alias/)  
* **Reference Reading (Official PostgreSQL Docs):**  
  * [The WHERE Clause](https://www.postgresql.org/docs/current/queries-where.html)  
  * [LIMIT and OFFSET](https://www.postgresql.org/docs/current/queries-limit.html)  
  * [Comparison Functions and Operators](https://www.postgresql.org/docs/current/functions-comparisons.html)  
  * [Pattern Matching](https://www.postgresql.org/docs/current/functions-matching.html)  
  * [Value Expressions](https://www.postgresql.org/docs/current/sql-expressions.html)  
* **Technical Focus:** *WHERE, LIMIT, FETCH, IN, BETWEEN, LIKE, IS NULL, Expressions.*  
* **Detailed Competencies:**  
  * **Predicate Logic:** Constructing complex filter conditions using AND, OR, and NOT operators.  
  * **Three-Valued Logic:** Mastering how NULL impacts boolean comparisons (True, False, Unknown).  
  * **Scalar Expressions:** Using the database as a calculator. Performing mathematical operations (+, \-, \*, /, %) within queries.  
  * **String & Logical Expressions:** Concatenating strings (using ||), manipulating text, and using logical expressions to derive new values on the fly.  
  * **Column Aliasing (AS):** Assigning meaningful names to expressions and "virtual columns" to ensure data is self-documenting for human analysts and AI agents.  
* **Bonus: Practical Applications**  
  * **Dynamic Pricing Tools:** Create an expression that automatically calculates a 10% "early bird" discount for students who register before a certain date.  
  * **Security Log Analysis:** Use LIKE and NOT IN to filter through thousands of server access logs to find suspicious activity patterns from unauthorized IP addresses.  
* **Assignment:** The "Census Audit." Use the Wyoming census dataset to identify specific demographic segments. Create a virtual column "Estimated Tax" using expressions and alias your headers for a professional report.

## **Unit 3: Mastering the Join**

**Theme:** Relational Interconnectivity.

* **Required Neon Readings:**  
  * [PostgreSQL Joins](https://neon.com/postgresql/tutorial/postgresql-joins/)  
  * [INNER JOIN](https://neon.com/postgresql/tutorial/postgresql-inner-join/)  
  * [LEFT JOIN](https://neon.com/postgresql/tutorial/postgresql-left-join/)  
  * [RIGHT JOIN](https://neon.com/postgresql/tutorial/postgresql-right-join/)  
  * [FULL OUTER JOIN](https://neon.com/postgresql/tutorial/postgresql-full-outer-join/)  
  * [Table Aliases](https://neon.com/postgresql/tutorial/postgresql-table-alias/)  
* **Reference Reading (Official PostgreSQL Docs):**  
  * [Joined Tables](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-JOIN)  
  * [Join Expressions](https://www.postgresql.org/docs/current/sql-select.html#SQL-FROM)  
* **Technical Focus:** *INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL OUTER JOIN, SELF JOIN, CROSS JOIN.*  
* **Detailed Competencies:**  
  * **Join Mechanics:** Understand how the join engine uses equality to narrow results.  
  * **Relational Mapping:** Distinguish between 1:1, 1:N, and N:M relationships and how to navigate them.  
  * **Handling Missing Relations:** Using Outer Joins to find data that *doesn't* exist in a related table (e.g., finding students who haven't paid fees).  
  * **Self-Referential Logic:** Using Self-Joins to query hierarchical data (e.g., finding a student's advisor who is also a student).  
* **Bonus: Practical Applications**  
  * **CRM Consolidation:** Join a "Sales" table with a "Customer Support" table to build a 360-degree customer profile for a marketing AI to analyze.  
  * **Academic Audit Bot:** Compare a "Student Course History" table against a "Degree Requirements" table using a LEFT JOIN to identify exactly which classes a student still needs to graduate.  
* **Assignment:** Build a "Unified Student View." Connect five tables (Profiles, Financials, Courses, Enrollment, and Grades) into a single query that flags students at risk of losing aid based on attendance and grades.

## **Unit 4: Grouping, Set Operations & Pivoting**

**Theme:** Analytical Reporting & Feature Engineering.

* **Required Neon Readings:**  
  * [GROUP BY](https://neon.com/postgresql/tutorial/postgresql-group-by/)  
  * [HAVING](https://neon.com/postgresql/tutorial/postgresql-having/)  
  * [UNION](https://neon.com/postgresql/tutorial/postgresql-union/)  
  * [INTERSECT](https://neon.com/postgresql/tutorial/postgresql-intersect/)  
  * [EXCEPT](https://neon.com/postgresql/tutorial/postgresql-except/)  
  * [Aggregate Functions](https://neon.com/postgresql/tutorial/postgresql-aggregate-functions/)  
* **Reference Reading (Official PostgreSQL Docs):**  
  * [GROUP BY and HAVING](https://www.postgresql.org/docs/current/queries-group.html)  
  * [Combining Queries (UNION, INTERSECT, EXCEPT)](https://www.postgresql.org/docs/current/queries-union.html)  
  * [Aggregate Functions Reference](https://www.postgresql.org/docs/current/functions-aggregate.html)  
* **Technical Focus:** *GROUP BY, HAVING, UNION, INTERSECT, EXCEPT, CASE-Based Pivoting.*  
* **Detailed Competencies:**  
  * **Aggregation Logic:** Using SUM, AVG, COUNT to reduce datasets into metrics.  
  * **Long-to-Wide Transformations (Pivoting):** Using conditional aggregation (SUM(CASE WHEN...)) to flip row-based data into column-based features for machine learning models.  
  * **Manual Query Tracing:** Reading a query and manually calculating the intermediate results to verify logic before execution.  
* **Bonus: Practical Applications**  
  * **Financial Trend Graphing:** Pivot monthly sales data into a "Wide" format so it can be passed into a Python graphing library (like Matplotlib) for an executive slide deck.  
  * **ML Feature Engineering:** Transform a student's transactional log of "Logins," "Library Visits," and "Assignment Submissions" into a single row of numeric features used to train a student-success prediction model.  
* **Assignment:** Create a "Student Success Pivot." Pivot a student's semester-by-semester GPA into a single row with columns for specific academic years. Before running, manually trace 5 students to predict the final wide-format output.

## **Unit 5: Data Modification & Transactions**

**Theme:** Data Integrity and State Management.

* **Required Neon Readings:**  
  * [INSERT](https://neon.com/postgresql/tutorial/postgresql-insert/)  
  * [UPDATE](https://neon.com/postgresql/tutorial/postgresql-update/)  
  * [DELETE](https://neon.com/postgresql/tutorial/postgresql-delete/)  
  * [UPSERT](https://neon.com/postgresql/tutorial/postgresql-upsert/)  
  * [Transactions](https://neon.com/postgresql/tutorial/postgresql-transaction/)  
* **Reference Reading (Official PostgreSQL Docs):**  
  * [Data Manipulation (INSERT/UPDATE/DELETE)](https://www.postgresql.org/docs/current/dml.html)  
  * [Transactions (Tutorial)](https://www.postgresql.org/docs/current/tutorial-transactions.html)  
  * [The COMMIT Statement](https://www.postgresql.org/docs/current/sql-commit.html)  
  * [The ROLLBACK Statement](https://www.postgresql.org/docs/current/sql-rollback.html)  
  * [SET TRANSACTION (Isolation Levels)](https://www.postgresql.org/docs/current/sql-set-transaction.html)  
* **Technical Focus:** *INSERT, UPDATE, DELETE, UPSERT, BEGIN, COMMIT, ROLLBACK.*  
* **Detailed Competencies:**  
  * **Upsert Patterns:** Using ON CONFLICT to handle high-volume data ingestion.  
  * **ACID Compliance:** Understanding Atomicity, Consistency, Isolation, and Durability in transaction management.  
  * **Transaction Guarding:** Using Rollbacks to revert changes when a multi-step process fails in the middle.  
* **Bonus: Practical Applications**  
  * **Inventory Reservation System:** Build a transaction that ensures a product is "subtracted" from inventory only if a credit card record is successfully "added" to the sales table.  
  * **User Onboarding Workflow:** Use an UPSERT to handle new user registration while simultaneously updating the "Last Login" timestamp for returning users in one efficient step.  
* **Assignment:** Simulate a high-stakes registration period. Script a transaction where a student is enrolled, a seat count is decremented, and a billing record is created—all or nothing.

## **Unit 6: Modularity, Window Functions & CTEs**

**Theme:** Advanced Analytical Engineering.

* **Required Neon Readings:**  
  * [Subquery](https://neon.com/postgresql/tutorial/postgresql-subquery/)  
  * [Common Table Expression (CTE)](https://neon.com/postgresql/tutorial/postgresql-cte/)  
  * [Recursive CTE](https://neon.com/postgresql/tutorial/postgresql-recursive-cte/)  
  * [Window Functions](https://neon.com/postgresql/tutorial/postgresql-window-function/)  
* **Reference Reading (Official PostgreSQL Docs):**  
  * [WITH Queries (CTEs)](https://www.postgresql.org/docs/current/queries-with.html)  
  * [Window Functions (Tutorial)](https://www.postgresql.org/docs/current/tutorial-window.html)  
  * [Built-in Window Functions List](https://www.postgresql.org/docs/current/functions-window.html)  
* **Technical Focus:** *Subquery, CTE, Recursive CTE, Window Functions (OVER, PARTITION BY).*  
* **Detailed Competencies:**  
  * **Windowing Mechanics:** Performing calculations across rows without collapsing them (unlike GROUP BY).  
  * **Analytical Ranking:** Implementing RANK(), DENSE\_RANK(), and ROW\_NUMBER() to create leaderboards and identify top-tier records.  
  * **Sequential Navigation:** Using LEAD() and LAG() to calculate growth rates or delta changes between events.  
  * **Recursive Logic:** Traversing tree structures like org charts or prerequisite paths.  
* **Bonus: Practical Applications**  
  * **Year-over-Year (YoY) Performance:** Use LAG() to build a report showing a business's monthly revenue compared directly to the same month from the previous year.  
  * **Interactive Org-Chart Visualization:** Use a Recursive CTE to generate a JSON hierarchy for a web-based organizational chart tool.  
* **Assignment:** 1\. Refactor a messy query into CTEs. 2\. Build a leaderboard using window functions. 3\. Use LAG() to calculate enrollment changes over three semesters.

## **Unit 7: Schema Design & Data Integrity**

**Theme:** Database Architecture & Data Lineage.

* **Required Neon Readings:**  
  * [CREATE TABLE](https://neon.com/postgresql/tutorial/postgresql-create-table/)  
  * [ALTER TABLE](https://neon.com/postgresql/tutorial/postgresql-alter-table/)  
  * [Data Types](https://neon.com/postgresql/tutorial/postgresql-data-types/)  
  * [Constraints (PK, FK, Check, Unique, Not Null)](https://neon.com/postgresql/tutorial/postgresql-primary-key/)  
* **Reference Reading (Official PostgreSQL Docs):**  
  * [Data Definition Basics](https://www.postgresql.org/docs/current/ddl-basics.html)  
  * [Constraints](https://www.postgresql.org/docs/current/ddl-constraints.html)  
  * [PostgreSQL Data Types](https://www.postgresql.org/docs/current/datatype.html)  
  * [COMMENT (Metadata/Lineage)](https://www.postgresql.org/docs/current/sql-comment.html)  
* **Technical Focus:** *CREATE TABLE, ALTER TABLE, Data Types, Constraints.*  
* **Detailed Competencies:**  
  * **Data Modeling:** Designing tables with correct types (JSONB vs. Text).  
  * **Data Lineage:** Learn to document and enforce data source tracking. Use COMMENT to prove *where* data came from so AI outputs can be audited for compliance.  
  * **Specialized Design: Dimensional Modeling Concepts:**  
    * **Dimension Tables:** Context (who, what, where, when, why).  
    * **Fact Tables:** Quantitative measurements (metrics) of a business process.  
    * **Factless Fact Tables:** Tracking events without numeric measures (e.g., attendance logs).  
    * **Coverage Tables:** Ensuring all dimension combinations are accounted for.  
    * **Slowly Changing Dimensions (SCD):** Mastering **SCD Type 2** for historical accuracy.  
  * **Historical Integrity:** Implementing SCD logic to ensure the database can "time travel" to show data as it existed on a specific date.  
* **Bonus: Practical Applications**  
  * **Healthcare Record Auditing:** Design a schema that uses CHECK constraints to ensure patient vitals are within biologically possible ranges.  
  * **Historical Price Tracking:** Implement SCD Type 2 for an e-commerce catalog so you can track price changes over time.  
* **Assignment:** Build a "Career Services" database. Implement SCD Type 2 logic and define at least one Fact and one Dimension table.

## **Unit 8: Performance, Indexing & FinOps**

**Theme:** Optimization, Professional Delivery, & Cloud Costs.

* **Required Neon Readings:**  
  * [PostgreSQL Views](https://neon.com/postgresql/tutorial/postgresql-views/)  
  * [Materialized Views](https://neon.com/postgresql/tutorial/postgresql-materialized-views/)  
  * [PostgreSQL Indexes](https://neon.com/postgresql/tutorial/postgresql-indexes/)  
  * [EXPLAIN](https://neon.com/postgresql/tutorial/postgresql-explain/)  
  * [Triggers](https://neon.com/postgresql/tutorial/postgresql-triggers/)  
* **Reference Reading (Official PostgreSQL Docs):**  
  * [The CREATE VIEW Statement](https://www.postgresql.org/docs/current/sql-createview.html)  
  * [Indexes](https://www.postgresql.org/docs/current/indexes.html)  
  * [Using EXPLAIN](https://www.postgresql.org/docs/current/using-explain.html)  
  * [Trigger Implementation](https://www.postgresql.org/docs/current/triggers.html)  
* **Technical Focus:** *Views, Materialized Views, Indexes, EXPLAIN ANALYZE, Triggers, FinOps Principles.*  
* **Detailed Competencies:**  
  * **Query Plan Analysis:** Using EXPLAIN ANALYZE to read the engine's "mind" and find slow sequential scans.  
  * **FinOps (Cloud Cost Management):** Understand that in the cloud, time is money. Learn how to calculate the cost of a query and optimize SQL to reduce compute charges.  
  * **Indexing Strategy:** Using B-Tree and Hash indexes to turn minute-long queries into milliseconds.  
  * **Automation:** Using Triggers to automatically log every change to a sensitive table (Auditing).  
* **Bonus: Practical Applications**  
  * **E-commerce Search Optimization:** Take a search query that takes 10 seconds and use a GIN index on a JSONB column to make it feel instantaneous for the customer.  
  * **Automated Audit Logs:** Create a trigger that automatically copies a record into an "Archive" table every time a grade is changed, ensuring a permanent audit trail.  
* **Assignment (Final Capstone):** The "LCCC Analytical Engine." Diagnose a slow query via an execution plan, apply indexes, and build an automated audit trail. Include a "Cost Analysis" comparing the original query expense to the optimized version.

## **Appendix A: Potential Improvements & Considerations**

1. **Full-Text Search (FTS):** Bridge the gap to semantic search using tsvector.  
2. **Semi-Structured Data (JSONB):** Deep dive into GIN indexes for AI outputs.  
3. **AI Metadata Strategy:** LLM-friendly table comments (Data Cataloging).

## **Appendix B: Support & OER**

* **Documentation:** [Neon PostgreSQL Tutorial](https://neon.com/postgresql/tutorial)  
* **Theory:** *Database Design – 2nd Edition* (Adrienne Watt)  
* **Logic Review:** [SQL Murder Mystery](https://mystery.knightlab.com/)  
* **Environment:** GitHub Codespaces & Nutanix "Eagle AI".

## **Appendix F: Development Environment History (GitHub Codespaces)**

**Record of Infrastructure Strategy:**

* **Transition Rationale:** Moved from local lab-only environments to GitHub Codespaces in Unit 1 to solve "environment drift" and ensure an identical, cloud-native development stack.  
* **Technical Configuration:**  
  * **Environment:** Containerized VS Code (Docker-based) via GitHub.  
  * **Pre-installed Tooling:** postgresql-client, VS Code SQL extensions, and Python psycopg2/SQLAlchemy libraries.  
  * **Persistence:** All student code is version-controlled via GitHub repositories, mirroring professional DataOps workflows.  
* **Database Connection:** Tunneling established from Codespaces to the LCCC Nutanix "Eagle AI" cluster, allowing students to operate as remote engineers accessing enterprise hardware.
