/*
  Validation and demonstration queries for Assignment2STAR.sql.

  Expected result conventions:
  - every MISMATCH_ROWS value should be 0;
  - bridge-weight checks should return no rows;
  - all listed constraints should be ENABLED and VALIDATED; and
  - source and warehouse totals should match.
*/

/* ========================================================================== */
/* 1. SHOW THE CREATED TABLE STRUCTURES                                       */
/* ========================================================================== */

SELECT Table_Name,
       Column_ID,
       Column_Name,
       Data_Type,
       Data_Length,
       Data_Precision,
       Data_Scale,
       Nullable
FROM User_Tab_Columns
WHERE Table_Name IN
(
    'BOOKINGMONTHDIM', 'FACULTYDIM', 'AGEGROUPDIM', 'CARBODYDIM',
    'MAINTENANCETYPEDIM', 'MAINTENANCETEAMDIM', 'RESEARCHCENTERDIM',
    'TEAMCENTERBRIDGE', 'CARDIM', 'ZONEDIM', 'ERRORDIM',
    'DAMAGESEVERITYDIM', 'BOOKINGFACT', 'MAINTENANCEFACT', 'ACCIDENTFACT'
)
ORDER BY Table_Name, Column_ID;

/* All PK/FK constraints should be ENABLED and VALIDATED. */
SELECT Table_Name,
       Constraint_Name,
       Constraint_Type,
       Status,
       Validated
FROM User_Constraints
WHERE Table_Name IN
(
    'BOOKINGMONTHDIM', 'FACULTYDIM', 'AGEGROUPDIM', 'CARBODYDIM',
    'MAINTENANCETYPEDIM', 'MAINTENANCETEAMDIM', 'RESEARCHCENTERDIM',
    'TEAMCENTERBRIDGE', 'CARDIM', 'ZONEDIM', 'ERRORDIM',
    'DAMAGESEVERITYDIM', 'BOOKINGFACT', 'MAINTENANCEFACT', 'ACCIDENTFACT'
)
AND Constraint_Type IN ('P', 'R')
ORDER BY Table_Name, Constraint_Type, Constraint_Name;

/* ========================================================================== */
/* 2. QUICK ROW COUNTS                                                        */
/* ========================================================================== */

SELECT 'BOOKINGMONTHDIM' AS Table_Name, COUNT(*) AS Row_Count FROM BookingMonthDIM
UNION ALL
SELECT 'FACULTYDIM',             COUNT(*) FROM FacultyDIM
UNION ALL
SELECT 'AGEGROUPDIM',            COUNT(*) FROM AgeGroupDIM
UNION ALL
SELECT 'CARBODYDIM',             COUNT(*) FROM CarBodyDIM
UNION ALL
SELECT 'MAINTENANCETYPEDIM',     COUNT(*) FROM MaintenanceTypeDIM
UNION ALL
SELECT 'MAINTENANCETEAMDIM',     COUNT(*) FROM MaintenanceTeamDIM
UNION ALL
SELECT 'RESEARCHCENTERDIM',      COUNT(*) FROM ResearchCenterDIM
UNION ALL
SELECT 'TEAMCENTERBRIDGE',       COUNT(*) FROM TeamCenterBridge
UNION ALL
SELECT 'CARDIM',                 COUNT(*) FROM CarDIM
UNION ALL
SELECT 'ZONEDIM',                COUNT(*) FROM ZoneDIM
UNION ALL
SELECT 'ERRORDIM',               COUNT(*) FROM ErrorDIM
UNION ALL
SELECT 'DAMAGESEVERITYDIM',      COUNT(*) FROM DamageSeverityDIM
UNION ALL
SELECT 'BOOKINGFACT',            COUNT(*) FROM BookingFact
UNION ALL
SELECT 'MAINTENANCEFACT',        COUNT(*) FROM MaintenanceFact
UNION ALL
SELECT 'ACCIDENTFACT',           COUNT(*) FROM AccidentFact
ORDER BY Table_Name;

