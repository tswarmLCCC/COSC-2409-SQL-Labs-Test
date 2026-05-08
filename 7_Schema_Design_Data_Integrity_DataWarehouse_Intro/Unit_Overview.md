# **Unit 7: Schema Design & Data Integrity**

## **Unit Overview & Objectives**

This unit shifts our focus from the **logic of retrieval** to the **architecture of storage**. As an Analytical Engineer, your ability to write complex queries is essentially a temporary "patch" if the underlying data is corrupted, undocumented, or "flat." We will explore how to design databases that act as self-governing systems—enforcing business rules through code and maintaining a perfect, immutable historical record.

In the modern data stack, the schema is your first line of defense against "Data Swamps." We are moving beyond just "making it work" to a philosophy of "Data as a Product," where structural integrity is a non-negotiable feature.

**Learning Objectives:**

* **Architect Structural Integrity:** Utilize CREATE TABLE and ALTER TABLE to build resilient schemas that adapt to evolving business requirements without causing downstream breaks or data loss.  
* **Implement the "Immune System" of Data:** Mastery of Constraints (PK, FK, CHECK, UNIQUE, NOT NULL) to prevent "garbage-in, garbage-out" scenarios at the point of ingestion, reducing the need for expensive downstream cleaning.  
* **Solve the Semi-Structured Dilemma:** Evaluate the trade-offs between rigid schemas (Text/Numeric) and flexible schemas (JSONB) for modern application data, specifically focusing on the performance costs of indexing nested data.  
* **Establish Data Lineage:** Leverage COMMENT and metadata strategies to prove data provenance—proving *where* data came from so AI outputs can be audited for regulatory compliance and stakeholder trust.  
* **Model for Performance:** Design Dimensional Models (Star Schemas) consisting of Fact and Dimension tables to optimize analytical throughput and minimize "Join Bloat."  
* **Master the Time Machine:** Implement Slowly Changing Dimensions (SCD) Type 2 to ensure the database can "time travel" and represent data exactly as it existed on any specific historical date, preserving the "Truth of the Moment."

## **The Problem: The Fragile Schema & The Historical Void**

In academic environments, data is usually "clean" and static. In the real world, you face two catastrophic architectural failures that can bankrupt a data project and destroy the credibility of an engineering team:

### **1\. The "Garbage-In" Syndrome (Integrity Failure)**

**The Problem:** Without constraints, a database is just a fancy, shared Excel sheet. If a "Vitals" table allows a human heart rate of 900 BPM or a "Price" table allows a negative cost, the database has failed its primary mission of being a "Single Source of Truth."

**The Consequences:** Bad data in a schema leads to "Silent Failures." Your queries run without errors, and your dashboards look beautiful, but the *answers* they provide are fundamentally wrong. This leads to "Insight Hallucinations," where business decisions are made based on sensor glitches or human typos.

**The Solution:** **Strong Typing and Constraints**. We treat the schema as the "Immune System." By using CHECK and FOREIGN KEY constraints, we force the data to prove its validity before it is allowed to occupy space on the disk.

### **2\. The "Historical Void" (The Overwrite Problem)**

**The Problem:** Standard databases are "destructive" by default. In a traditional "Update" model, if a user changes their address or a product changes its price, the old value is overwritten and lost forever.

**The Consequences:** This creates a "Historical Void." If you run a sales report for 2023 using 2024 prices (because the 2023 prices were overwritten), your revenue figures will be mathematically incorrect. You cannot audit what you did not preserve.

**The Solution:** **SCD Type 2**. We solve this by moving from "destructive updates" to "versioned inserts." By adding "valid-from" and "valid-to" timestamps, we preserve the historical lineage of every attribute, allowing for "Point-in-Time" reporting.

## **1\. Data Modeling: Types and Identity**

Choosing the right data type is your first act of optimization. It affects storage costs, query speed, and—most importantly—mathematical accuracy.

### **Precision vs. Speed**

* **Structured (Numeric/Decimal):** High performance, strict enforcement. For monetary values, **never** use FLOAT or REAL. These are approximate types based on binary floating-point math.  
  * *Example:* In binary floating-point, ![][image1] often does not equal ![][image2] precisely. In a financial system processing millions of transactions, these "rounding crumbs" can result in thousands of dollars in unaccounted discrepancies. Always use NUMERIC(precision, scale).  
* **Semi-Structured (JSONB):** This is "Schema-on-Read." It is highly flexible for data that changes frequently, such as user preferences or raw API responses. However, you lose the ability to easily enforce NOT NULL or CHECK constraints on internal fields.

### **The Identity Crisis: Serial vs. UUID**

How we identify rows (Primary Keys) defines our data's scalability and security:

* **SERIAL (Integers):** Simple, fast, and easy to read. However, they are predictable. If your user ID is 1005, you know user 1006 likely exists. This is an "Insecure Direct Object Reference" (IDOR) risk.  
* **UUID (Universally Unique Identifier):** A 128-bit label that is virtually guaranteed to be unique across all systems.  
  * **Analytical Context:** Use UUIDs for public-facing identifiers to prevent ID-guessing. While they are slightly slower to join than integers, they allow you to merge data from two different servers without ever worrying about "ID Collisions."

## **2\. Dimensional Modeling: Facts and Dimensions**

To make data readable for humans and fast for computers, we use the **Star Schema**. This is the process of "Denormalization"—purposefully organizing data for analytical speed.

### **Dimension Tables (The Context)**

Dimension tables contain descriptive attributes—the "Who, What, Where, When, and Why."

* **Characteristics:** Dimension tables are "wide" (many columns) and contain highly descriptive text.  
* *Example:* dim\_students contains the student's name, major, veteran status, and scholarship type. These provide the **context** required for filtering and grouping.

### **Fact Tables (The Metrics)**

Fact tables contain the quantitative measurements (metrics) of a business process.

* **Characteristics:** Fact tables are "narrow" (few columns) but extremely "long" (millions/billions of rows). They consist mostly of foreign keys pointing to dimensions and the numeric measures themselves.  
* **Factless Fact Tables:** These track the *occurrence* of an event without a numeric measure (e.g., an attendance log where the "fact" is simply that the student showed up).  
* **The Performance Tax:** Every Foreign Key in a Fact table **must** have an Index. Without indexes, joining a Fact table of 10 million rows to a Dimension table will require a "Sequential Scan" (reading the entire disk), which will cripple your performance.

## **3\. Implementation: Slowly Changing Dimensions (SCD Type 2\)**

SCD Type 2 is how we achieve **Historical Integrity**. It transforms a static table into a "Bitemporal" ledger.

**The Lifecycle of a Record Change:**

1. **Initial State:** A student is a "CS Major." The row has effective\_start \= 2023-01-01, effective\_end \= NULL, and is\_current \= TRUE.  
2. **The Change:** The student switches to "Business" on 2024-01-01.  
3. **The Retirement:** We do not delete the CS row. We update it: effective\_end \= 2024-01-01 and is\_current \= FALSE.  
4. **The New Version:** We insert a brand new row for the "Business" major with effective\_start \= 2024-01-01 and effective\_end \= NULL.

**The Audit Consequence:** When you run a "Credits per Major" report for the year 2023, this student’s credits will be correctly attributed to the CS department. If you run the report for 2024, they will be attributed to Business. This is "Point-in-Time" accuracy.

## **4\. Bonus: Practical Applications**

### **Healthcare Record Auditing (Biological Constraints)**

In clinical environments, data integrity is a safety feature. We use CHECK constraints to ensure sensors or human input aren't providing "impossible" data that could trigger false alarms or incorrect prescriptions.

ALTER TABLE patient\_vitals   
ADD CONSTRAINT vitals\_plausibility\_check   
CHECK (  
    (heart\_rate BETWEEN 20 AND 250\) AND  
    (body\_temp\_f BETWEEN 90 AND 110\) AND  
    (systolic\_bp \> 40\)  
);

### **Data Lineage for AI Governance**

As AI agents (LLMs) begin to write queries against our databases, they need to know which tables are "Certified" and where they came from.

COMMENT ON TABLE dim\_products IS 'Source: Master Catalog API. Certified by: Supply Chain Team. Data Lineage: Updated nightly.';  
COMMENT ON COLUMN dim\_products.sku IS 'Unique stock keeping unit. Format: AAA-999-BB.';

This metadata is consumed by AI tools to ensure they don't use "stale" or "raw" tables for executive reporting.

## **Student Exercises**

1. **The Constraint Shield:** Create a career\_postings table. Implement a CHECK constraint ensuring salary\_min \< salary\_max, a NOT NULL constraint on company\_name, and a UNIQUE constraint on the job\_reference\_code.  
2. **The Star Schema Design:** Identify one Fact and two Dimensions for a "Hospital Pharmacy System." Write the CREATE TABLE statement for the Fact table, ensuring you include Foreign Keys with proper REFERENCES clauses and INDEX declarations.  
3. **The Time Machine:** Write the SQL logic to "retire" a user's old subscription tier (e.g., 'Free') and "activate" a new one ('Premium') using SCD Type 2 logic.

## **Instructor Unit Notes**

