# **Unit 7: Schema Design & Data Integrity**

## **Unit Overview & Objectives**

This unit marks your transition from being a "query writer" to becoming a **Database Architect** and **Analytical Engineer**. In the modern enterprise, you are the primary stakeholder responsible for the "Immune System" of the data stack. We are moving away from the "move fast and break things" mentality of early-stage development toward a philosophy of **Data as a Product**, where structural integrity, historical accuracy, and provenance are non-negotiable features of the system.

We will explore how to design schemas that do not just store values, but enforce complex business rules at the hardware and kernel level. By the end of this unit, you will understand how a well-designed schema ensures that your data remains a "Single Source of Truth," providing a reliable foundation for human analysts and AI agents alike.

**Learning Objectives:**

* **Architect Structural Integrity:** Utilize CREATE TABLE and ALTER TABLE to build resilient schemas that adapt to changing business requirements without causing "Silent Failures" or downstream breakage.  
* **Implement the "Immune System" of Data:** Master the comprehensive use of Constraints (PK, FK, CHECK, UNIQUE, NOT NULL) to prevent "garbage-in, garbage-out" scenarios at the moment of ingestion.  
* **Master Dimensional Modeling Taxonomy:** Distinguish between Fact and Dimension tables and implement specialized warehouse structures like **Factless Fact Tables** and **Coverage Tables** to solve complex analytical gaps.  
* **Define the Grain:** Learn to establish the atomic level of detail for fact tables to ensure mathematical consistency across all reporting layers.  
* **Establish Data Lineage & AI Auditability:** Leverage PostgreSQL COMMENT features and metadata strategies to prove data provenance—essential for compliance in an AI-driven economy.  
* **The Time Machine Logic:** Implement **Slowly Changing Dimensions (SCD) Type 2** to preserve historical context and enable "point-in-time" reporting that accurately reflects the past.  
* **Bi-Temporal Auditing Foundations:** Understand the difference between "Valid Time" (when a fact was true in the world) and "Transaction Time" (when the database recorded the fact) to build audit-proof records.

## **The Problem: The Fragile Schema & The Historical Void**

In production environments, you will face two catastrophic architectural failures that can bankrupt a data project’s credibility and lead to multi-million dollar business errors:

### **1\. The "Garbage-In" Syndrome (Integrity Failure)**

**The Problem:** Without hard-coded constraints, a database is just a "Data Swamp" or a glorified, shared Excel sheet. If a Career Services table allows a negative salary, or a Healthcare table allows a heart rate of 0 for a living patient, the database has failed its primary mission.

**The Consequence:** Modern AI models and LLMs are "Garbage In, Garbage Out." If an AI agent queries a table with corrupted data, it won't trigger an error; it will provide a highly confident, mathematically incorrect hallucination. This leads to "Silent Failures"—where the dashboard looks beautiful, but the underlying numbers are a lie.

**The Solution:** **Constraints as the Structural Defense**. We use CHECK and FOREIGN KEY constraints to force the data to prove its validity before it is allowed to occupy a single byte of space on the disk. We treat the schema as a contract that the data must sign.

### **2\. The "Historical Void" (The Overwrite Problem)**

**The Problem:** Standard transactional databases are "destructive" by design. When a student changes their major or a product changes its price, a standard UPDATE statement overwrites the old value, deleting it forever.

**The Consequence:** This creates a **Historical Lie**. If a student earned 60 credits as a Biology major and then switched to Computer Science, a destructive update makes it look like the Computer Science department produced those 60 credits. Your departmental performance reports for the previous year are now fundamentally fraudulent and unauditable.

**The Solution:** **SCD Type 2**. We move from "destructive updates" to "versioned inserts," ensuring we can "time travel" to see the world exactly as it existed on any specific calendar date.

## **1\. Data Modeling: Types, Identity & Lineage**

### **Specialized Data Types & Precision Errors**

Choosing a data type is an act of engineering. It impacts storage, speed, and mathematical truth.

* **NUMERIC vs. FLOAT:** For financial and scientific measurements, **never** use FLOAT or REAL. These are approximate types based on binary floating-point math. They can lose "rounding crumbs" (e.g., ![][image1] often does not equal ![][image2] precisely in binary).  
  * *Implication:* In a high-volume ledger, these tiny errors accumulate into significant financial discrepancies. Always use NUMERIC(precision, scale) for absolute accuracy in ledger systems.  
* **JSONB vs. Structured:** Use JSONB for "Semi-Structured" data (like raw API payloads), but remember: JSONB is a "black box" to standard SQL constraints. It provides flexibility at the cost of governance. If a field is critical for a report (like salary or status), it belongs in a structured column.

### **Identity: SERIAL vs. UUID (Security & Scalability)**