/* Dimension counts should agree with their source domains. */
SELECT 'BOOKINGMONTHDIM' AS Table_Name,
       (SELECT COUNT(*)
          FROM (SELECT DISTINCT TO_CHAR(BookingDate, 'YYYYMM') FROM Booking))
           AS Source_Count,
       (SELECT COUNT(*) FROM BookingMonthDIM) AS Warehouse_Count
FROM Dual
UNION ALL
SELECT 'FACULTYDIM',
       (SELECT COUNT(*) FROM Faculty),
       (SELECT COUNT(*) FROM FacultyDIM)
FROM Dual
UNION ALL
SELECT 'AGEGROUPDIM',
       3,
       (SELECT COUNT(*) FROM AgeGroupDIM)
FROM Dual
UNION ALL
SELECT 'CARBODYDIM',
       (SELECT COUNT(*)
          FROM (SELECT DISTINCT CarBodyType, NumSeats FROM Car)),
       (SELECT COUNT(*) FROM CarBodyDIM)
FROM Dual
UNION ALL
SELECT 'MAINTENANCETYPEDIM',
       (SELECT COUNT(*) FROM MaintenanceType),
       (SELECT COUNT(*) FROM MaintenanceTypeDIM)
FROM Dual
UNION ALL
SELECT 'MAINTENANCETEAMDIM',
       (SELECT COUNT(DISTINCT mt.TeamID)
          FROM MaintenanceTeam mt
          JOIN BelongTo b ON b.TeamID = mt.TeamID),
       (SELECT COUNT(*) FROM MaintenanceTeamDIM)
FROM Dual
UNION ALL
SELECT 'RESEARCHCENTERDIM',
       (SELECT COUNT(*) FROM ResearchCenter),
       (SELECT COUNT(*) FROM ResearchCenterDIM)
FROM Dual
UNION ALL
SELECT 'TEAMCENTERBRIDGE',
       (SELECT COUNT(*)
          FROM (SELECT DISTINCT TeamID, CenterID FROM BelongTo)),
       (SELECT COUNT(*) FROM TeamCenterBridge)
FROM Dual
UNION ALL
SELECT 'CARDIM',
       (SELECT COUNT(*) FROM Car),
       (SELECT COUNT(*) FROM CarDIM)
FROM Dual
UNION ALL
SELECT 'ZONEDIM',
       (SELECT COUNT(DISTINCT AccidentZone) FROM AccidentInfo),
       (SELECT COUNT(*) FROM ZoneDIM)
FROM Dual
UNION ALL
SELECT 'ERRORDIM',
       (SELECT COUNT(*) FROM Error),
       (SELECT COUNT(*) FROM ErrorDIM)
FROM Dual
UNION ALL
SELECT 'DAMAGESEVERITYDIM',
       (SELECT COUNT(DISTINCT Car_Damage_Severity) FROM AccidentInfo),
       (SELECT COUNT(*) FROM DamageSeverityDIM)
FROM Dual
ORDER BY Table_Name;

/* ========================================================================== */
/* 3. RECONCILE SOURCE TOTALS TO FACT TOTALS                                  */
/* ========================================================================== */

SELECT 'BOOKING RECORDS' AS Check_Name,
       (SELECT COUNT(*) FROM Booking) AS Source_Total,
       (SELECT NVL(SUM(NumberOfBookings), 0) FROM BookingFact) AS Warehouse_Total
FROM Dual
UNION ALL
SELECT 'MAINTENANCE RECORDS',
       (SELECT COUNT(*) FROM Maintenance),
       (SELECT NVL(SUM(NumberOfMaintenance), 0) FROM MaintenanceFact)
FROM Dual
UNION ALL
SELECT 'ACCIDENT-CAR INVOLVEMENTS',
       (SELECT COUNT(*)
          FROM CarAccident ca
          JOIN AccidentInfo ai ON ai.AccidentID = ca.AccidentID),
       (SELECT NVL(SUM(NumberOfAccidents), 0) FROM AccidentFact)
FROM Dual;

