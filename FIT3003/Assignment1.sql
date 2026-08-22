-- Just looking at all tables in the GRACIE2 schema
select * from GRACIE2.instrument;
select * from GRACIE2.lesson;
select * from GRACIE2.instructor;
select * from GRACIE2.enrollment;
select * from GRACIE2.student;
select * from GRACIE2.parent;

-- Creating the dimension tables for the STAR schema
create table InstrumentDIM as
select * from GRACIE2.instrument;

create table InstructorDIM as 
select InstructorID, FirstName, LastName, Qualification
from GRACIE2.instructor;

create table MonthDIM (
    MonthID number primary key,
    MonthName varchar2(20) NOT NULL
);

insert into MonthDIM values (1, 'January');
insert into MonthDIM values (2, 'February');
insert into MonthDIM values (3, 'March');
insert into MonthDIM values (4, 'April');
insert into MonthDIM values (5, 'May');
insert into MonthDIM values (6, 'June');
insert into MonthDIM values (7, 'July');
insert into MonthDIM values (8, 'August');
insert into MonthDIM values (9, 'September');
insert into MonthDIM values (10, 'October');
insert into MonthDIM values (11, 'November');
insert into MonthDIM values (12, 'December');

create table agegroupdim (
    AgeGroupID varchar2(3) primary key,
    AgeGroupName varchar2(20) NOT NULL,
    MinimumAge   NUMBER(2) NOT NULL,
    MaximumAge   NUMBER(2) NOT NULL
);

INSERT INTO agegroupdim
VALUES ('EC', 'early childhood', 4, 6);

INSERT INTO agegroupdim
VALUES ('MC', 'middle childhood', 7, 9);

INSERT INTO agegroupdim
VALUES ('T', 'teen', 10, 18);

create table ClassSizeDIM (
    ClassSizeID varchar2(2) primary key,
    ClassSizeName varchar2(20) NOT NULL,
    MinimumSize   NUMBER(1) NOT NULL,
    MaximumSize   NUMBER(3) NOT NULL
);

insert into ClassSizeDIM values ('I', 'individual', 1, 1);
insert into ClassSizeDIM values ('S', 'small', 2, 3);
insert into ClassSizeDIM values ('M', 'medium', 4, 6);
insert into ClassSizeDIM values ('L', 'large', 7, 999);

create table lessondayDIM (
    lessondayID varchar2(9) primary key,
    lessondaycategory varchar2(7) NOT NULL
);

insert into lessondayDIM values ('Monday', 'Weekday');
insert into lessondayDIM values ('Tuesday', 'Weekday');
insert into lessondayDIM values ('Wednesday', 'Weekday');
insert into lessondayDIM values ('Thursday', 'Weekday');
insert into lessondayDIM values ('Friday', 'Weekday');
insert into lessondayDIM values ('Saturday', 'Weekend');
insert into lessondayDIM values ('Sunday', 'Weekend');

commit;

-- Now to make the tempfact table

create table tempfact as
select 
    e.lesson_day as LessonDayID,
    l.InstrumentID,
    l.InstructorID,
    to_number(to_char(e.start_date, 'MM')) as MonthID,
    l.class_size,
    FLOOR(MONTHS_BETWEEN(e.start_date, s.birthdate)/12) as Age,
    l.monthly_fee
from GRACIE2.lesson l, GRACIE2.student s, GRACIE2.enrollment e
where l.lessonid = e.lessonid and s.studentid = e.studentid;

-- Now to add the AgeGroupID to the tempfact table
alter table tempfact add (AgeGroupID varchar2(3));

update tempfact t
set AgeGroupID = 'EC'
where t.Age >= 4 and t.Age <= 6;

update tempfact t
set AgeGroupID = 'MC'
where t.Age >= 7 and t.Age <= 9;

update tempfact t
set AgeGroupID = 'T'
where t.Age >= 10 and t.Age <= 18;

-- Now to add the ClassSizeID to the tempfact table
alter table tempfact add (ClassSizeID varchar2(2));

update tempfact t
set ClassSizeID = 'I'
where t.class_size = 1;

update tempfact t
set ClassSizeID = 'S'
where t.class_size >= 2 and t.class_size <= 3;

update tempfact t
set ClassSizeID = 'M'
where t.class_size >= 4 and t.class_size <= 6;

update tempfact t
set ClassSizeID = 'L'
where t.class_size >= 7;

-- Now to create the fact table
create table enrolment_fact as
select 
    t.LessonDayID,
    t.InstrumentID,
    t.InstructorID,
    t.MonthID,
    t.AgeGroupID,
    t.ClassSizeID,
    count(*) as TotalEnrollments,
    sum(t.monthly_fee) as TotalRevenue
from tempfact t
group by t.LessonDayID, t.InstrumentID, t.InstructorID, t.MonthID, t.AgeGroupID, t.ClassSizeID;

select * from enrolment_fact;

commit;

-- Determine which age groups, based on the number of enrollments, are the most actively engaged with the program.
select a.agegroupname, a.minimumage, a.maximumage, sum(f.totalenrollments) as totalenrollments
from enrolment_fact f, agegroupdim a
where f.AgeGroupID = a.AgeGroupID
group by a.agegroupname, a.minimumage, a.maximumage
order by totalenrollments desc;

-- Evaluate the number of enrollments for each instructor and the qualifications of the corresponding instructors.
select i.instructorid, i.firstname, i.lastname, i.qualification, sum(f.totalenrollments) as totalenrollments
from enrolment_fact f, instructordim i
where f.instructorid = i.instructorid
group by i.instructorid, i.firstname, i.lastname, i.qualification;

-- Identify which instruments attract the most enrollments.
select i.instrumentid, i.description, sum(f.totalenrollments) as totalenrollments
from enrolment_fact f, instrumentdim i
where f.instrumentid = i.instrumentid
group by i.instrumentid, i.description
order by totalenrollments desc;

-- Determine which month (based on start date of enrolment) is the most profitable (based on revenue)
select m.monthname, sum(f.totalrevenue) as totalrevenue
from enrolment_fact f, monthdim m
where f.monthid = m.monthid
group by m.monthname
order by totalrevenue desc;

-- Assess how class size impacts enrollment and revenue.
select c.classsizename, c.minimumsize, c.maximumsize, sum(f.totalenrollments) as totalenrollments, sum(f.totalrevenue) as totalrevenue
from enrolment_fact f, classsizedim c
where f.classsizeid = c.classsizeid
group by c.classsizename, c.minimumsize, c.maximumsize;

-- Identify the most popular lesson days for lessons to understand the scheduling preferences.
select l.lessondayid, l.lessondaycategory, sum(f.totalenrollments) as totalenrollments
from enrolment_fact f, lessondaydim l
where f.lessondayid = l.lessondayid
group by l.lessondayid, l.lessondaycategory
order by totalenrollments desc;

commit;