# **Unit 2: Advanced Filtering & Logic**

## **Precision Retrieval: Slicing Data and Logic**

### **1\. Unit Overview & Objectives**

In Unit 1, we learned how to "shine a flashlight" on specific columns using the SELECT statement. However, in professional database work, identifying *what* you want to see is only half the battle. You must also determine *which* specific rows deserve to be seen. In this unit, we introduce the WHERE clause—the engine of database filtering—and explore the mathematical logic that allows a database to make decisions.

**Learning Objectives:**

* **Master** the WHERE clause to filter datasets based on specific, multi-layered criteria.  
* **Analyze** the implications of Three-Valued Logic and how NULL values impact query results.  
* **Construct** complex search patterns using LIKE, ILIKE, IN, BETWEEN, and Regular Expressions (POSIX).  
* **Implement** Scalar Expressions to transform the database into a high-speed calculator for derived data.  
* **Standardize** output using Column Aliasing (AS) to create professional, self-documenting reports.

### **2\. The Problem Statement: Precision vs. Noise**

A modern database is like a digital ocean. If you are looking for information on a specific subset of citizens in a Wyoming Census dataset of 500,000 people, a simple SELECT statement (even with specific columns) still leaves you with a massive, unreadable list.

#### **The Need for the "Surgical" Lookup**

Sometimes, you aren't looking for a "list" at all—you are looking for one specific person. Imagine a student walks into your office and provides their ID number. Without filtering, you would have to scroll through the entire campus directory to find their record. The WHERE clause allows for **Surgical Retrieval**, where the database ignores 49,999 records to return the exact one you need instantly. This precision is vital for tasks like customer support, medical records, and security audits.

#### **Creating a "Decision Space"**

Beyond simple lookups, filtering allows us to create a restricted "space" for analysis. If a manager asks, "How much are we paying in overtime this month?", you don't look at all salary data. You first slice the data to include only "Overtime" records. This focused **Decision Space** is the essential first step before we perform aggregations (calculations like sums and averages), which we will master in later units. This unit gives you the tools to filter out the noise and present only the specific facts that lead to action.

### **3\. Theoretical Framework: The Logic of Retrieval**

To master filtering, you must understand that the WHERE clause is actually a **Decision Engine**. It evaluates every single row in your table against a set of rules and decides whether to "keep" or "discard" that row.

#### **A. Predicates and Comparison Operators**

At the heart of the WHERE clause is the **Predicate**. A predicate is a statement that can be evaluated as either **True**, **False**, or **Unknown**. In SQL, every expression in your WHERE clause must boil down to one of these three Boolean values for a row to be processed.

| Operator | Name | Definition | Example |
| :---- | :---- | :---- | :---- |
| \= | **Equal to** | Returns true if the values on both sides are identical. | WHERE department \= 'Sales' |
| \<\> or \!= | **Not equal to** | Returns true if the values are different. | WHERE status \<\> 'Retired' |
| \> | **Greater than** | Returns true if the left value is strictly larger than the right. | WHERE age \> 21 |
| \< | **Less than** | Returns true if the left value is strictly smaller than the right. | WHERE price \< 10.00 |
| \>= | **Greater than or equal** | Returns true if the left value is larger than or exactly equal to the right. | WHERE GPA \>= 3.5 |
| \<= | **Less than or equal** | Returns true if the left value is smaller than or exactly equal to the right. | WHERE stock \<= 10 |

*Note: BETWEEN and IN are also technically predicates. BETWEEN is shorthand for (x \>= a AND x \<= b), and IN is shorthand for a series of \= checks joined by OR.*

#### **B. Condition Expressions: The "Rules"**

A **Condition Expression** is the actual rule you write. It can be a simple comparison or a complex calculation. When the database evaluates these, it treats them as a **Boolean Expression**. If the computer cannot confidently say "True" (as is the case with NULL), it defaults to a "No" for the sake of data safety.

* **Calculated Conditions:** You can perform math inside the rule. For example, WHERE (annual\_income / 12\) \> 5000 calculates the monthly income for *every row* before applying the filter.

#### **C. Order of Evaluation: How the Database "Thinks"**

It is critical to understand that the database engine evaluates expressions in a specific pipeline. A common beginner mistake is trying to use an alias (like AS total\_tax) in the WHERE clause. This fails because the database filters the rows *before* it ever looks at your SELECT labels.

