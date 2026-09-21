/*
  MonCity Version-1 data warehouse (Oracle SQL)

  Assumptions
  -----------
  1. The cleaned operational tables already exist in this schema with the names
     FACULTY, RESEARCHCENTER, PASSENGER, ERROR, MAINTENANCETYPE, BOOKING,
     CAR, MAINTENANCE, ACCIDENTINFO, CARACCIDENT, MAINTENANCETEAM and BELONGTO.
  2. Source primary/foreign-key and null problems have already been cleaned.
  3. This script implements the table and column names in the final Version-1
     diagram exactly.

  Fact grains
  -----------
  BOOKINGFACT:
    one row per booking month + faculty + passenger age group + car body.
  MAINTENANCEFACT:
    one row per car body + maintenance type + maintenance team.
  ACCIDENTFACT:
    one row per car + accident zone + error code + damage severity.
    NUMBEROFACCIDENTS counts car-accident involvements from CARACCIDENT.

  The implementation follows the textbook pattern:
  - CREATE TABLE AS SELECT for extracted dimensions;
  - manual CREATE TABLE and INSERT for the fixed age bands;
  - temporary fact tables where dimension keys need transformation; and
  - COUNT/SUM with GROUP BY to populate the high-aggregation facts.
*/

/*
  Optional reset for a rerun. Uncomment only after confirming that these are the
  warehouse objects you intend to replace.

DROP TABLE BookingFact CASCADE CONSTRAINTS PURGE;
DROP TABLE MaintenanceFact CASCADE CONSTRAINTS PURGE;
DROP TABLE AccidentFact CASCADE CONSTRAINTS PURGE;
DROP TABLE TempBookingFact PURGE;
DROP TABLE TempMaintenanceFact PURGE;
DROP TABLE TempAccidentFact PURGE;
DROP TABLE TeamCenterBridge CASCADE CONSTRAINTS PURGE;
DROP TABLE BookingMonthDIM CASCADE CONSTRAINTS PURGE;
DROP TABLE FacultyDIM CASCADE CONSTRAINTS PURGE;
DROP TABLE AgeGroupDIM CASCADE CONSTRAINTS PURGE;
DROP TABLE CarBodyDIM CASCADE CONSTRAINTS PURGE;
DROP TABLE MaintenanceTypeDIM CASCADE CONSTRAINTS PURGE;
DROP TABLE MaintenanceTeamDIM CASCADE CONSTRAINTS PURGE;
DROP TABLE ResearchCenterDIM CASCADE CONSTRAINTS PURGE;
DROP TABLE CarDIM CASCADE CONSTRAINTS PURGE;
DROP TABLE ZoneDIM CASCADE CONSTRAINTS PURGE;
DROP TABLE ErrorDIM CASCADE CONSTRAINTS PURGE;
DROP TABLE DamageSeverityDIM CASCADE CONSTRAINTS PURGE;
*/

/* ========================================================================== */
/* 1. DIMENSION TABLES                                                        */
/* ========================================================================== */

CREATE TABLE BookingMonthDIM AS
SELECT DISTINCT
       TO_NUMBER(TO_CHAR(BookingDate, 'YYYYMM')) AS BookingMonthID,
       TO_CHAR(BookingDate, 'FMMonth',
               'NLS_DATE_LANGUAGE=English')     AS BookingMonth,
       TO_NUMBER(TO_CHAR(BookingDate, 'YYYY'))  AS BookingYear
FROM Booking;

CREATE TABLE FacultyDIM AS
SELECT FacultyID,
       FacultyName
FROM Faculty;

/* A fixed domain is inserted manually so all required bands exist even when a
   source data set happens to contain no passenger in one of the bands. */
CREATE TABLE AgeGroupDIM
(
    AgeGroupID          NUMBER(1),
    AgeGroupDescription VARCHAR2(30),
    MinimumAge          NUMBER(3),
    MaximumAge          NUMBER(3)
);