* **The JSONB Performance Tax:** Remind students that while JSONB is flexible, it cannot enforce the "Structural Integrity" required for financial or medical data. It is for *attributes*, not *entities*.  
* **Identity Obfuscation:** Discuss the security benefits of UUIDs. In a world of scrapers, incremental integer IDs are a roadmap for data theft.  
* **SCD Storage Trade-off:** SCD Type 2 "bloats" the database. For every change, a new row is added. Students must understand that they are trading disk space for the ability to perform historical audits.  
* **The "NULL" vs. "High Date" Debate:** While some use 9999-12-31 for current records, explain that NULL is more idiomatic in PostgreSQL and allows for "Partial Indexes" (e.g., CREATE INDEX ... WHERE effective\_end IS NULL), which significantly accelerates queries for "current" data.

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEkAAAAXCAYAAABH92JbAAADTklEQVR4Xu2XP2gUQRjF71BBURCReHi5u727iJLKyKlBUbEQIYIiaiFRRGy0sFADEQOCElIoKMRGSRfEzsImgn/AgI2ojYUKWogSTGUKUcFA0N/LzmyGyS3n5eCisg8+dvfN+2bmezu7O5tKJUiQIMFfiFwutyQIgm5iiLhaKpXW+ZpaIG9DPp/f7fPNguasuZsaulWTr6kGtKuJi8orFouXyVvja1Llcnk5gkdEf0tLyzKEHZy/IQ76Wh9oOwuFQi/aF8Qvzs/7mmZAc9WcNXfVoFpUk2rztS4wdrN03NztnK/nfER1ED00pyOhClORHFdYjusjxFsSM5GwCoxJe9HuIb43YhJ9naGPLp+vhWw2myfvveZsOdWimojTrtaFVhq6e2hOcLlAXGtr60rm8dzUUpkW2s5oGHY7wNlN8N847nP5OKjDRk1Srgz3+VowN3SmqBBpuDvEqFaWw0cIwsfsI/FVq8jh+4JwNZ2zRDvxxTfJFk0MuHwc5tmkG1VM0sochh+HL7u8RaVSWYRmkPYHMszymodMimqxxcWZ5PNxmE+TjBlxJs3ia2AhOXeJKfJ3TjOalFzzzfhXTDIv6dFqZszFJHI6lUMMaaVNk1x0NdskDa4PQhC+E9zoJ/+Yz7e1ta1KmRerj0wmsxTNYzN2QyaZr7z6uq1+o4Y4M+L4ONRjErqtQbiX8eMl4z30ebhBouj3YxFnRhxfDbpx6G6hvz5rf0VDmYZx3wxbNNHn8nGox6Q4KLdQ5+MmMO5ANTOMSWN81nMu78MahP5CyqxY8tqjjbHzTI8gWmwTSdoFN6mj5bQcScym3E2WwXyapG0KY0+5c1UtqsmtyzzmQfSuCaGtQg+aszq3JNcn4Q9EKjo/SnyCLBlKidqxPrM7Vm2yuH5F/CS2RMkG9a68apirSXYDSFyynH4tmMsY3GHLcX0tCN+/Vpfm/DjcD2nlgQ2uJzhus7l2ud2k4QlJ+41BrznvsBqz4u6je6e7YXk0p+A/a3AnJoin5oX7x5irSQKraSNjfiC/lzgUhBvkK+6qKYY7+snA/G4FM5tJd+42qu6v0qyatRoAE3Z4S7IpaMQkQV8kvUd0o/Wr4rf/FwjCr167zydIkCBBghn8BoQaL2dBKaBrAAAAAElFTkSuQmCC>

[image2]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABkAAAAXCAYAAAD+4+QTAAAB80lEQVR4Xu2UyytFURTGzw1FkcQl93XuKzcjdDMwkYQYkDDCXJkaKKUUJv4BJRN/gRETA2KiFBmgxIDECBOE8vitY+/btut6ZKJY9XX2/va3vrWfx3H+49dGKBQqcF23H8yBmVgslrI12QJ9JRhXuSOBQCBsa5x4PF7M4AqY9Pv9hdFotJb2Pui1tXZEIpFOdMtMqiaZTPrFA9yDHls4CrnFt0Rz9AfAAckVptYMJpOPZglcgzrh8IjTvgB7rKjME4qxFCBhwTQIh8P18Dd8u0zeDFVkETzRbhIuGAyG6J+B48wE6VSDS7sIxdPwt2Da5O2QQhiX0vSpfjs5z2Cebq4n0mbZitj8RyGrQL8uOyPtzIA6uBfb7DtFEolEOdoNtU3bcgkctTIvIDt+WsQMcprBHXkT6XQ6zyOzmWXjP4tUKlWkVvWER6tH6itnmxkHP2byZsj7khmjGXCM7REv2R15Gh4hjw9iDSwxmK+FCFrgHuWrOTHlSgccZajPE5yASuEMPzmCIZ0r4kFwykBMUT737eVuirEQck3p74IH0KDyZLVXYErvP7+nJP1zcPDuhomAhFkGVqnerQrs0a7VGjXDZXSH3B5X0TKZYdGCMfftL7EDjsxcM3zMugqTPkwaMzfjC6G2sU1yZXVQObbmP/5gvAJ/PJRsVLAAdQAAAABJRU5ErkJggg==>
