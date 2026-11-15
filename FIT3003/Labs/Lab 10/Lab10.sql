DROP TABLE GLUALB;

CREATE TABLE GLUALB (
    PatientID CHAR(1) NOT NULL PRIMARY KEY,
    Glucose NUMBER(5,1),
    Albumin NUMBER(3,1),
    MortalityPrediction NUMBER(12,10)
);

INSERT ALL
    INTO GLUALB (PatientID, Glucose, Albumin, MortalityPrediction)
    VALUES ('A', 162.2, 3.5, 0.573189504)

    INTO GLUALB (PatientID, Glucose, Albumin, MortalityPrediction)
    VALUES ('B', 93.7, 2.9, 0.22)

    INTO GLUALB (PatientID, Glucose, Albumin, MortalityPrediction)
    VALUES ('C', 68.5, 2.6, 0.217082562)

    INTO GLUALB (PatientID, Glucose, Albumin, MortalityPrediction)
    VALUES ('D', 155.0, 3.0, 0.534815242)

    INTO GLUALB (PatientID, Glucose, Albumin, MortalityPrediction)
    VALUES ('E', 121.0, 4.5, 0.475139465)

    INTO GLUALB (PatientID, Glucose, Albumin, MortalityPrediction)
    VALUES ('F', 198.0, 2.2, 0.969279952)

    INTO GLUALB (PatientID, Glucose, Albumin, MortalityPrediction)
    VALUES ('G', 99.1, 4.1, 0.552492172)

    INTO GLUALB (PatientID, Glucose, Albumin, MortalityPrediction)
    VALUES ('H', 180.2, 5.0, 0.752011091)

    INTO GLUALB (PatientID, Glucose, Albumin, MortalityPrediction)
    VALUES ('I', 169.0, 3.4, 0.799263517)

    INTO GLUALB (PatientID, Glucose, Albumin, MortalityPrediction)
    VALUES ('J', 64.9, 2.6, 0.383771494)

    INTO GLUALB (PatientID, Glucose, Albumin, MortalityPrediction)
    VALUES ('K', 72.1, 3.9, 0.45)

    INTO GLUALB (PatientID, Glucose, Albumin, MortalityPrediction)
    VALUES ('L', 155.0, 4.6, 0.862259153)

    INTO GLUALB (PatientID, Glucose, Albumin, MortalityPrediction)
    VALUES ('M', 218.0, 3.8, 0.99)

    INTO GLUALB (PatientID, Glucose, Albumin, MortalityPrediction)
    VALUES ('N', 146.0, 4.5, 0.813710339)

    INTO GLUALB (PatientID, Glucose, Albumin, MortalityPrediction)
    VALUES ('P', 91.9, 2.6, 0.496873792)

    INTO GLUALB (PatientID, Glucose, Albumin, MortalityPrediction)
    VALUES ('Q', 200.0, 4.6, 0.745266898)

    INTO GLUALB (PatientID, Glucose, Albumin, MortalityPrediction)
    VALUES ('R', 70.3, 2.0, 0.132516482)
SELECT 1 FROM dual;

SELECT SLOPE, Y_BAR_MAX - (SLOPE * X_BAR_MAX) AS INTERCEPT
FROM (
    SELECT SUM((GLUCOSE-X_BAR)*(ALBUMIN-Y_BAR))/SUM((GLUCOSE-X_BAR)*(GLUCOSE-X_BAR)) AS SLOPE,
        MAX(X_BAR) AS X_BAR_MAX,
        MAX(Y_BAR) AS Y_BAR_MAX
    FROM (
        SELECT AVG(GLUCOSE) AS X_BAR, AVG(ALBUMIN) AS Y_BAR
        FROM GLUALB
    ) AV, GLUALB
);

CREATE TABLE AGEWBC (
    Age NUMBER(4, 1),
    WBC NUMBER(4, 1)
);

