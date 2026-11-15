DESC user_objects;

SELECT OBJECT_NAME
FROM user_objects
WHERE OBJECT_TYPE = 'PROCEDURE';

SELECT OBJECT_NAME
FROM user_objects
WHERE OBJECT_TYPE = 'TABLE';

DESC user_source;

SELECT NAME,TYPE,LINE
FROM user_source
WHERE TYPE = 'PROCEDURE';

DESC user_errors;

SELECT NAME,TYPE,LINE
FROM user_errors
WHERE TYPE = 'PROCEDURE';

SET SERVEROUTPUT ON;

BEGIN
DBMS_OUTPUT.PUT_LINE('hello World');
END;
/

DECLARE
v_str VARCHAR2(20):='Hello World';
v_today DATE;
BEGIN
DBMS_OUTPUT.PUT_LINE(v_str);
v_today := SYSDATE;
DBMS_OUTPUT.PUT_LINE('Today is.. ' || v_today);
END;
/

CREATE TABLE lab11_ans
(QuestionID VARCHAR2(20),
Question VARCHAR2 (400),
N_responses NUMBER,
Sum_score NUMBER,
Avg_score NUMBER,
Avg_Label VARCHAR2 (10));

-- Task 2 -------------------------------------

SELECT * 
FROM DEI_SURVEY.EMPLOYEE E, DEI_SURVEY.EMPLOYMENT EE, DEI_SURVEY.DIVISION D
WHERE E.ID = EE.ID AND EE.DIVISION_ID = D.DIVISION_ID;

-- Creating the procedure to list all IT employees
CREATE OR REPLACE PROCEDURE LIST_EMPLOYEES_IT AS
BEGIN
    FOR r IN (
        SELECT E.ID, E.NAME, E.SURNAME, E.EMAIL, EE.MANAGER
        FROM DEI_SURVEY.EMPLOYEE E, DEI_SURVEY.EMPLOYMENT EE, DEI_SURVEY.DIVISION D
        WHERE E.ID = EE.ID AND EE.DIVISION_ID = D.DIVISION_ID AND D.DIVISION = 'IT'
    )
    LOOP 
        DBMS_OUTPUT.PUT_LINE(r.ID || ' ' || r.NAME || ' ' || r.SURNAME || ' ' || r.EMAIL || ' ' || r.MANAGER);
    END LOOP;
END LIST_EMPLOYEES_IT;

EXEC LIST_EMPLOYEES_IT;

SELECT * FROM DEI_SURVEY.RESPONSE R JOIN DEI_SURVEY.DEI_QUESTION Q ON R.QUESTION_ID = Q.QUESTION_ID;


-- Use PL/SQL to create the average survey score across all questions and average per category. 
-- The output should display a label based on the following ranges:
--      Neutral if the average score is between -0.5 and 0.5 (inclusive),
--      Agree if the average score is greater than 0.5,
--      Disagree if the average score is less than -0.5.
-- Including question_id, question, number of responses, total score, average score, and average score label.

-- Just making the query first
SELECT Q.QUESTION_ID, Q.QUESTIONS, 
    COUNT(*) AS N_RESPONSES, 
    SUM(R.RESPONSEVALUE) AS SUM_SCORE,
    SUM(R.RESPONSEVALUE)/COUNT(*) AS AVG_SCORE,
    CASE
        WHEN SUM(R.RESPONSEVALUE)/COUNT(*) > 0.5 THEN 'Agree'
        WHEN SUM(R.RESPONSEVALUE)/COUNT(*) < -0.5 THEN 'Disagree'
        ELSE 'Neutral'
    END AS AVG_LABEL
FROM DEI_SURVEY.RESPONSE R JOIN DEI_SURVEY.DEI_QUESTION Q ON R.QUESTION_ID = Q.QUESTION_ID
GROUP BY Q.QUESTION_ID, Q.QUESTIONS;


