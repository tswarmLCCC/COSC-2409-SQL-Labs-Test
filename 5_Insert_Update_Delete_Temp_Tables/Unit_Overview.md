# **Unit 5: Data Integrity & State Management**

## **The Science of Data Mutation and Transactional Safety**

### **1\. Unit Overview & Objectives**

In Units 1 through 4, we focused exclusively on Data Query Language (DQL)—the art of retrieving and analyzing existing information. In Unit 5, we transition to Data Manipulation Language (DML). You are moving from being a "reader" of data to a "writer" of data.

This transition carries immense responsibility. While a mistake in a SELECT statement merely returns an incorrect report, a mistake in DML can permanently destroy the foundational "Source of Truth" for an entire organization. This unit focuses on **State Management**: the methodology used to handle high-volume data, protect against "partial failures," and maintain the structural integrity of the database.

**Learning Objectives:**

* **Implement** core DML operations (INSERT, UPDATE, DELETE) with precise predicate filtering.  
* **Execute** "Upsert" logic using ON CONFLICT to automate duplicate handling and synchronize data streams.  
* **Analyze** the four pillars of **ACID Compliance** to justify relational database reliability.  
* **Orchestrate** multi-table mutations using Transaction Blocks (BEGIN, COMMIT, ROLLBACK).  
* **Utilize** SELECT INTO for permanent snapshotting and **Temporary Tables** for session-level scratchpads.  
* **Construct** "Stepped Calculation" workflows that break complex, multi-stage logic into verifiable intermediate steps.

### **2\. The Problem Statement: The Fragility of the "Mirror of Reality"**

Before touching the code, we must understand the fundamental challenge: **The Mirror of Reality**. A database is only valuable if it perfectly reflects the real world. If a bank’s database says you have $500, but you actually have $0, the mirror is cracked, and the system has failed.

#### **The Crisis of Synchronicity**

Real-world actions are often complex, while computer commands are singular. In the physical world, "transferring money" is one event. In the database world, that same event requires at least two separate changes (subtracting from Alice, adding to Bob).

The primary threat is **Synchronicity**. If a process requires three steps to reflect a real-world event, but only two steps finish before a system crash, the database now represents a "Partial Truth." Partial truth is often more dangerous than no data at all, as it leads to over-enrollment, lost payments, or ghost inventory. We need tools to ensure that multi-step events happen as a **"Single Heartbeat."**

#### **The Case Study: The Partial Success Disaster**

Imagine a course registration system where only one seat remains:

1. **INSERT** a record into enrollment (Student is added).  
2. **UPDATE** the course\_inventory (Seat count becomes 0).  
3. **INSERT** a record into billing (Invoice is generated).

If the power fails after Step 1, the student thinks they are in the class, but the inventory still says a seat is available. The next student who clicks "Enroll" will be admitted to a full room. This is a **State Desync**.

### **3\. Theoretical Framework: ACID and the Architecture of the Scratchpad**

#### **A. ACID Compliance: The Database's DNA**

To solve the "Cracked Mirror" problem, professional databases follow the **ACID** model:

* **Atomicity (All-or-Nothing):** A transaction is an "Atom"—it cannot be split. Either every line succeeds, or the entire block is ignored.  
* **Consistency:** The database acts as a strict librarian, enforcing all schema rules (e.g., "Balances cannot be negative") during every write.  
* **Isolation (The "Bubble" Effect):** Your "Work in Progress" is invisible to other users until you hit COMMIT. This prevents others from making decisions based on your half-finished math.  
* **Durability:** Once the database says "Success," the data is etched into the disk and will survive a total system crash.

#### **B. Snapshots vs. Scratchpads: Designing for Safety**

Sophomore learners often fear the "permanence" of SQL. We solve this by creating "Safe Zones" for experimentation:

1. **Permanent Snapshots (SELECT INTO):** Think of this as a **Historical Backup**. You "freeze" a result set into a new, permanent table on the disk. It lives forever until manually deleted. (e.g., "Back up the Grades table before the end-of-semester purge").  
2. **Session Scratchpads (INTO TEMP):** Think of this as a **Post-it Note**. These tables exist only in your current connection. They are private to you and are automatically deleted the moment you log out. This is the ultimate playground for testing destructive logic.  
3. **Modular Steps (TEMP Tables):** Used for **Complexity Management**. Instead of one 100-line query, you break a problem into three small, verifiable temp tables. You calculate Part A, verify it, calculate Part B, verify it, then join them for the final result.