* **SERIAL:** Incremental integers (![][image3]). Easy to read but predictable. In a public portal, an ID of 1005 tells a scraper exactly how to find user 1006\. This is a security vulnerability known as an IDOR risk.  
* **UUID:** 128-bit random identifiers. These provide "Identity Obfuscation," making it impossible for unauthorized users to "guess" the next record's URL. Furthermore, UUIDs allow for merging data from different servers without ever worrying about "ID collisions."

## **2\. Advanced Dimensional Modeling: The Taxonomy**

To optimize for analytical speed, we use the **Star Schema**. This requires a strict separation between **Context** (Dimensions) and **Metrics** (Facts).

### **A. The Grain: The Foundation of Truth**

The "Grain" is the level of detail represented by a single row in a fact table. Before you write a single line of SQL, you must define the grain.

* **High Grain:** One row per student per semester.  
* **Atomic Grain:** One row per student per individual interaction (e.g., a single resume review).  
* **Rule:** Always model at the most atomic grain possible. You can always aggregate up, but you can never "un-aggregate" a low-grain table.

### **B. Dimension Tables (The Context)**

**Definition:** Descriptive attributes—the "Who, What, Where, and Why."

**Utility:** These are the "labels" on your charts. They are wide, textual, and rarely updated.

**Data Preview:**

| center\_id (UUID) | campus\_name | lead\_coordinator | regional\_code | is\_active |
| :---- | :---- | :---- | :---- | :---- |
| 550e8400... | West Campus | Sarah Jenkins | WC-01 | TRUE |

### **C. Fact Tables (The Measurement)**

**Definition:** Quantitative metrics—the "How Much" or "How Many."

**Utility:** These are the numbers you sum, average, or count. They consist mostly of Foreign Keys and numbers.

**Data Preview:**

| application\_id | student\_key | job\_key | center\_key | base\_salary\_offered | days\_to\_offer |
| :---- | :---- | :---- | :---- | :---- | :---- |
| f47ac10... | student\_123 | job\_888 | center\_wc | 85000.00 | 14 |

### **D. Factless Fact Tables (The Event)**

**Definition:** Tracking occurrences where there is no numeric metric. The "fact" is simply that the event happened.

**Utility:** Used for tracking attendance, participation, or logs.

**Data Preview:**

| meetup\_id | student\_key | recruiter\_key | interaction\_timestamp |
| :---- | :---- | :---- | :---- |
| 111-aaa | student\_123 | recruiter\_ibm | 2024-10-12 09:30:00 |

### **E. Coverage Tables (The Universe)**

**Definition:** Defining the "Universal Set" of what *could* happen to find what *didn't* happen.

**Utility:** This provides the "Denominator." To find out which students *haven't* used career services, you need a Coverage table of all students eligible for those services.

**Data Preview:**

| student\_key | benefit\_type | eligibility\_start |
| :---- | :---- | :---- |
| student\_123 | Resume Review | 2024-01-01 |
| student\_456 | Resume Review | 2024-01-01 |

## **3\. Implementation: Slowly Changing Dimensions (SCD Type 2\)**

SCD Type 2 is the industry standard for maintaining **Historical Integrity**. It transforms a static table into a chronological ledger by adding three "Administrative Columns":

1. **effective\_start**: The timestamp when this specific version of the row became "the truth."  
2. **effective\_end**: The timestamp when this version was superseded (NULL for current records).  
3. **is\_current**: A boolean flag used for high-speed filtering of the "now."

### **The SCD Lifecycle: A Step-by-Step Evolution**

Imagine Student 123 changes their major from **Biology** to **Computer Science**.

**Phase 1: Initial State (January 2023\)**

| student\_id | name | major | effective\_start | effective\_end | is\_current |
| :---- | :---- | :---- | :---- | :---- | :---- |
| 123 | John Doe | **Biology** | 2023-01-01 | NULL | TRUE |

**Phase 2: The Change Event (January 2024\)**

John switches his major. We perform a **Two-Step Atomic Operation**:

1. **Retire Version 1:** Update effective\_end to 2024-01-01 and is\_current to FALSE.  
2. **Birth Version 2:** Insert a brand new row with the updated major and a new effective\_start.

**Phase 3: The Resulting Ledger**

| student\_id | name | major | effective\_start | effective\_end | is\_current |
| :---- | :---- | :---- | :---- | :---- | :---- |
| 123 | John Doe | **Biology** | 2023-01-01 | **2024-01-01** | **FALSE** |
| 123 | John Doe | **CompSci** | **2024-01-01** | NULL | **TRUE** |

## **4\. Practical Applications & Exercises**

### **Healthcare: The Plausibility Shield**