INSERT INTO AgeGroupDIM VALUES (1, 'Young adults',       18, 35);
INSERT INTO AgeGroupDIM VALUES (2, 'Middle-aged adults', 36, 59);
INSERT INTO AgeGroupDIM VALUES (3, 'Old-aged adults',    60, NULL);

/* CARBODYID is a surrogate key for each distinct body type/seat combination. */
CREATE TABLE CarBodyDIM AS
SELECT ROW_NUMBER() OVER (ORDER BY CarBodyType, NumSeats) AS CarBodyID,
       CarBodyType,
       NumSeats
FROM
(
    SELECT DISTINCT CarBodyType, NumSeats
    FROM Car
);

CREATE TABLE MaintenanceTypeDIM AS
SELECT MaintenanceType        AS MaintenanceTypeID,
       MaintenanceDescription
FROM MaintenanceType;

CREATE TABLE ResearchCenterDIM AS
SELECT CenterID,
       CenterName
FROM ResearchCenter;

/* BELONGTO is many-to-many. The team dimension stores the list aggregate,
   group count and equal allocation weight required by the final design. */
CREATE TABLE MaintenanceTeamDIM AS
SELECT mt.TeamID,
       LISTAGG(b.CenterID, '_') WITHIN GROUP
           (ORDER BY b.CenterID)                  AS CenterGroupList,
       COUNT(b.CenterID)                          AS CenterCount,
       1.0 / COUNT(b.CenterID)                    AS CenterWeightFactor
FROM MaintenanceTeam mt
JOIN
(
    SELECT DISTINCT TeamID, CenterID
    FROM BelongTo
) b
  ON b.TeamID = mt.TeamID
GROUP BY mt.TeamID;

CREATE TABLE TeamCenterBridge AS
SELECT DISTINCT TeamID,
                CenterID
FROM BelongTo;

/* Determinant dimension in the final diagram. */
CREATE TABLE CarDIM AS
SELECT RegistrationNo,
       CarModel,
       ManufacturingYear,
       CarBodyType,
       NumSeats
FROM Car;

/* The diagram contains only ZONEID, so the operational zone value is the key. */
CREATE TABLE ZoneDIM AS
SELECT DISTINCT AccidentZone AS ZoneID
FROM AccidentInfo;

CREATE TABLE ErrorDIM AS
SELECT ErrorCode,
       ErrorMessage
FROM Error;

CREATE TABLE DamageSeverityDIM AS
SELECT ROW_NUMBER() OVER (ORDER BY Description) AS DamageSeverityID,
       Description
FROM
(
    SELECT DISTINCT Car_Damage_Severity AS Description
    FROM AccidentInfo
);

/* Dimension and bridge keys. */
ALTER TABLE BookingMonthDIM
    ADD CONSTRAINT pk_bookingmonth_dim PRIMARY KEY (BookingMonthID);

ALTER TABLE FacultyDIM
    ADD CONSTRAINT pk_faculty_dim PRIMARY KEY (FacultyID);

ALTER TABLE AgeGroupDIM
    ADD CONSTRAINT pk_agegroup_dim PRIMARY KEY (AgeGroupID);

ALTER TABLE CarBodyDIM
    ADD CONSTRAINT pk_carbody_dim PRIMARY KEY (CarBodyID);

ALTER TABLE MaintenanceTypeDIM
    ADD CONSTRAINT pk_mainttype_dim PRIMARY KEY (MaintenanceTypeID);

ALTER TABLE ResearchCenterDIM
    ADD CONSTRAINT pk_researchcenter_dim PRIMARY KEY (CenterID);

ALTER TABLE MaintenanceTeamDIM
    ADD CONSTRAINT pk_maintteam_dim PRIMARY KEY (TeamID);

ALTER TABLE TeamCenterBridge
    ADD CONSTRAINT pk_teamcenter_bridge PRIMARY KEY (TeamID, CenterID);

