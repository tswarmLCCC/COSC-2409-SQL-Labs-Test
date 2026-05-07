# **Unit 4: Grouping, Set Operations & Pivoting**

## **Analytical Reporting & Feature Engineering**

### **1\. Unit Overview & Objectives**

In previous units, we focused on "Row-Level" operations—finding, filtering, and joining individual records to build a detailed view of specific entities. However, in professional data science and business intelligence, we rarely present raw lists of thousands of rows to decision-makers. Instead, we provide high-level summaries that drive strategy.

This unit introduces **Aggregation**, the process of collapsing massive datasets into single, meaningful metrics like averages, totals, and counts. Beyond simple mathematics, we will explore **Set Operations** for vertical data synthesis and the advanced logic of **Pivoting** and **Unpivoting**. These transformations are essential for creating executive dashboards, managing Data Warehouses, and performing "Feature Engineering" for machine learning models.

**Learning Objectives:**

* **Master** the core Aggregate Functions (![][image1], ![][image2], ![][image3], ![][image4], ![][image5]) to transform millions of rows into actionable summary metrics.  
* **Implement** the GROUP BY and HAVING clauses to categorize data and filter results based on summarized values.  
* **Execute** Set Operations (UNION, INTERSECT, EXCEPT) to merge, compare, or isolate independent result sets vertically.  
* **Construct** Pivot tables using CASE-based conditional aggregation to restructure data from a transactional "Long" format to an analytical "Wide" format.  
* **Perform** Unpivoting operations using LATERAL joins to normalize "Wide" data into "Long" formats.  
* **Analyze** the circular data workflow: Unpivoting wide records into a "Feature Grab Bag" and Re-Pivoting them into custom, optimized datasets for AI and warehousing.

### **2\. The Problem Statement: Data Summarization vs. Data Dumps**

Imagine you are the Lead Analyst for a global financial institution. Your database captures every single credit card transaction made by 10 million customers. On a Monday morning, your CEO asks: "What was our total revenue per branch last month, and which branches are performing below average?"

#### **The Grain of the Data**

If you provide a "Data Dump" (the raw list of 10 million transactions), you have provided the "truth," but you haven't provided an "answer." The CEO cannot make a decision based on 10 million rows. This is a problem of **Data Grain**.

* **Raw Grain:** One row per individual transaction (too detailed).  
* **Summary Grain:** One row per branch (just right).  
  Unit 4 is about learning how to change the "grain" of your data to match the needs of the human or system consuming it.

#### **The Formatting Struggle (Pivoting & Unpivoting)**

Furthermore, data is often stored in ways that are convenient for input but impossible for analysis.

* **Pivoting (Long-to-Wide):** Turning row-based records (e.g., individual monthly sales) into columns (e.g., Jan\_Sales, Feb\_Sales) for comparison.  
* **Unpivoting (Wide-to-Long):** Turning column-based data back into rows. This is often necessary when you inherit a messy spreadsheet where someone has used columns to represent dates or categories, making it impossible to perform standard database operations like filtering or joining.

### **3\. Theoretical Framework: The Logic of Aggregation & Restructuring**

#### **A. The "Bucket" Metaphor (GROUP BY)**

To understand GROUP BY, imagine a warehouse where items are scattered on the floor.

1. **Categorization:** You choose a column to group by (e.g., Department). The engine creates a "bucket" for every unique value.  
2. **The Toss:** The engine tosses every row into its corresponding bucket.  
3. **The Squish (Aggregation):** You perform a calculation *inside* the bucket. You can no longer see individual rows; you only see the collective properties (e.g., AVG(gpa)).  
4. **The Result:** The database returns exactly one row per bucket.

#### **B. Set Operations: The Vertical Stack**

Set Operations combine queries **vertically** (stacking result sets on top of each other).

* **UNION / UNION ALL:** Merges two lists. UNION ALL is faster as it skips the duplicate check.  
* **INTERSECT:** Finds the "Overlap" (data in both sets).  
* **EXCEPT:** Finds the "Difference" (data in Set A but not Set B).

#### **C. The Logical Execution Order (The 6-Step Pipeline)**

1. **FROM / JOIN:** Locate and connect tables.  
2. **WHERE:** Filter individual, raw rows.  
3. **GROUP BY:** Sort rows into buckets.  
4. **HAVING:** Filter the buckets based on the summary result.  
5. **SELECT:** Perform final math and apply aliases (AS).  
6. **ORDER BY / LIMIT:** Sort and trim the final report.

