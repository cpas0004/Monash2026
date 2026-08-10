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