ALTER TABLE CarDIM
    ADD CONSTRAINT pk_car_dim PRIMARY KEY (RegistrationNo);

ALTER TABLE ZoneDIM
    ADD CONSTRAINT pk_zone_dim PRIMARY KEY (ZoneID);

ALTER TABLE ErrorDIM
    ADD CONSTRAINT pk_error_dim PRIMARY KEY (ErrorCode);

ALTER TABLE DamageSeverityDIM
    ADD CONSTRAINT pk_damageseverity_dim PRIMARY KEY (DamageSeverityID);

ALTER TABLE TeamCenterBridge
    ADD CONSTRAINT fk_bridge_team
        FOREIGN KEY (TeamID) REFERENCES MaintenanceTeamDIM (TeamID);

ALTER TABLE TeamCenterBridge
    ADD CONSTRAINT fk_bridge_center
        FOREIGN KEY (CenterID) REFERENCES ResearchCenterDIM (CenterID);

/* ========================================================================== */
/* 2. BOOKING FACT                                                            */
/* ========================================================================== */

CREATE TABLE TempBookingFact AS
SELECT b.BookingID,
       TO_NUMBER(TO_CHAR(b.BookingDate, 'YYYYMM')) AS BookingMonthID,
       p.FacultyID,
       p.PassengerAge,
       c.CarBodyType,
       c.NumSeats
FROM Booking b
JOIN Passenger p
  ON p.PassengerID = b.PassengerID
JOIN Car c
  ON c.RegistrationNo = b.RegistrationNo;

CREATE TABLE BookingFact AS
SELECT bm.BookingMonthID,
       f.FacultyID,
       ag.AgeGroupID,
       cb.CarBodyID,
       COUNT(t.BookingID) AS NumberOfBookings
FROM TempBookingFact t
JOIN BookingMonthDIM bm
  ON bm.BookingMonthID = t.BookingMonthID
JOIN FacultyDIM f
  ON f.FacultyID = t.FacultyID
JOIN AgeGroupDIM ag
  ON t.PassengerAge >= ag.MinimumAge
 AND (ag.MaximumAge IS NULL OR t.PassengerAge <= ag.MaximumAge)
JOIN CarBodyDIM cb
  ON cb.CarBodyType = t.CarBodyType
 AND cb.NumSeats = t.NumSeats
GROUP BY bm.BookingMonthID,
         f.FacultyID,
         ag.AgeGroupID,
         cb.CarBodyID;

DROP TABLE TempBookingFact PURGE;

ALTER TABLE BookingFact
    ADD CONSTRAINT pk_booking_fact
        PRIMARY KEY (BookingMonthID, FacultyID, AgeGroupID, CarBodyID);

ALTER TABLE BookingFact
    ADD CONSTRAINT fk_bfact_month
        FOREIGN KEY (BookingMonthID) REFERENCES BookingMonthDIM (BookingMonthID);

ALTER TABLE BookingFact
    ADD CONSTRAINT fk_bfact_faculty
        FOREIGN KEY (FacultyID) REFERENCES FacultyDIM (FacultyID);

ALTER TABLE BookingFact
    ADD CONSTRAINT fk_bfact_agegroup
        FOREIGN KEY (AgeGroupID) REFERENCES AgeGroupDIM (AgeGroupID);

ALTER TABLE BookingFact
    ADD CONSTRAINT fk_bfact_carbody
        FOREIGN KEY (CarBodyID) REFERENCES CarBodyDIM (CarBodyID);

/* ========================================================================== */
/* 3. MAINTENANCE FACT                                                        */
/* ========================================================================== */

CREATE TABLE TempMaintenanceFact AS
SELECT m.MaintenanceID,
       c.CarBodyType,
       c.NumSeats,
       m.MaintenanceType AS MaintenanceTypeID,
       m.TeamID,
       m.MaintenanceCost
FROM Maintenance m
JOIN Car c
  ON c.RegistrationNo = m.RegistrationNo;