#### **D. The Deconstruction Metaphor: Unpivoting**

If Pivoting is about "squishing" data into a summary, **Unpivoting** is about "unwrapping" it. Think of a wide row as a sealed box containing multiple items (columns). Unpivoting opens that box and lays every item out on the floor as its own individual row.

* **The "Key-Value" Pair:** When you unpivot, you create a standard format of two columns: an **Attribute Name** (The Key) and the **Value**.

### **4\. Implementation: The Reporting & Restructuring Tutorial**

**Note for T-SQL/Oracle Users:** Unlike SQL Server or Oracle, PostgreSQL does not have a dedicated PIVOT or UNPIVOT keyword. Instead, PostgreSQL uses standard SQL patterns that are more powerful and transparent. We use **Conditional Aggregation** for pivoting and **Lateral Joins** for unpivoting.

#### **A. The Core Aggregate Functions**

* **COUNT(\*)**: Row count.  
* **SUM(col)**: Total sum.  
* **AVG(col)**: Mathematical mean.  
* **MIN() / MAX()**: Extremes.

#### **B. The Golden Rule of Grouping**

**"Every column in your SELECT statement must either be inside an aggregate function OR be listed in the GROUP BY clause."**

#### **C. The PostgreSQL Pivot: How the "Squish" Works**

To understand pivoting, you must visualize the **Sparse Intermediate State**. When you run a CASE statement inside a SELECT, the database first creates a massive, messy table full of NULLs before it groups them.

**Step 1: The Raw Data (Long Format)**

| id | semester | gpa |
| :---- | :---- | :---- |
| 1 | Fall | 3.5 |
| 1 | Spring | 4.0 |

**Step 2: The Sparse Intermediate View (Unaggregated)**

If you run the query *without* the MAX and GROUP BY, you see this:

SELECT   
    id,  
    CASE WHEN semester \= 'Fall' THEN gpa END AS fall\_val,  
    CASE WHEN semester \= 'Spring' THEN gpa END AS spring\_val  
FROM student\_history;

| id | fall\_val | spring\_val |
| :---- | :---- | :---- |
| 1 | 3.5 | **NULL** |
| 1 | **NULL** | 4.0 |

**Step 3: The Aggregate Squish**

When we add GROUP BY id and MAX(), the database looks at the two rows for ID \#1. It sees (3.5, NULL) and (NULL, 4.0). Since MAX ignores NULL, it pulls the only real value from each column and "squishes" them into one row:

| id | fall\_val | spring\_val |
| :---- | :---- | :---- |
| 1 | 3.5 | 4.0 |

#### **D. The PostgreSQL Unpivot: Understanding the LATERAL Join**

If a standard join is a "zipper," a **LATERAL Join** is a **"For-Each Loop."** It allows the database to take a single row and, for that specific row, run a sub-query that generates multiple new rows.

**The Logic of CROSS JOIN LATERAL:**

1. **Row Selection:** The engine picks Row \#1 (which has 3 columns: Math, Science, English).  
2. **The Explosion:** It passes that row into the LATERAL block.  
3. **The Values Constructor:** Inside LATERAL, the VALUES command manually creates 3 new rows, effectively "hard-coding" the labels ('Math\_Score', 'Sci\_Score') and pairing them with the data from the current row.  
4. **Result:** One wide row becomes three narrow rows.

SELECT   
    student\_id,  
    feat.attr\_name,  
    feat.attr\_value  
FROM students  
CROSS JOIN LATERAL (  
    VALUES   
        ('Math\_Score', math\_score),  
        ('Sci\_Score', science\_score),  
        ('Eng\_Score', english\_score)  
) AS feat(attr\_name, attr\_value);

**Visual Illustration of the Unpivot:**

* **Input:** \[ID: 1, Math: 90, Sci: 80\]  
* **Process:** The VALUES clause creates:  
  * ('Math\_Score', 90\)  
  * ('Sci\_Score', 80\)  
* **Output:** 2 distinct rows for ID \#1.

#### **E. The "Grab Bag" Workflow: Advanced Feature Engineering**

In high-end Data Warehousing and AI projects, we use a circular workflow:

1. **Step 1: The Unpivot (Deconstruction).** Every data point (GPA, Attendance, Zip Code) becomes a row in a "Grab Bag."  
2. **Step 2: The Feature Filter.** We write one WHERE clause to remove outliers across every single feature type simultaneously.  
3. **Step 3: The Re-Pivot (Reconstruction).** We rebuild a perfectly formatted "Wide" row containing only the clean "features" needed for our AI model.

### **5\. Student Exercises: The "Student Success Pivot"**

*Connect to your GitHub Codespace and execute the following against the university\_records dataset.*

1. **Departmental ROI Report:** For every major, calculate COUNT of students, AVG credits, and MAX balance. Sort by the highest student count.  
2. **The Sparse Proof (The "Why" Exercise):** Write the query from Section 4C, Step 2\. Do **not** use MAX or GROUP BY. Observe the resulting table. Identify why the NULL values are appearing where they are.  
3. **The Elite Majors:** Re-write the ROI report but use HAVING to show only departments with \> 15 students and an average GPA \> 3.2.  
4. **The Unpivot Challenge:** Take the student\_test\_scores table. Use CROSS JOIN LATERAL to unpivot it into a "Long" format.  
5. **The Feature Engineering Workflow:** \* **Part A:** Unpivot a student's logins, library\_visits, and grades into a "Grab Bag" (Key-Value pairs).  
   * **Part B:** Re-pivot that grab bag into a single row with three columns, but only for students whose values in the grab bag are all greater than zero.  
6. **Manual Query Tracing:** Look at Student \#505. They had 10 logins, 0 library visits, and a 3.5 GPA. Trace the unpivot/re-pivot logic on paper. Will this student appear in the final wide-format output?

### **6\. Instructor Unit Notes**

* **The "Grouping Error":** Remind students: if it's not a bucket label (Group By), it must be squished (Aggregate).  
* **Lateral Joins:** This is a "lightbulb" moment. Explain that LATERAL lets you do things a standard Join can't—it lets the right side of the join "see" the data in the left side.  
* **AI Readiness:** Emphasize that the Pivot/Unpivot loop is the secret to **Feature Engineering**.

### **Appendix: GitHub Codespaces & Performance Reference**

* **Connecting:** psql \-U postgres  
* **Performance Impact:** Aggregations and Unpivoting require "Full Table Scans."  
* **Visualization:** Use \\x to toggle "Expanded Display" for wide Pivot tables.

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADEAAAAYCAYAAABTPxXiAAADZklEQVR4Xu2WS0iUURiGR7ToHl2mQUfneBkSLWgxXQhcGETUogILyqw2EkWL2hSRRLiRCFqEQUEUVpBot01EBRKRu1q5iCAQFIKgaFFkCyPteZ1zxuPxH3UTtJgXXs75v+89338u33f+PxYroIB/j3g8vqSysrKxoqJiR3V19XLZksnkqnQ6HQ+1/x0ymcw8Y8wFOJhKpU7RnoTv4BUW9Ya2rqysbBFtN/wDxy3V79NCFYf+ocA/Srzt/ruI14z9p6d5hm2Br/GB70QQ706UvgTHDdiTSCQWO6MmhvgtA1/rhJy9qqpqA7Yf6F+Ul5cvdHaH2trapfifM3Yvj0WhX9AkYC+6r7BfY0KNQPw073mJ5jfsCP054NwKh0mh9RG+NtgZ2FrsrrT5dgcWX47vCS9fEfocmFwSzT34WO+GpaHGZkcbcS7Z9+0KNTng7ICf9PII31kWtyewdcKxME0cZMd/M5bnFAQ0DZzEZdpzaEdoM6FGk4ZN+LpoP9NWh5ocCHZXK6U9z2Ox79NxwpXu2aZKPxzSbvpaBzuxltDuw2qaLMc1Yd9fU1Ozhvm02xN7D/v8VJ8GxAdtIFFF+Qq2ciMtC7XY6+A3k6cYZcPXHbWzHiZqULHsqY2ZqYsuwn4arlMcfCNmpnoQlHupbN75t4o4EKaYsTunnfTtDto5FvIgNYd60Km6S8J49YVtM+OPqU+s43Yu+eshQDHiOuUq7XcNVhBfYGavhwb812NzqAf10ZbCYaW0nu13qt1+o3QiXWaWeihWzsciXkignXayuR336iHyEhCkN3OsB/W9mBM5j++oFikf36XVZrZ60OoQXKNbEuFzuZibkNu1fEH1zdDOkQ61oc9Drh7cM/1Hmiwb12iyaTWxqdyKm3j+ZWaqB12dCJ5GFSgvOgw/shsVzsbkEugH4f1Y9OkdYMzFKJ9DVM0Q7xb8opTyT3hO9aAVwhHEW3y7Ugz7ANzn22PZHL2K/YMW5Nu1IcTpdf9beVCEplmnpb4z2vQa0yZMSnMnlL8eVEAm+7U8Y7J5p36rneSQDThtRzVJ/A/hcMr7x9K4qBRzwH8E3aiZvPl0I22zvt06Hd2Sti56Aq3+s27X19fPnxJU+WuLeuKKZSc3Mni/8jIqvQIUsZi10vt/uwUUUEABBQh/AS5NE8uX4D1+AAAAAElFTkSuQmCC>