INSERT ALL
    INTO AgeWBC (Age, WBC) VALUES (74, 27)
    INTO AgeWBC (Age, WBC) VALUES (56.3, 8.6)
    INTO AgeWBC (Age, WBC) VALUES (55.9, 8.5)
    INTO AgeWBC (Age, WBC) VALUES (80.4, 9.2)
    INTO AgeWBC (Age, WBC) VALUES (56.8, 7.8)
    INTO AgeWBC (Age, WBC) VALUES (29.8, 18.2)
    INTO AgeWBC (Age, WBC) VALUES (19.1, 12.2)
    INTO AgeWBC (Age, WBC) VALUES (32.7, 19)
    INTO AgeWBC (Age, WBC) VALUES (28.3, 37.3)
    INTO AgeWBC (Age, WBC) VALUES (73.8, 41.5)
    INTO AgeWBC (Age, WBC) VALUES (62.7, 30.2)
    INTO AgeWBC (Age, WBC) VALUES (25.7, 16.6)
    INTO AgeWBC (Age, WBC) VALUES (66, 17.6)
    INTO AgeWBC (Age, WBC) VALUES (64.9, 16)
    INTO AgeWBC (Age, WBC) VALUES (37.2, 16.1)
    INTO AgeWBC (Age, WBC) VALUES (94.6, 4.7)
    INTO AgeWBC (Age, WBC) VALUES (39.7, 8.4)
    INTO AgeWBC (Age, WBC) VALUES (29.9, 9.7)
    INTO AgeWBC (Age, WBC) VALUES (48, 5.4)
    INTO AgeWBC (Age, WBC) VALUES (42, 24.4)
    INTO AgeWBC (Age, WBC) VALUES (71.5, 19.5)
    INTO AgeWBC (Age, WBC) VALUES (47.4, 18.3)
    INTO AgeWBC (Age, WBC) VALUES (24.9, 17.7)
    INTO AgeWBC (Age, WBC) VALUES (50.8, 6)
    INTO AgeWBC (Age, WBC) VALUES (45.3, 20.9)
    INTO AgeWBC (Age, WBC) VALUES (76.7, 2.5)
    INTO AgeWBC (Age, WBC) VALUES (55.7, 12.1)
    INTO AgeWBC (Age, WBC) VALUES (86.8, 7.3)
    INTO AgeWBC (Age, WBC) VALUES (83.5, 8.4)
    INTO AgeWBC (Age, WBC) VALUES (84.4, 18)
    INTO AgeWBC (Age, WBC) VALUES (18.7, 26)
    INTO AgeWBC (Age, WBC) VALUES (85, 9.6)
    INTO AgeWBC (Age, WBC) VALUES (57.3, 9.8)
    INTO AgeWBC (Age, WBC) VALUES (80.6, 6.9)
    INTO AgeWBC (Age, WBC) VALUES (65.8, 23.2)
    INTO AgeWBC (Age, WBC) VALUES (67.9, 14.8)
    INTO AgeWBC (Age, WBC) VALUES (84.9, 9.2)
    INTO AgeWBC (Age, WBC) VALUES (67.1, 6.8)
    INTO AgeWBC (Age, WBC) VALUES (51.1, 21.9)
    INTO AgeWBC (Age, WBC) VALUES (88.6, 8.4)
    INTO AgeWBC (Age, WBC) VALUES (29.8, 10)
    INTO AgeWBC (Age, WBC) VALUES (65, 14.9)
    INTO AgeWBC (Age, WBC) VALUES (74, 11)
    INTO AgeWBC (Age, WBC) VALUES (78.9, 16.7)
    INTO AgeWBC (Age, WBC) VALUES (53.4, 6)
    INTO AgeWBC (Age, WBC) VALUES (86, 6.5)
    INTO AgeWBC (Age, WBC) VALUES (71.8, 14.5)
    INTO AgeWBC (Age, WBC) VALUES (54.7, 12.3)
    INTO AgeWBC (Age, WBC) VALUES (90.9, 21.9)
SELECT 1 FROM dual;

SELECT SLOPE, Y_BAR_MAX -(SLOPE*X_BAR_MAX) AS INTERCEPT
FROM (

SELECT SUM((AGE-X_BAR)*(WBC-Y_BAR))/SUM((AGE-X_BAR)*(AGE-X_BAR)) AS SLOPE,
    MAX(X_BAR) AS X_BAR_MAX,
    MAX(Y_BAR) AS Y_BAR_MAX
FROM (

SELECT AVG(AGE) AS X_BAR, AVG(WBC) AS Y_BAR
FROM AGEWBC

) AV, AGEWBC

);


CREATE TABLE JunkDim AS
SELECT
    E.Ensuite,
    P.Pool,
    A.Aspect_Facing,
    S.Spa
FROM
    (SELECT DISTINCT Ensuite FROM Property) E
CROSS JOIN
    (SELECT DISTINCT Pool FROM Property) P
CROSS JOIN
    (SELECT DISTINCT Aspect_Facing FROM Property) A
CROSS JOIN
    (SELECT DISTINCT Spa FROM Property) S;