CREATE TABLE MaintenanceFact AS
SELECT cb.CarBodyID,
       mt.MaintenanceTypeID,
       team.TeamID,
       COUNT(t.MaintenanceID) AS NumberOfMaintenance,
       SUM(t.MaintenanceCost) AS TotalMaintenanceCost
FROM TempMaintenanceFact t
JOIN CarBodyDIM cb
  ON cb.CarBodyType = t.CarBodyType
 AND cb.NumSeats = t.NumSeats
JOIN MaintenanceTypeDIM mt
  ON mt.MaintenanceTypeID = t.MaintenanceTypeID
JOIN MaintenanceTeamDIM team
  ON team.TeamID = t.TeamID
GROUP BY cb.CarBodyID,
         mt.MaintenanceTypeID,
         team.TeamID;

DROP TABLE TempMaintenanceFact PURGE;

ALTER TABLE MaintenanceFact
    ADD CONSTRAINT pk_maintenance_fact
        PRIMARY KEY (CarBodyID, MaintenanceTypeID, TeamID);

ALTER TABLE MaintenanceFact
    ADD CONSTRAINT fk_mfact_carbody
        FOREIGN KEY (CarBodyID) REFERENCES CarBodyDIM (CarBodyID);

ALTER TABLE MaintenanceFact
    ADD CONSTRAINT fk_mfact_type
        FOREIGN KEY (MaintenanceTypeID)
        REFERENCES MaintenanceTypeDIM (MaintenanceTypeID);

ALTER TABLE MaintenanceFact
    ADD CONSTRAINT fk_mfact_team
        FOREIGN KEY (TeamID) REFERENCES MaintenanceTeamDIM (TeamID);

/* ========================================================================== */
/* 4. ACCIDENT FACT                                                           */
/* ========================================================================== */

CREATE TABLE TempAccidentFact AS
SELECT ca.RegistrationNo,
       ai.AccidentID,
       ai.AccidentZone,
       ai.ErrorCode,
       ai.Car_Damage_Severity
FROM CarAccident ca
JOIN AccidentInfo ai
  ON ai.AccidentID = ca.AccidentID;

CREATE TABLE AccidentFact AS
SELECT car.RegistrationNo,
       z.ZoneID,
       e.ErrorCode,
       ds.DamageSeverityID,
       COUNT(t.AccidentID) AS NumberOfAccidents
FROM TempAccidentFact t
JOIN CarDIM car
  ON car.RegistrationNo = t.RegistrationNo
JOIN ZoneDIM z
  ON z.ZoneID = t.AccidentZone
JOIN ErrorDIM e
  ON e.ErrorCode = t.ErrorCode
JOIN DamageSeverityDIM ds
  ON ds.Description = t.Car_Damage_Severity
GROUP BY car.RegistrationNo,
         z.ZoneID,
         e.ErrorCode,
         ds.DamageSeverityID;

DROP TABLE TempAccidentFact PURGE;

ALTER TABLE AccidentFact
    ADD CONSTRAINT pk_accident_fact
        PRIMARY KEY (RegistrationNo, ZoneID, ErrorCode, DamageSeverityID);

ALTER TABLE AccidentFact
    ADD CONSTRAINT fk_afact_car
        FOREIGN KEY (RegistrationNo) REFERENCES CarDIM (RegistrationNo);

ALTER TABLE AccidentFact
    ADD CONSTRAINT fk_afact_zone
        FOREIGN KEY (ZoneID) REFERENCES ZoneDIM (ZoneID);

ALTER TABLE AccidentFact
    ADD CONSTRAINT fk_afact_error
        FOREIGN KEY (ErrorCode) REFERENCES ErrorDIM (ErrorCode);

ALTER TABLE AccidentFact
    ADD CONSTRAINT fk_afact_severity
        FOREIGN KEY (DamageSeverityID)
        REFERENCES DamageSeverityDIM (DamageSeverityID);

COMMIT;
