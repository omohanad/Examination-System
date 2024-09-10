# Examination System
Power BI Development Track - Graduation Project

## Project Overview
This project involves constructing an automated system capable of performing automated exams and building a SQL database to support this system. In addition to a data warehpuse to support reporting services.

## 1. Requirements
Analyzing System Requirements: Determine the database entities, attributes, and relationships.

## 2. Preparation
- Designing the ERD: Create the Entity-Relationship Diagram for the database.
  
![ER Diagram drawio](https://github.com/user-attachments/assets/a1a641dc-0298-43ca-b995-35fdeed0cfd4)

  
- Implementing Mapping Roles: Build the database schema based on the ERD.

![Mapping drawio](https://github.com/user-attachments/assets/590ca7fe-d0c9-425b-8fa9-398f8de1c3fa)

- Applying Normalization: Ensure the database schema is correctly normalized.
- Database Development: Create tables, define attribute data types, constraints, and relationships.

  ![image](https://github.com/user-attachments/assets/47f4682f-bc6e-4ef0-8c76-0a6dc05e94c4)

- Generating Row Data: Use tools like Excel, ChatGPT, and Redgate Data Generator to populate the database.

  ![image](https://github.com/user-attachments/assets/b7379d83-967a-4c50-a683-c8be2a8ac133)

- Creating Stored Procedures (SPs): Created 137 stored procedures to manage SELECT, INSERT, UPDATE, and DELETE operations, for SSRS Reports, and Generating and submiting exams.

  ![image](https://github.com/user-attachments/assets/19703c65-6deb-4b55-b8e5-3fa3e7559170)

  ![image](https://github.com/user-attachments/assets/f0f9f191-1c26-41d7-8836-14abef511508)

  ![image](https://github.com/user-attachments/assets/eeaff045-81d6-49fb-ad61-2dd47cee0726)


- Creating an ETL Pipeline: Use SSIS to build the data warehouse Fact and Dimensions tables.

![Screenshot 2024-09-07 035201](https://github.com/user-attachments/assets/07636fa8-f586-42a8-a046-d9266ff6b42e)

![image](https://github.com/user-attachments/assets/7f5796f5-7527-4b66-85ee-b1028c8a1771)

- Building a Desktop Application: Develop an application for students to take exams, leveraging the SPs for exam generation and answer submissions. [Check Repo.](https://github.com/AbdEl-RhmanMohamad/Exam-App)

  ![image](https://github.com/user-attachments/assets/9d3db0a8-670d-47cc-a5a0-77ace14614f6)

## 3. Sharing
- Creating Paginated Reports: Use SSRS and Power BI Report Builder to create reports leveraging the SPs.
  
![image](https://github.com/user-attachments/assets/8ab5f78c-f770-4c09-885b-baf88d46e2e9)

- Using Power BI: Analyze, clean, and build dashboards to share insights.

 ![image](https://github.com/user-attachments/assets/889c667b-72a1-4f28-af19-eb5639fec174)
 