SELECT 'MAINTENANCE COST' AS Check_Name,
       (SELECT NVL(SUM(MaintenanceCost), 0) FROM Maintenance) AS Source_Total,
       (SELECT NVL(SUM(TotalMaintenanceCost), 0) FROM MaintenanceFact)
           AS Warehouse_Total
FROM Dual;

/* ACCIDENTINFO counts accidents once, while ACCIDENTFACT counts once per car.
   The two values may legitimately differ when an accident involves >1 car. */
SELECT (SELECT COUNT(*) FROM AccidentInfo) AS Accident_Events,
       (SELECT COUNT(*) FROM CarAccident)  AS Car_Accident_Involvements,
       (SELECT NVL(SUM(NumberOfAccidents), 0) FROM AccidentFact)
           AS Warehouse_Involvements
FROM Dual;

/* ========================================================================== */
/* 4. EXACT AGGREGATE RECONCILIATION                                          */
/* ========================================================================== */

/* Both booking mismatch counts must be 0. */
WITH SourceAgg AS
(
    SELECT TO_NUMBER(TO_CHAR(b.BookingDate, 'YYYYMM')) AS BookingMonthID,
           p.FacultyID,
           CASE
               WHEN p.PassengerAge BETWEEN 18 AND 35 THEN 1
               WHEN p.PassengerAge BETWEEN 36 AND 59 THEN 2
               WHEN p.PassengerAge >= 60 THEN 3
           END AS AgeGroupID,
           cb.CarBodyID,
           COUNT(b.BookingID) AS NumberOfBookings
    FROM Booking b
    JOIN Passenger p
      ON p.PassengerID = b.PassengerID
    JOIN Car c
      ON c.RegistrationNo = b.RegistrationNo
    JOIN CarBodyDIM cb
      ON cb.CarBodyType = c.CarBodyType
     AND cb.NumSeats = c.NumSeats
    GROUP BY TO_NUMBER(TO_CHAR(b.BookingDate, 'YYYYMM')),
             p.FacultyID,
             CASE
                 WHEN p.PassengerAge BETWEEN 18 AND 35 THEN 1
                 WHEN p.PassengerAge BETWEEN 36 AND 59 THEN 2
                 WHEN p.PassengerAge >= 60 THEN 3
             END,
             cb.CarBodyID
),
WarehouseAgg AS
(
    SELECT BookingMonthID, FacultyID, AgeGroupID, CarBodyID, NumberOfBookings
    FROM BookingFact
)
SELECT 'BOOKING SOURCE MINUS WAREHOUSE' AS Check_Name,
       COUNT(*) AS Mismatch_Rows
FROM
(
    SELECT * FROM SourceAgg
    MINUS
    SELECT * FROM WarehouseAgg
)
UNION ALL
SELECT 'BOOKING WAREHOUSE MINUS SOURCE',
       COUNT(*)
FROM
(
    SELECT * FROM WarehouseAgg
    MINUS
    SELECT * FROM SourceAgg
);

/* Both maintenance mismatch counts must be 0. */
WITH SourceAgg AS
(
    SELECT cb.CarBodyID,
           m.MaintenanceType AS MaintenanceTypeID,
           m.TeamID,
           COUNT(m.MaintenanceID) AS NumberOfMaintenance,
           SUM(m.MaintenanceCost) AS TotalMaintenanceCost
    FROM Maintenance m
    JOIN Car c
      ON c.RegistrationNo = m.RegistrationNo
    JOIN CarBodyDIM cb
      ON cb.CarBodyType = c.CarBodyType
     AND cb.NumSeats = c.NumSeats
    GROUP BY cb.CarBodyID, m.MaintenanceType, m.TeamID
),
WarehouseAgg AS
(
    SELECT CarBodyID, MaintenanceTypeID, TeamID,
           NumberOfMaintenance, TotalMaintenanceCost
    FROM MaintenanceFact
)
SELECT 'MAINTENANCE SOURCE MINUS WAREHOUSE' AS Check_Name,
       COUNT(*) AS Mismatch_Rows
FROM
(
    SELECT * FROM SourceAgg
    MINUS
    SELECT * FROM WarehouseAgg
)
UNION ALL
SELECT 'MAINTENANCE WAREHOUSE MINUS SOURCE',
       COUNT(*)