[image2]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAC0AAAAYCAYAAABurXSEAAADAElEQVR4Xu2WPWhUQRSFE4x/ICpolCS7+/avyaqFrNgYQfAHLBQRtUk6C8FGCMRoWrFQQWKwsFBUAgbR2AmiQdMpWiiiWFkoUQsRGxVJSOJ3sjPrePc9E1G7PXCY9+65c9+dmTszr6Ghjjr+DlEUtcC+bDa73Gr/AfPS6XSBb+2h3ZHP55d5gRxyxWJxYeichEacT8Cxtra2VCgQ+BT2cTjtie1c6JPJZLqMfpcPLw19hFQqtRi9B36BT+Fp2AcfwcPE2U87TP9Ftm8NcC7j/FXUs9Wjyiq8cWyxukC/A2j3C4XCKqsJaO3wlZLFtxRq5XJ5PoleR5vSIEItFm70gwR6SztB22F9mpubl6CNwg/oeatredFuoK2xmkAJbED/CEfCUghB323o42qtVgMc98IzjPQY7TSddlkf0IR2M0pYCfoeQuu2dkEzj/YCvmeCilb3UFziPLflWQMXcLi1tTVNp14lDTutn4D9YtyglAj2W3xsRWh38HtF/XqtGMKV6LVZ6xmnHpy79KxkfhfcD0qz6m2qRewX4PbQ1wP/HByDn2C71UMoVlLpVKH6I9Cg6tW9zyQNT1pfAXun06sbRcnCfh6bAtcqqOXdrs/tWWdwNmhUBDpP0M3exsc7sE0Q/Gro64G2Uwl4XeXA+xDvWeNaRVByA1bTIKLKqVRlLpdbrdys7ww0QzhNuoCWsbPiak7H4ohWRxvXl1YSfNJxJYdtkzvm3rnvfsN2OXYS3PE0ZHdy9PMsHvUlE0K7OqrU5xOCb4VXdFxavxCq/6SkPYISii3LGSB2h5spsPukX2uZrM4JsxLtJfwMH8D11seChNbKn6TvJA0QfQBOZRLO50ZXt8+Y7YwV3Qo8dInX3HrBBaO6Po6p0frEQN88Sp9J2iN6D0UmZ6ObhNpLSxvOidOOcqpepbyfjX79v9DzpVKptCCMo00IHyecybFwm17/G9+jyhWuQRyMKpfVPeJtwdYft4/+CVjidcxOZO1zgZJyCe7Tn92fDLyOOuqoY+74AZNU7cGlz6TlAAAAAElFTkSuQmCC>

