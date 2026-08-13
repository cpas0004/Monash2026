-- PART A

drop table SemesterDIM;
create table SemesterDIM (
    SemID VARCHAR2(10) PRIMARY KEY,
    SemDesc VARCHAR2(20),
    StartDate DATE,
    EndDate DATE
);

drop table TimeDIM;
create table TimeDIM (
    TimeID NUMBER,
    TimeDesc VARCHAR2(20),
    StartTime DATE,
    EndTime DATE
);

create table MajorDIM as
select * from dw.major;

create table ClassDIM as
select * from dw.class;

insert into SemesterDIM VALUES ('S1', 'Semester 1', TO_DATE('01-JAN', 'DD-MON'), TO_DATE('15-JUL', 'DD-MON'));
insert into SemesterDIM VALUES ('S2', 'Semester 2', TO_DATE('16-JUL', 'DD-MON'), TO_DATE('31-DEC', 'DD-MON'));

insert into TimeDIM VALUES (1, 'Morning', TO_DATE('06:01', 'HH24:MI'), TO_DATE('12:00', 'HH24:MI'));
insert into TimeDIM VALUES (2, 'Afternoon', TO_DATE('12:01', 'HH24:MI'), TO_DATE('18:00', 'HH24:MI'));
insert into TimeDIM VALUES (3, 'Night', TO_DATE('18:01', 'HH24:MI'), TO_DATE('06:00', 'HH24:MI'));

create table tempfact_uselog as
select u.log_date, u.log_time, u.student_id, s.class_id, s.major_code
from dw.uselog u, dw.student s
where u.student_id = s.student_id;

alter table tempfact_uselog add (timeID NUMBER);

update tempfact_uselog set timeID = 1
where TO_CHAR(log_time, 'HH24:MI') between '06:01' and '12:00';

update tempfact_uselog set timeID = 2
where TO_CHAR(log_time, 'HH24:MI') between '12:01' and '18:00';

commit;

update tempfact_uselog set timeID = 3
where TO_CHAR(log_time, 'HH24:MI') >= '18:01' OR TO_CHAR(log_time, 'HH24:MI') <= '06:00';

-- OR could have just updated where values were NULL still
update tempfact_uselog set timeID = 3
where timeID is NULL;

commit;

alter table tempfact_uselog add (semID VARCHAR2(10));

update tempfact_uselog set semID = 'S1'
where TO_CHAR(log_date, 'MMDD') >= '0101' and TO_CHAR(log_date, 'MMDD') <= '0715';

update tempfact_uselog set semID = 'S2'
where TO_CHAR(log_date, 'MMDD') >= '0716' and TO_CHAR(log_date, 'MMDD') <= '1231';

commit;

create table fact_uselog as
select t.semID, t.timeID, t.CLASS_ID, t.MAJOR_CODE, count(*) as total_usage
from tempfact_uselog t
group by t.semID, t.timeID, t.CLASS_ID, t.MAJOR_CODE;

--------------------------------------------
-- PART B

select count(*) from dw.student;
select * from dw.student;

select count(*) from dw.uselog;
select * from dw.uselog;

select count(*) from dw.major;
select * from dw.major;

select count(*) from dw.class;
select * from dw.class;

select count(*) from tempfact_uselog;
select count(*) from fact_uselog;

-- Investigating
-- content dw.uselog from operational database
Select log_date, 
to_char(log_time, 'HH24:MI') as log_time,
student_ID, act
From dw.uselog;

-- content from data warehousing
Select log_date,
to_char(log_time, 'HH24:MI') as log_time,
student_ID
From tempfact_uselog;

-- checking if the duplication are in uselog (choosing an example that I know is duplicated in tempfact)
select u.log_date, TO_CHAR(u.log_time, 'HH24:MI') as log_time, u.student_id
from dw.uselog u
where u.student_id = '5VR36V83A';

-- now checking if the duplication is in student table (choosing an example that I know is duplicated in tempfact)
select * from dw.student s
where s.student_id = '5VR36V83A';

-- now checking if there are lots of duplicated students
select student_id, count(*)
from dw.STUDENT
group by student_id
having count(*) > 1;