CREATE OR REPLACE PROCEDURE SURVEY_REPORT1 AS
BEGIN
    FOR R IN (
        SELECT Q.QUESTION_ID, Q.QUESTIONS, 
            COUNT(*) AS N_RESPONSES, 
            SUM(R.RESPONSEVALUE) AS SUM_SCORE,
            SUM(R.RESPONSEVALUE)/COUNT(*) AS AVG_SCORE,
            CASE
                WHEN SUM(R.RESPONSEVALUE)/COUNT(*) > 0.5 THEN 'Agree'
                WHEN SUM(R.RESPONSEVALUE)/COUNT(*) < -0.5 THEN 'Disagree'
                ELSE 'Neutral'
            END AS AVG_LABEL
        FROM DEI_SURVEY.RESPONSE R JOIN DEI_SURVEY.DEI_QUESTION Q ON R.QUESTION_ID = Q.QUESTION_ID
        GROUP BY Q.QUESTION_ID, Q.QUESTIONS
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE(R.QUESTION_ID|| ' ' ||R.QUESTIONS|| ' ' ||R.N_RESPONSES|| ' ' ||R.SUM_SCORE|| ' ' ||R.AVG_SCORE|| ' ' ||R.AVG_LABEL);
    END LOOP;
END SURVEY_REPORT1;

EXEC SURVEY_REPORT1;

-- Modifying to put the new data into the lab11_ans table
CREATE OR REPLACE PROCEDURE SURVEY_REPORT AS
BEGIN
    FOR R IN (
        SELECT Q.QUESTION_ID, Q.QUESTIONS, 
            COUNT(*) AS N_RESPONSES, 
            SUM(R.RESPONSEVALUE) AS SUM_SCORE,
            SUM(R.RESPONSEVALUE)/COUNT(*) AS AVG_SCORE,
            CASE
                WHEN SUM(R.RESPONSEVALUE)/COUNT(*) > 0.5 THEN 'Agree'
                WHEN SUM(R.RESPONSEVALUE)/COUNT(*) < -0.5 THEN 'Disagree'
                ELSE 'Neutral'
            END AS AVG_LABEL
        FROM DEI_SURVEY.RESPONSE R JOIN DEI_SURVEY.DEI_QUESTION Q ON R.QUESTION_ID = Q.QUESTION_ID
        GROUP BY Q.QUESTION_ID, Q.QUESTIONS
    )
    LOOP
        INSERT INTO lab11_ans (QUESTIONID, QUESTION, N_RESPONSES, SUM_SCORE, AVG_SCORE, AVG_LABEL)
            VALUES (R.QUESTION_ID, R.QUESTIONS, R.N_RESPONSES, R.SUM_SCORE, R.AVG_SCORE, R.AVG_LABEL);
    END LOOP;
END SURVEY_REPORT;

SELECT * FROM lab11_ans;

EXEC SURVEY_REPORT;

SELECT * FROM lab11_ans;


-- Task 3 -------------------------------------

CREATE TABLE LAB11DIVISION AS SELECT * FROM DEI_SURVEY.DIVISION;
CREATE TABLE LAB11EMPLOYMENT AS SELECT * FROM DEI_SURVEY.EMPLOYMENT;
CREATE TABLE LAB11EMPLOYEE AS SELECT * FROM DEI_SURVEY.EMPLOYEE;
CREATE TABLE LAB11IDENTITY AS SELECT * FROM DEI_SURVEY.IDENTITY;
CREATE TABLE LAB11BACKGROUND AS SELECT * FROM DEI_SURVEY.BACKGROUND;
CREATE TABLE LAB11RESPONSE AS SELECT * FROM DEI_SURVEY.RESPONSE;
CREATE TABLE LAB11DEI_QUESTION AS SELECT * FROM DEI_SURVEY.DEI_QUESTION;

CREATE OR REPLACE TRIGGER LAB11RESPONSE_TRIGGER
    AFTER INSERT ON LAB11RESPONSE
    FOR EACH ROW
BEGIN
    UPDATE lab11_ans
    SET N_RESPONSES = N_RESPONSES + 1,
        SUM_SCORE = SUM_SCORE + :NEW.RESPONSEVALUE,
        AVG_SCORE = (SUM_SCORE + :NEW.RESPONSEVALUE) / (N_RESPONSES + 1),
        AVG_LABEL = CASE
            WHEN (SUM_SCORE + :NEW.RESPONSEVALUE) / (N_RESPONSES + 1) > 0.5 THEN 'Agree'
            WHEN (SUM_SCORE + :NEW.RESPONSEVALUE) / (N_RESPONSES + 1) < -0.5 THEN 'Disagree'
            ELSE 'Neutral'
        END
    WHERE QUESTIONID = :NEW.QUESTION_ID;
END LAB11RESPONSE_TRIGGER;

SELECT * FROM lab11_ans;

insert into LAB11EMPLOYEE
values('201',	'Alessandra',	'Callan', 'Alessandra', to_date('5/1/1990','DD/MM/YY'),32,'Canadian','Alessandra.Callan@mail.ca','243 779 6459');

insert into LAB11IDENTITY
values('201','Female','She/her/hers','Heterosexual','No');

insert into LAB11BACKGROUND
values('201','No','No','No','White','No');

insert into LAB11EMPLOYMENT
values('201','D4','No');

insert into LAB11RESPONSE
values('201','Aug_D_Q1','Disagree',2);
insert into LAB11RESPONSE
values('201','Aug_D_Q2','Disagree',-1);
insert into LAB11RESPONSE
values('201','Aug_D_Q3','Disagree',1);
insert into LAB11RESPONSE
values('201','Aug_D_Q4','Disagree',1);
insert into LAB11RESPONSE
values('201','Aug_D_Q5','Disagree',2);
insert into LAB11RESPONSE
values('201','Aug_E_Q1','Disagree',-2);
insert into LAB11RESPONSE
values('201','Aug_E_Q2','Disagree',2);
insert into LAB11RESPONSE
values('201','Aug_E_Q3','Disagree',1);
insert into LAB11RESPONSE
values('201','Aug_E_Q4','Disagree',-1);
insert into LAB11RESPONSE
values('201','Aug_E_Q5','Disagree',1);
insert into LAB11RESPONSE
values('201','Aug_I_Q1','Disagree',-2);
insert into LAB11RESPONSE
values('201','Aug_I_Q2','Disagree',2);
insert into LAB11RESPONSE
values('201','Aug_I_Q3','Disagree',1);
insert into LAB11RESPONSE
values('201','Aug_I_Q4','Disagree',0);
insert into LAB11RESPONSE
values('201','Aug_I_Q5','Disagree',2);

SELECT * FROM lab11_ans;