1. **Row Access (FROM):** The engine identifies and opens the table.  
2. **Filter Evaluation (WHERE):** For the current row, the engine calculates expressions and performs comparisons.  
3. **Projection (SELECT):** Only rows that passed the filter are then "projected" to show specific columns and aliases.  
4. **Final Trim (LIMIT/OFFSET):** The very last step is trimming the result set to the requested size.

#### **D. Three-Valued Logic & The Mystery of NULL**

Unlike binary logic (True/False), SQL uses **Three-Valued Logic (3VL)**.

* **NULL is "Unknown":** In SQL, NULL isn't a broken value; it's a question the database can't answer. If you ask Is age \> 21? and the age is NULL, the answer is **Unknown**.  
* **The Propagation of NULL:** 5 \+ NULL is NULL. NULL \= NULL is actually Unknown.  
* **The Consequence:** Because the WHERE clause only keeps "True" results, "Unknown" rows are discarded. You must use IS NULL or IS NOT NULL to interact with missing data.

### **4\. Implementation: The Advanced Filtering Tutorial**

#### **A. Range and List Matching (IN & BETWEEN)**

* **IN (The "Set" Operator):** WHERE city IN ('Laramie', 'Cheyenne').  
* **BETWEEN (The "Range" Operator):** WHERE age BETWEEN 18 AND 25 (Inclusive of 18 and 25).

#### **B. Pattern Matching: LIKE, ILIKE, vs. Regular Expressions**

##### **1\. Basic Wildcards (LIKE & ILIKE)**

* **LIKE**: Case-sensitive matching. 'Wyoming' will not match 'wyoming'.  
* **ILIKE**: PostgreSQL's "Case-Insensitive" version. This is much more forgiving for user-entered data.  
* **%**: Matches any sequence of characters.  
* **\_**: Matches exactly one character.

##### **2\. Regular Expressions (POSIX Operators)**

Regex is used for highly sophisticated patterns that LIKE cannot handle.

* **\~**: Case-sensitive match.  
* **\~\***: Case-insensitive match (**Pro-Tip:** Start here if you aren't sure about the casing).  
* **\!\~**: Does not match.

**Common Regex Characters:**

* **^ / $**: Start / End of string.  
* **\[ \]**: Match any character inside.  
* **.**: Match any single character.  
* **\* / \+**: Zero or more / One or more of the preceding character.

**Example:** WHERE last\_name \~ '^B...s$'; (Starts with B, ends with s, 5 letters total).

#### **C. The NULL Dilemma: IS NULL**

Never use \= NULL. Use IS NULL to find missing data or IS NOT NULL to find completed records.

#### **D. Using Expressions and Aliasing (AS)**

Use expressions for on-the-fly math (salary \* 0.12) and AS to give them professional names. Remember: you cannot use this alias in the WHERE clause because the filter happens before the name is assigned.

### **5\. Student Exercises: The "Census Audit"**

*Connect to your GitHub Codespace and execute the following against the wyoming\_census table.*

1. **High Earners:** Find residents earning over $100,000, sorted descending.  
2. **The Geographic Filter:** Find residents in 'Sheridan', 'Gillette', or 'Laramie' born between 1980 and 1995\.  
3. **The Regex Search:** Use \~\* to find residents whose last name contains "th", then any single character, then "n" (e.g., Smithson).  
4. **The Missing Data Audit:** Identify residents who do not have an address listed (IS NULL).  
5. **The Tax Estimator:** Calculate a virtual column "Estimated Tax" as 12% of annual\_income and alias it.  
6. **Top 10 Report:** Retrieve the 10 residents with the longest first names. (Hint: Use LENGTH(first\_name) to calculate the character count).

### **6\. Instructor Unit Notes**

* **Regex Performance:** Regex is powerful but slower. Use LIKE or ILIKE for simple tasks.  
* **Parentheses in Logic:** (A OR B) AND C is not the same as A OR (B AND C). Grouping is vital.  
* **Alias Trap:** Remind students that aliases belong to the output, not the search criteria.

### **Appendix: GitHub Codespaces & Psql Refresher**

* **Starting:** psql \-U postgres  
* **Switching Databases:** \\c census\_db  
* **Viewing Schema:** \\d wyoming\_census  
* **Exiting:** \\q