[image3]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEoAAAAYCAYAAABdlmuNAAAEyklEQVR4Xu2YS2hcVRjHbzCKbxGNY/OYM5MEQ6OikFqpWJEiRQUfVEHRhSvRRTd244MiYuhCYmutwUIt1gexSrsTrRQXVaFWuxBEDRiEWopdiArSFlox9fef+53JNye3M9ONiNw//Lnnfo/z+M75vntmsqxEiRL/NfT19V1cq9Vur1arD4YQliI6R/JKpXLRwMDAYGLewMTExLnYXyufoaGh1cPDw5elNv8bsMhxAvMlPEagPuC5Dr5De6+CQHsPzzu8z+jo6KXIp+BPcL0Fdz38TfLBwcELkv5n4WnHY/BF6cfHx8+j/W6i/2ZkZOSq2Ed/f/+FyN6Df5t+nvndGfUC7/c5vXgKvsz4h7sh/t8y7+t9nw3oNIR8cacwesYvTuCErET3JzziTxS2NyKbg5tSn3q9vhz5Hwy8ldderwv5BmgBa708gvFuwu8z+q+lugj0E/gfhfNwZ5aMMTY2dgnyPXCV5sbzYzjFvCrSKzt4/1RzZLzrJLM4PALnFmWOpcxWlH/BB1qUBuZ7PrqPRLUlo/NlvP8Kt6mP1EdAt8VPxNCLbDc8oYA4eRPo1sANqdwD/aPaVJ4HCsbQRlWUFaztcul47khO93DIA71PpSbKeV8CZxToKGuAzp5EcZrns7z2tCgd0L+N3XNqKxVofyf6tEihxVjfT0QZqXMlsu9Ftb19BIvYzOLuTeUe+G+yU7XWxnjB69Hdivw1az+e9ofuLvmFZEMsgBszHwsiPIrwFzjHpIcWzBcDm+3VvD710J60QQpTJyJYoPB7Osp0ipCd0A5nBRuj3UW/UxNOdRE6Jdo4C3odHoGzMa0EbY7Gp9mrQJFKV7guNLcNmlsaQD5C14Q0s7QLtuC2x1zQV8xyOE7saLvFCHEyPlC2gJZT5oFuKdzl0yEFAbmBPl/J8kBr46atz4fNROn9huycWxOuPnVcQ9y5fXDeTkpX0A5oUsHVqyJIJxuzXWNiLWoGHlfatDgYrP/JVO4R8vrUDDTvK+BJ+vxEdUgnTSdOJ8/7RVh6LapPhQh50fpZDh2j6qDTYYvfkuo8Qn4ydEXQ6atL1k19QjeZpkOKYPUpvis4ChLyk3BF1dWnIrjN7phJPlDiklTvUcsL/i1qx0D5dCqCs9ucWS2K9QnORJnH2dYnL1fa2eKnbb6qT4VQgGTbaUMa0IAYH+wUKBVB9G/Gr1usMe0ChU0t5BfQWX8fweceW8w6bx+hzzi67e1SWicJm9ezJNCaJ35fh/zu9lXIf1Esgis53WcSxhtDwc3WQTVFl8PmVyBYPYC7s+SSJ1jB36YJU0yXe11Y+CTHmtWE+U0TrJWpziMk9ckj2FUBHtRBSPWCghO6rU8RLCTg+CMDfw6v9jrL++eRP5W17p4+t7qgHkd3s5M3vibodqA7VHSZdPev6cz1aTfnqYKxWmBzeh/bu1OdEBa+yGesn2dVnzwsTfaH/G7zFq+PwVd5/wKuygomHhcmHw1Ytd93PA9rkvr9l/pE1PKfPYd47g356XiJ5w88H8oKxhLsc77LFhj5YcGJiFeFlvqkUxryUqDflb6P3+GBRT9X2qBHAQP3i3Q8ktk/Bu2guxW2qxUopVmtTW3xUJphf5v88F92pp9AJUqUKFGiRIl/E/8AjYmTxn8mLSUAAAAASUVORK5CYII=>