-- checking duplicated majors
select major_code, count(*)
from dw.MAJOR
group by major_code
having count(*) > 1;

-- checking duplicated classes
select class_id, count(*)
from dw.CLASS
group by class_id
having count(*) > 1;

--------------------------------------------
-- PART C

-- Using the DISTINCT keyword to remove duplicates for the tempfact table
create table tempfact_uselog2 as
select distinct U.log_date , U.log_time,
U.student_ID, S.class_id, S.major_code
from dw.uselog U, dw.student S
where U.student_id = S.student_id;

-- How many records are in the new tempfact table?
select count(*) from tempfact_uselog2;
select count(*) from dw.uselog;

-- mostly fixed the issue, but there are still 6 extra records in uselog compared to tempfact_uselog2.

-- Check for illegal students  in uselog
select * from dw.USELOG
where student_id not in (select student_id from dw.student);
-- No, all good

-- Check for illegal majors in dw.student
select *
from dw.uselog u, dw.student s
where u.student_id = s.student_id
and s.major_code not in (select major_code from dw.major);
-- No, all good

-- Did some uselog entries not get copied to tempfact_uselog2?
-- Check if there are records in uselog that are not in tempfact_uselog2
select *
from dw.uselog u
where log_date not in (select log_date from tempfact_uselog2)
and log_time not in (select log_time from tempfact_uselog2)
and student_id not in (select student_id from tempfact_uselog2);
-- No, they are all in there

-- Are there duplicates in uselog then?
SELECT log_date, log_time, student_id, COUNT(*)
FROM dw.uselog
GROUP BY log_date, log_time, student_id
HAVING COUNT(*) > 1;


-- Now we repeat all the step to create the tempfact_uselog2 again
alter table tempfact_uselog2
add (timeid number);

update tempfact_uselog2
set timeid = 1
where  to_char(log_time, 'HH24:MI') >= '06:01'
and to_char(log_time, 'HH24:MI') <='12:00';

select count(*) from tempfact_uselog2 where timeid = 1;

update tempfact_uselog2
set timeid = 2
where  to_char(log_time, 'HH24:MI') >= '12:01'
and to_char(log_time, 'HH24:MI') <='18:00';

select count(*) from tempfact_uselog2 where timeid = 2;

update tempfact_uselog2
set timeid = 3
where to_char(log_time, 'HH24:MI') >= '18:01'
or to_char(log_time, 'HH24:MI') <='06:00';

select count(*) from tempfact_uselog2 where timeid = 3;

-- Adding the semid
alter table tempfact_uselog2
add (semid varchar2(10));

update tempfact_uselog2
set semid = 'S1'
where to_char(log_date, 'MMDD') >= '0101'
and to_char(log_date, 'MMDD') <= '0715';

select count(*) from tempfact_uselog2 where semid = 'S1';

update tempfact_uselog2
set semid = 'S2'
where to_char(log_date, 'MMDD') >= '0716'
and to_char(log_date, 'MMDD') <= '1231';

select count(*) from tempfact_uselog2 where semid = 'S2';

-- Now can make the fact table
create table fact_uselog2 as
select t.semid, t.timeid, t.class_id,
t.major_code, count(t.student_id) as total_usage
from tempfact_uselog2 t
group by t.semid, t.timeid, t.class_id, t.major_code;

-- inspecting the old and new fact tables
select * 
from fact_uselog
order by semid, timeid, class_id, major_code;

select *
from fact_uselog2
order by semid, timeid, class_id, major_code;

-- practice queries

-- How many total usage for each time period?
select f.timeID, t.timeDesc, sum(f.total_usage) as total_usage
from fact_uselog2 f join timeDIM t on f.timeid = t.timeid
group by f.timeID, t.timeDesc;

-- How many users by time, major and class
select f.timeID, f.major_code, f.class_id, sum(f.total_usage) as total_usage
from fact_uselog2 f
group by f.timeID, f.major_code, f.class_id;

-- how many users by major and semester?
select f.semID, f.major_code, m.major_name, sum(f.total_usage) as total_usage
from fact_uselog2 f join majorDIM m on f.major_code = m.major_code
group by f.semID, f.major_code, m.major_name;