FROM
(
    SELECT * FROM WarehouseAgg
    MINUS
    SELECT * FROM SourceAgg
);

/* Both accident mismatch counts must be 0. */
WITH SourceAgg AS
(
    SELECT ca.RegistrationNo,
           ai.AccidentZone AS ZoneID,
           ai.ErrorCode,
           ds.DamageSeverityID,
           COUNT(ai.AccidentID) AS NumberOfAccidents
    FROM CarAccident ca
    JOIN AccidentInfo ai
      ON ai.AccidentID = ca.AccidentID
    JOIN DamageSeverityDIM ds
      ON ds.Description = ai.Car_Damage_Severity
    GROUP BY ca.RegistrationNo,
             ai.AccidentZone,
             ai.ErrorCode,
             ds.DamageSeverityID
),
WarehouseAgg AS
(
    SELECT RegistrationNo, ZoneID, ErrorCode,
           DamageSeverityID, NumberOfAccidents
    FROM AccidentFact
)
SELECT 'ACCIDENT SOURCE MINUS WAREHOUSE' AS Check_Name,
       COUNT(*) AS Mismatch_Rows
FROM
(
    SELECT * FROM SourceAgg
    MINUS
    SELECT * FROM WarehouseAgg
)
UNION ALL
SELECT 'ACCIDENT WAREHOUSE MINUS SOURCE',
       COUNT(*)
FROM
(
    SELECT * FROM WarehouseAgg
    MINUS
    SELECT * FROM SourceAgg
);

/* ========================================================================== */
/* 5. BRIDGE/LIST/WEIGHT CHECKS                                               */
/* ========================================================================== */

/* Expected: no rows. Each team's repeated weight must add to 1 across its
   bridge rows. */
SELECT mt.TeamID,
       SUM(mt.CenterWeightFactor) AS AllocatedWeight
FROM MaintenanceTeamDIM mt
JOIN TeamCenterBridge b
  ON b.TeamID = mt.TeamID
GROUP BY mt.TeamID
HAVING ABS(SUM(mt.CenterWeightFactor) - 1) > 0.000001;

/* Expected: 0 mismatches for list, count and weight. */
WITH Rebuilt AS
(
    SELECT TeamID,
           LISTAGG(CenterID, '_') WITHIN GROUP
               (ORDER BY CenterID) AS CenterGroupList,
           COUNT(CenterID)       AS CenterCount,
           1.0 / COUNT(CenterID) AS CenterWeightFactor
    FROM TeamCenterBridge
    GROUP BY TeamID
)
SELECT COUNT(*) AS Mismatch_Rows
FROM MaintenanceTeamDIM mt
JOIN Rebuilt r
  ON r.TeamID = mt.TeamID
WHERE mt.CenterGroupList <> r.CenterGroupList
   OR mt.CenterCount <> r.CenterCount
   OR ABS(mt.CenterWeightFactor - r.CenterWeightFactor) > 0.000001;

/* ========================================================================== */
/* 6. QUERIES SHOWING THAT THE STAR ANSWERS THE ASSIGNMENT QUESTIONS          */
/* ========================================================================== */

/* Inspect labels first if you need to confirm source spelling/capitalisation. */
SELECT * FROM FacultyDIM ORDER BY FacultyID;
SELECT * FROM CarBodyDIM ORDER BY CarBodyID;
SELECT * FROM DamageSeverityDIM ORDER BY DamageSeverityID;

/* 6.1 Bookings made by IT passengers in July using a bus (all years). */
SELECT SUM(bf.NumberOfBookings) AS NumberOfBookings
FROM BookingFact bf
JOIN BookingMonthDIM bm ON bm.BookingMonthID = bf.BookingMonthID
JOIN FacultyDIM f        ON f.FacultyID = bf.FacultyID
JOIN CarBodyDIM cb       ON cb.CarBodyID = bf.CarBodyID
WHERE UPPER(bm.BookingMonth) = 'JULY'
  AND UPPER(f.FacultyName) = 'IT'
  AND UPPER(cb.CarBodyType) = 'BUS';

