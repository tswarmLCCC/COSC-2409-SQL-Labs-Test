# **Unit 6: Modularity, Window Functions & CTEs**

## **Unit Overview & Objectives**

This unit marks your transition from being a "data retriever" to an **Analytical Engineer**. In previous units, you learned how to pull data; now, you will learn how to architect logic. We are moving away from monolithic, "one-shot" queries toward modular pipelines that are readable, maintainable, and mathematically sophisticated.

**Learning Objectives:**

* **Construct Modular Pipelines:** Understand why nested subqueries fail at scale and how to use Common Table Expressions (CTEs) to build procedural, step-by-step logic that mirrors human problem-solving.  
* **Master Windowing Mechanics:** Learn the "how" of the OVER() clause to perform calculations that require global context (like averages or sums) without losing individual row data.  
* **Execute Analytical Ranking:** Solve complex business problems like "identifying the top 3 customers per region" using ranking functions that handle ties and gaps correctly.  
* **Perform Sequential Navigation:** Use LEAD() and LAG() to bridge the gap between rows, allowing you to calculate growth rates and delta changes over time.  
* **Implement Recursive Logic:** Understand how to traverse "infinite" hierarchies, such as management chains or manufacturing parts lists, using Recursive CTEs and state-tracking.

## **The Problem: The Complexity Ceiling**

In basic SQL, your queries are simple enough to hold in your head all at once. However, as business requirements grow, you will hit a "Complexity Ceiling." Standard SQL provides two major points of failure:

### **1\. The "Nesting Tax" (Cognitive Load & Debugging)**

**The Problem:** When a query requires multiple layers of logic (e.g., "Find the average of a sum of a count"), developers often resort to nested subqueries.

**Why it fails:** SQL is technically evaluated "inside-out," but humans read "top-to-bottom." When you nest five subqueries deep, you create a "Subquery Pyramid." If a bug exists in the third layer, you have to mentally deconstruct the entire pyramid to find it. This leads to **Technical Debt**—code that works today but is impossible for a colleague (or your future self) to edit tomorrow.

**The Solution:** **CTEs**. We solve this by "naming" our logic blocks and defining them sequentially. This allows you to test each block individually before moving to the next.

### **2\. The "Aggregation Trade-off" (Data Loss)**

**The Problem:** The GROUP BY clause is "destructive."

**Why it fails:** If you want to see a student's test score *and* the class average in the same row, a standard GROUP BY cannot help you. It will collapse all the students into one row for the average, destroying the individual score data. Traditionally, you would have to run two separate queries and JOIN them back together—a process that is computationally expensive and logically verbose.

**The Solution:** **Window Functions**. We solve this by creating a "window" that looks at the rest of the data without collapsing the row you are currently standing on.

## **1\. Common Table Expressions (CTEs): The Procedural Shift**

A CTE is defined using the WITH keyword. It tells the SQL engine: "Run this logic first, call it 'X', and let me use 'X' for the rest of the query." This moves SQL away from a declarative "set" language toward a more procedural "pipeline" language.

### **How to Architect Modularity**

Instead of one giant query, we build a pipeline that handles abstraction. Each layer handles one specific business rule. Crucially, we use **Debugging Checkpoints**: instead of running the whole query, you can stop at any layer and SELECT \* FROM \[LayerName\] to verify the data before moving on.

WITH RawEnrollments AS (  
    \-- Layer 1: Data Cleaning & Extraction  
    \-- DEBUG CHECKPOINT: SELECT \* FROM RawEnrollments  
    SELECT student\_id, course\_id, COALESCE(credit\_hours, 0\) as credit\_hours   
    FROM university\_records   
    WHERE status \= 'Active'  
),  
StudentTotals AS (  
    \-- Layer 2: Business Logic (summarizing the clean data)  
    \-- DEBUG CHECKPOINT: SELECT \* FROM StudentTotals  
    SELECT student\_id, SUM(credit\_hours) as total\_credits  
    FROM RawEnrollments  
    GROUP BY 1  
),  
HighlyActiveStudents AS (  
    \-- Layer 3: Constraints (isolating the specific targets)  
    SELECT student\_id   
    FROM StudentTotals   
    WHERE total\_credits \> 12  
)  
\-- Layer 4: Final Presentation (The Reporting Layer)  
SELECT s.name, st.total\_credits  
FROM HighlyActiveStudents has  
JOIN students s ON s.id \= has.student\_id  
JOIN StudentTotals st ON st.student\_id \= s.id;