In healthcare, data integrity is a safety feature. We use CHECK constraints to ensure sensors or human input aren't providing "impossible" data.

ALTER TABLE patient\_vitals   
ADD CONSTRAINT bio\_integrity\_check   
CHECK (  
    (heart\_rate BETWEEN 20 AND 250\) AND   
    (body\_temp\_f BETWEEN 90 AND 110\)  
);

### **Career Services: Data Lineage & Provenance**

We use the COMMENT command to bake metadata directly into the system catalog so AI agents and auditors can trust the source.

COMMENT ON TABLE fact\_job\_applications IS 'Source: Handshake API v2. Lineage: Raw \-\> Cleaned. Owner: Career Services Admin.';  
COMMENT ON COLUMN fact\_job\_applications.base\_salary\_offered IS 'Source: Recruiter Entry. Lineage: Manual \-\> Cleansed.';

## **Student Exercises**

1. **The Integrity Shield:** Build a jobs table for a Career Services portal. Implement a CHECK constraint ensuring min\_salary \< max\_salary and a NOT NULL constraint on job\_title.  
2. **Factless Design:** Create a table to track "Recruiter Interchanges" where the goal is to record every time a student speaks to a recruiter, regardless of whether a job was offered.  
3. **The Universe (Coverage):** Design a coverage table that maps every student\_id to every major\_id currently offered. Use this to identify students who are registered but do not have an assigned major.  
4. **The Time Machine (SCD Type 2):** Write a SQL script that "retires" a student's old career advisor and "inserts" a new one using the versioning logic (Start Date, End Date, Is Current).

## **Instructor Unit Notes**

* **The Coverage Gap:** Explain that most business errors come from not knowing what *didn't* happen. Coverage tables solve this by providing the "Denominator" for your calculations.  
* **Indexing FKs:** Remind students that in a Star Schema, every Foreign Key in the Fact table **must** be indexed. Without indexes, joining a Fact table of 10 million rows to a Dimension table will require a "Sequential Scan," which will cripple analytical performance.  
* **Storage-for-Truth Trade-off:** SCD Type 2 "bloats" the database by adding new rows for every change. This is a purposeful trade: we spend disk space to buy **Historical Truth**.  
* **Bitemporal Logic:** Advanced students should consider **Transaction Time** (when the data hit the DB) vs **Valid Time** (when the change happened in the world). SCD Type 2 usually tracks Valid Time.

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEkAAAAXCAYAAABH92JbAAADTklEQVR4Xu2XP2gUQRjF71BBURCReHi5u727iJLKyKlBUbEQIYIiaiFRRGy0sFADEQOCElIoKMRGSRfEzsImgn/AgI2ojYUKWogSTGUKUcFA0N/LzmyGyS3n5eCisg8+dvfN+2bmezu7O5tKJUiQIMFfiFwutyQIgm5iiLhaKpXW+ZpaIG9DPp/f7fPNguasuZsaulWTr6kGtKuJi8orFouXyVvja1Llcnk5gkdEf0tLyzKEHZy/IQ76Wh9oOwuFQi/aF8Qvzs/7mmZAc9WcNXfVoFpUk2rztS4wdrN03NztnK/nfER1ED00pyOhClORHFdYjusjxFsSM5GwCoxJe9HuIb43YhJ9naGPLp+vhWw2myfvveZsOdWimojTrtaFVhq6e2hOcLlAXGtr60rm8dzUUpkW2s5oGHY7wNlN8N847nP5OKjDRk1Srgz3+VowN3SmqBBpuDvEqFaWw0cIwsfsI/FVq8jh+4JwNZ2zRDvxxTfJFk0MuHwc5tmkG1VM0sochh+HL7u8RaVSWYRmkPYHMszymodMimqxxcWZ5PNxmE+TjBlxJs3ia2AhOXeJKfJ3TjOalFzzzfhXTDIv6dFqZszFJHI6lUMMaaVNk1x0NdskDa4PQhC+E9zoJ/+Yz7e1ta1KmRerj0wmsxTNYzN2QyaZr7z6uq1+o4Y4M+L4ONRjErqtQbiX8eMl4z30ebhBouj3YxFnRhxfDbpx6G6hvz5rf0VDmYZx3wxbNNHn8nGox6Q4KLdQ5+MmMO5ANTOMSWN81nMu78MahP5CyqxY8tqjjbHzTI8gWmwTSdoFN6mj5bQcScym3E2WwXyapG0KY0+5c1UtqsmtyzzmQfSuCaGtQg+aszq3JNcn4Q9EKjo/SnyCLBlKidqxPrM7Vm2yuH5F/CS2RMkG9a68apirSXYDSFyynH4tmMsY3GHLcX0tCN+/Vpfm/DjcD2nlgQ2uJzhus7l2ud2k4QlJ+41BrznvsBqz4u6je6e7YXk0p+A/a3AnJoin5oX7x5irSQKraSNjfiC/lzgUhBvkK+6qKYY7+snA/G4FM5tJd+42qu6v0qyatRoAE3Z4S7IpaMQkQV8kvUd0o/Wr4rf/FwjCr167zydIkCBBghn8BoQaL2dBKaBrAAAAAElFTkSuQmCC>