/* 6.2 Bookings by passenger age group. */
SELECT ag.AgeGroupDescription,
       SUM(bf.NumberOfBookings) AS NumberOfBookings
FROM BookingFact bf
JOIN AgeGroupDIM ag ON ag.AgeGroupID = bf.AgeGroupID
GROUP BY ag.AgeGroupID, ag.AgeGroupDescription
ORDER BY ag.AgeGroupID;

/* 6.3 Maintenance records whose team belongs to CE04.
   Do not apply the weight here: the wording asks whether the team belongs to
   CE04, rather than asking for an allocated share across all centres. */
SELECT b.CenterID,
       SUM(mf.NumberOfMaintenance) AS NumberOfMaintenance
FROM MaintenanceFact mf
JOIN TeamCenterBridge b ON b.TeamID = mf.TeamID
WHERE UPPER(b.CenterID) = 'CE04'
GROUP BY b.CenterID;

/* 6.4 Total maintenance cost by maintenance type for mini buses. */
SELECT mt.MaintenanceTypeID,
       mt.MaintenanceDescription,
       SUM(mf.TotalMaintenanceCost) AS TotalMaintenanceCost
FROM MaintenanceFact mf
JOIN MaintenanceTypeDIM mt
  ON mt.MaintenanceTypeID = mf.MaintenanceTypeID
JOIN CarBodyDIM cb
  ON cb.CarBodyID = mf.CarBodyID
WHERE UPPER(cb.CarBodyType) = 'MINI BUS'
GROUP BY mt.MaintenanceTypeID, mt.MaintenanceDescription
ORDER BY mt.MaintenanceTypeID;

/* 6.5 Accidents recorded in ZoneA for Car01. */
SELECT RegistrationNo,
       ZoneID,
       SUM(NumberOfAccidents) AS NumberOfAccidents
FROM AccidentFact
WHERE UPPER(RegistrationNo) = 'CAR01'
  AND UPPER(ZoneID) = 'ZONEA'
GROUP BY RegistrationNo, ZoneID;

/* 6.6 Accidents for each error code in ZoneB for Car06. */
SELECT af.ErrorCode,
       e.ErrorMessage,
       SUM(af.NumberOfAccidents) AS NumberOfAccidents
FROM AccidentFact af
JOIN ErrorDIM e ON e.ErrorCode = af.ErrorCode
WHERE UPPER(af.RegistrationNo) = 'CAR06'
  AND UPPER(af.ZoneID) = 'ZONEB'
GROUP BY af.ErrorCode, e.ErrorMessage
ORDER BY af.ErrorCode;

/* 6.7 Severe-damage accidents involving Car05. */
SELECT af.RegistrationNo,
       ds.Description,
       SUM(af.NumberOfAccidents) AS NumberOfAccidents
FROM AccidentFact af
JOIN DamageSeverityDIM ds
  ON ds.DamageSeverityID = af.DamageSeverityID
WHERE UPPER(af.RegistrationNo) = 'CAR05'
  AND UPPER(ds.Description) = 'SEVERE DAMAGE'
GROUP BY af.RegistrationNo, ds.Description;

/* Optional analytical allocation by research centre. Because a team may belong
   to several centres, multiply additive measures by the equal weight factor to
   avoid double-counting when totals are reported across all centres. */
SELECT rc.CenterID,
       rc.CenterName,
       SUM(mf.NumberOfMaintenance * mt.CenterWeightFactor)
           AS AllocatedNumberOfMaintenance,
       SUM(mf.TotalMaintenanceCost * mt.CenterWeightFactor)
           AS AllocatedMaintenanceCost
FROM MaintenanceFact mf
JOIN MaintenanceTeamDIM mt ON mt.TeamID = mf.TeamID
JOIN TeamCenterBridge b     ON b.TeamID = mt.TeamID
JOIN ResearchCenterDIM rc   ON rc.CenterID = b.CenterID
GROUP BY rc.CenterID, rc.CenterName
ORDER BY rc.CenterID;