### **4\. Implementation Guide: Writing and Guarding Data**

#### **A. The UPSERT Pattern (ON CONFLICT)**

In high-speed systems, we often don't know if a record is "New" or "Returning." Instead of checking first (which is slow), we use an **UPSERT**.

INSERT INTO student\_logins (student\_id, last\_login)  
VALUES (101, NOW())  
ON CONFLICT (student\_id)   
DO UPDATE SET last\_login \= EXCLUDED.last\_login;

* **The EXCLUDED Virtual Table:** When a "collision" happens (the ID already exists), PostgreSQL creates a temporary table called EXCLUDED containing the new data you *tried* to insert. You use this to update the existing record.

#### **B. Transaction Blocks: The Professional Safety Net**

1. **BEGIN;**: Enters "Draft Mode." No one else can see your changes.  
2. **COMMIT;**: The "Save" button. Merges your draft into the "Source of Truth."  
3. **ROLLBACK;**: The "Emergency Undo." If you see you accidentally updated 10,000 rows instead of 1, run this to reset the database.

#### **C. The "Stepped Calculation" Workflow**

Professional engineers avoid "Monster Queries" by using the **Stepped Workflow** via Temp Tables.

**Step 1: Isolate specific data into a scratchpad.**

SELECT student\_id, sum(credits) as total\_credits  
INTO TEMP high\_load\_seniors  
FROM enrollment   
WHERE year \= 'Senior'  
GROUP BY student\_id  
HAVING sum(credits) \> 15;

**Step 2: Perform the next stage of logic using the scratchpad.**

By separating these, you can run SELECT \* FROM high\_load\_seniors to ensure your math is correct before using it in a billing or graduation query.

### **5\. Student Exercises: The "Registration Gauntlet"**

*Connect to your GitHub Codespace and execute the following against the university dataset.*

1. **Manual Ingestion:** Use INSERT to add a new faculty member. Explicitly list the columns name, department, and hire\_date.  
2. **The User Onboarding (UPSERT):** Use ON CONFLICT on the user\_login\_logs table. If the user\_id already exists, update the login\_count by incrementing it by 1 using the EXCLUDED table logic.  
3. **The Permanent Snapshot:** Use SELECT INTO to create a permanent backup table called billing\_audit\_backup for all students with a balance \> $500.  
4. **The Modular Step Challenge:** \* **Part A:** Create a TEMP table of students with a 4.0 GPA.  
   * **Part B:** Create a TEMP table of students with outstanding library fines.  
   * **Part C:** Use INTERSECT to find students on both lists.  
5. **The Trust Exercise (Destroy and Restore):** Run BEGIN;, then DELETE every record in the grades table. Run a SELECT to prove the table is empty. Then, run ROLLBACK; and run the SELECT again to prove the data has returned safely.  
6. **The High-Stakes Transaction:** Script the Enrollment Heartbeat: BEGIN;, DELETE a student from an old class, UPDATE the seat count in the courses table, and INSERT them into a new class. Verify all results, then COMMIT;.

### **6\. Instructor Unit Notes**

* **Session Scope:** Remind students that TEMP tables are invisible to other terminal tabs. If they open a second connection, their scratchpad won't be there.  
* **The "Where" Trap:** This is a trust exercise. Sophomores often fear DELETE. Use the ROLLBACK exercise to show them that as long as they are in a transaction, they are safe.  
* **EXCLUDED Keyword:** Explain that this only exists during the split-second of a conflict.

### **Appendix: GitHub Codespaces & State Reference**

* **\\dt**: Lists permanent tables.  
* **\\dt \*.\***: Lists all tables, including the hidden pg\_temp schema.  
* **Prompt Status:** If your prompt has a \* (e.g., postgres\#\*), you are inside a transaction. **Never** log out without typing COMMIT or ROLLBACK.