### **The Ephemeral Scope**

A critical constraint of CTEs is their **Scope**. A CTE is temporary; it only exists for the duration of the single query that follows it. You cannot define a CTE in one script and call it in another 10 minutes later. For persistence, you would need to use a View or a Temporary Table.

## **2\. Window Functions: The Moving Flashlight**

Window functions are invoked using the OVER() clause. Think of a window function as a "moving flashlight." As SQL iterates through your table, the flashlight illuminates a specific subset of other rows (the **Window**) and performs a calculation based on what it sees.

### **The Mechanics: Partitioning, Ordering, and Framing**

* **PARTITION BY**: This defines the "walls" of the window. If you partition by department, the flashlight only shines on other rows in that same department.  
* **ORDER BY**: This defines the "flow." Inside an OVER() clause, ORDER BY is what turns a static average into a running calculation.  
* **Aggregate Windows (Running Totals)**: By adding an ORDER BY to a SUM(), you create a cumulative calculation.  
  \-- This creates a running total of revenue over time  
  SELECT   
      sale\_date,   
      amount,  
      SUM(amount) OVER (ORDER BY sale\_date) as running\_total  
  FROM sales;

### **The Qualify Pattern (Filtering Rankings)**

One of the most common student errors is trying to filter a ranking result in the same query:

SELECT ... WHERE RANK() OVER(...) \<= 3 **(Error\!)**

Because Window Functions are calculated *after* the WHERE clause, the rank doesn't exist yet when the filter runs. You **must** use a CTE to "freeze" the calculation:

1. **CTE:** Calculate the rank.  
2. **Outer Query:** Filter where rank\_column \<= 3\.

## **3\. Sequential Navigation: Bridging the Row Gap**

SQL was originally designed to process "sets" (unordered piles of data). However, time-series data requires processing "sequences" (ordered lines of data).

**The Problem:** To calculate a month-over-month growth rate, the current row (February) needs to "know" the value of the previous row (January).

**The Solution:** LAG().

![][image1]**Practical Example: Finding the Delta**

If a student's GPA was 3.5 last semester and is 3.2 this semester, LAG() allows you to subtract the 3.5 from the 3.2 to calculate a \-0.3 delta within a single row.

## **4\. Recursive CTEs: The Hierarchy Engine**

Recursive CTEs are used when data is self-referential, such as a "Reports To" column in an employee table.

**The Infinite Loop Trap:**

Data integrity is the biggest risk in recursion. If Employee A reports to B, and Employee B reports to A, the recursion will never end. This is a "Circular Dependency." Professional SQL architects prevent this by:

1. **Limiting Depth:** Using a WHERE level \< 10 safety valve.  
2. **Path Tracking:** Concatenating IDs into a string (e.g., /1/4/12/) to ensure an ID is never visited twice.

## **Instructor Unit Notes**

* **The "Finality" of Window Functions:** Emphasize that window functions are "presentation-layer" calculations. They happen at the very end of the SQL execution order, just before the final SELECT is returned.  
* **Partition vs. Group By:** Use the phrase "Granularity Preservation." GROUP BY destroys granularity; PARTITION BY preserves it.  
* **Performance:** Remind students that OVER(ORDER BY ...) requires the database to perform a sort. On a 100-million-row table, this can be the most expensive part of the query.  
* **The Frame Clause:** Without a frame, SUM(amount) OVER(ORDER BY date) defaults to RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW. If they omit the ORDER BY, the "running" total just becomes a "grand" total because the flashlight shines on the whole room at once.

[image1]: <data:image/png;base64,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>