[image2]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABkAAAAXCAYAAAD+4+QTAAAB80lEQVR4Xu2UyytFURTGzw1FkcQl93XuKzcjdDMwkYQYkDDCXJkaKKUUJv4BJRN/gRETA2KiFBmgxIDECBOE8vitY+/btut6ZKJY9XX2/va3vrWfx3H+49dGKBQqcF23H8yBmVgslrI12QJ9JRhXuSOBQCBsa5x4PF7M4AqY9Pv9hdFotJb2Pui1tXZEIpFOdMtMqiaZTPrFA9yDHls4CrnFt0Rz9AfAAckVptYMJpOPZglcgzrh8IjTvgB7rKjME4qxFCBhwTQIh8P18Dd8u0zeDFVkETzRbhIuGAyG6J+B48wE6VSDS7sIxdPwt2Da5O2QQhiX0vSpfjs5z2Cebq4n0mbZitj8RyGrQL8uOyPtzIA6uBfb7DtFEolEOdoNtU3bcgkctTIvIDt+WsQMcprBHXkT6XQ6zyOzmWXjP4tUKlWkVvWER6tH6itnmxkHP2byZsj7khmjGXCM7REv2R15Gh4hjw9iDSwxmK+FCFrgHuWrOTHlSgccZajPE5yASuEMPzmCIZ0r4kFwykBMUT737eVuirEQck3p74IH0KDyZLVXYErvP7+nJP1zcPDuhomAhFkGVqnerQrs0a7VGjXDZXSH3B5X0TKZYdGCMfftL7EDjsxcM3zMugqTPkwaMzfjC6G2sU1yZXVQObbmP/5gvAJ/PJRsVLAAdQAAAABJRU5ErkJggg==>

[image3]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAD4AAAAXCAYAAABTYvy6AAAC80lEQVR4Xu2WT6hMURzH74Qi/xLTZP6dmWkyXhGaIkJvIbIgYfGWYkFS/rwQpVhaUN5KLwvSKwsLG0peemXHiqU/C3qRBSJPUc/z+Tnn6M5p7sy9c2+zcb/17d7zO7/zPb/f/Z17zvG8FClS/FeoaAy59rBQSi2HF+AoOpeKxWLd9QmDer2+qFwuH7c6tVptBeaM6xcLiA/Ao/AxnGaiW65PGFSr1fWMf1Qqlbbwvob3+3AGDnsRgjZjJ4hjkOSX8DxM+1dUna6QxBHfw3MTnOwlcSo7jyDvMf4gzVliKxQKS9F6im2KvqYzJBD4j0gB+IC7pS3J034GP0msrn9sKL1M3/aSuB0Lv0nFfPbzSlf9lN+/E/C9YsYcknaj0VjI+xNXOzHESbzZbM5h3DWq81B0rJ32WUlCnn7/ThCtfD6/zDMrh8qvQuMLnMhmswsc9/iIk3gAZqN3V+l9Y9DtDAPZ5Bg/xod7h8Zatz8RJJ04OhvQm4KjUkW3vxNyudx8kr0jCTP+DVo7PLMCEkeSiXP8LEZrHN6WJNz+KCCelei8T0KrLZJKXKpLpa6jdVV2e7e/B2RkucMZYjvidsZGEonbpNE455mlieYAG9R2x7UtzCZ5Uuj/PewmGSe2QHRLXHZUOZu94EuEVGZYgpZ3a6zoC8he2+6kI+e90vtCy9kvMUnicMTaONpyRucf5BfjI+c9n7Z8QHxV4D5jE4djnhOUTID9OfwJN/r7DDIEd4C+H3BSNiVL2p95bhanbjocYyXsr/C/KUnYMRV9EZIjbZ3YSKTB+0eZC1atXzttZe4FaFy0tr9gkm1GYFocDL/j+IJ/dLX4SJWwPYC/4ekWAa/lo9nxfn5gjloYHQH2nfA181+GQ0pffb+K3fqQZFHpJMftB7LazPVSKmx90Tih9JV3n7VFhvlIx1x7VHTTIdi5FX1X308SWwOXab9AIGdUmyUaFUnp9AVyTybYG3GPqKR0+gaqtEv+LdceFUnppEgRHn8Ahnrkn2V6EWIAAAAASUVORK5CYII=>