[image4]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADEAAAAYCAYAAABTPxXiAAAC1ElEQVR4Xu2WO2gUURiFZzGFohZG14V93Vl3YQ34IIiFL7DQwiKWGrC0iIVVQFc7mxSCCGLAQsFCQhCClQGjFgFBQWtJJVj4wCIERQUVH9+ZuXe5ueDsbpFuDhxm5j9n7v3vf/87u1GUI0eO/8IYcxB+hH8tX5fL5W2hz6Ferx/H89t6dX1aqVS2Or1arQ7jWfA8ji+azeZ259McxJ55+kqtVtvldIFxLgZjvGP83b5nFTBcg+9lJKlqqAtKFn0WfoFzhIZCjwMJ7MPzDc7Hcbw+1B1I/CSez0oS35VQVy5oz9F2htoqFIvFTRjvYbyhiZVA6AEF9HPwMp4/cDI0+EA/o8QYqxNqPpQ4nFDx4FKj0Sj5Os97id+OMgqWgIl2yMj1lJ14LPQQH7WLuMT9LzyHQ4+HAvrdXr5SqbQRzx1b7WnNzfjjvscWI7NgCbSlqjDX/bzwPXyJPtyginGtoM3DN2HFfJD4Fjyv+vAlxVO7cT0AfxB7pPmcB+1qViG6UIIYjzHICFyGU4F+WrpdxFvT/3nI9KGfgBd0r8S1AC1EC1JMxWDu+1mFSODOg7ZUZlUPziAVpDNIbPt6yC607/PQy+eK5z2P2/emeSxwHUG/FWUUIoG/pXZBi6LuozTxjhZivR3To8+jAc+DdtfFbBGXTHrIG2bQ82AftfoZY3tZVVIrSdAizRqdBz+u3THpbpyPBz0P7pmXp+Ay8aMaxB0y+wVRhTL7vN7neQiK1wXztXj3A/zEWAtZP7wJbPvMqiouxvOkSb9Qc3DUxbVQM8B5UOuFmo+weB7UDcnntlchEjDIIYwP2+32Zi82pgFslZLDLZh0hzL7POrzPLRaraKqTLvtCTXB2M8tOUyEWhds5RFMK3a14k94VpragZcfu/9DxK/Dr763nn7Lh9149u/Ik9AHF/120H8nxn7pecSbSOucR1ALE3+QVYgcOXLkyLFm+AfciwItDZ0rHwAAAABJRU5ErkJggg==>

[image5]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADUAAAAYCAYAAABa1LWYAAADSElEQVR4Xu1WS2gUQRCdhVX8HvysS/bXsx9cXFQMgwp+QEEPCvEiaMBjLh6EQEA28aAezEEQg3jUIBLCYsxFjODvEC9eclUiQvBDNKcYEPWgmPie073plDPJHDzpPCh6pup1dVd1Vc84TowY/x9c121XSh2R+r8OLLIHMgWZ0/Iyk8lslDyDQqFwGJyfmsvxaTab3SB5ErlcrgLuR8g5aTOA7SDks7UXyptSqbQZe1qF5xFhe77o2iBcgXyATIKYk3aCDmBvKH/hYaiSkhOCJPg3uRGc1m1plNAnyk0/SafTq42+UqmkGAikw/O8ZfacP5BKpdaAOABn1zB+xWl4kgMkYD8N6QFnFtIlCWHQp/sC8iNKMorFYhq8cchMPp/fSh2DwPt1yHHJDwQWLYF8A+MJjHMY2yQH+lYdVDc3B84+yQkCE4Y5d3Rg7yCj1EmeBOZc5F44WgGdgSkhuYFANo7xBDDuxMRvSpwC+mElnWPMwvYAMsFs2pwwMBHgn4W06KDGEOA6yZPgCYE7A3kFfh99OFEDIrhhTDyEiVsg05BeYT9Juw7qrYpQQgSaOw/uIHtRl/ioDqxFcgPAPhxWfuXcWrKHbJh+4uWga3mCG3F0VhCQC6d1PCZ14FH7iT14mVXAFyuoKZa74AYCvE4GBWk4EZLYhOknbGCFtbCpewZSZ2CaW1cR+wlTdtOvlWGT+bCLaAGYQMgz5X8GmhdGJJh+0q8JOBhUumfomKVHA4NWEfuJPQjefbXwm2Jkln7lHBvwvwu8u/Cznq3BeRwlLxQk24vAQS9kGvoDLB9ukHqWJ/STKkI/MRHwed4Rja1POvB2NUBACvZ7HPluXRjjSyXzN3S5NViCRof3LuXfgCyVVqNn4Mwy7UYXBAaPoIbK5fImaTNBhfnQAT3C/B2WmmXLDz5Pq93SBwMO9oI8Uq1W11q6Nu2AJdnMtPJPcNF+4tcfnH5wLkgbUZj/DvLisZFAQNthG4McFTaufUrvaSj0FsSR7lf+kTJrlO+QDtqwoIfJj80/FfRXIV9sLjgPWe/Gn+v324DF4cb7jB3cbXh/Lezvlf/feUnN/0tSPnEPlm/+5TTnKX+v/bVabbnhxIgRI0aMfwq/AEh8GBaraNjqAAAAAElFTkSuQmCC>
