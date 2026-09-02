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

----------------------------------------------------------------------------------------------

-- Based on the provided assignment, what is the total number of enrollments for each instrument by month, 
-- where the instructors hold a Diploma? (Month answer as text not a number)
SELECT I.Description AS Instrument, M.MonthName AS Month, SUM(F.TotalEnrollments) AS TotalEnrollments
FROM Enrolment_Fact F, InstrumentDIM I, InstructorDIM D, MonthDIM M
WHERE F.InstrumentID = I.InstrumentID 
    AND F.InstructorID = D.InstructorID 
    AND F.MonthID = M.MonthID 
    AND D.Qualification = 'Diploma'
GROUP BY I.Description, M.MonthID, M.MonthName
ORDER BY I.Description, M.MonthID;

-- Based on the provided case study, management wants to know the average revenue per enrollment for each instructor. 
-- Please order the instructors from highest to lowest average revenue per enrollment in your answer.
SELECT I.FirstName, I.LastName, SUM(F.TotalRevenue) / SUM(F.TotalEnrollments) AS AverageRevenuePerEnrollment
FROM Enrolment_Fact F, InstructorDIM I
WHERE F.InstructorID = I.InstructorID
GROUP BY I.InstructorID, I.FirstName, I.LastName
ORDER BY SUM(F.TotalRevenue) / SUM(F.TotalEnrollments) DESC;

-- Based on the provided case study, identify which class size has the lowest total revenue and which class 
-- size has the lowest number of enrollments. Additionally, determine which class size would be worth expanding 
-- with additional classes based on the average revenue per enrollment.
SELECT
    C.ClassSizeName,
    SUM(F.TotalRevenue) AS TotalRevenue,
    SUM(F.TotalEnrollments) AS TotalEnrollments,
    SUM(F.TotalRevenue) / SUM(F.TotalEnrollments) AS AverageRevenuePerEnrollment
FROM Enrolment_Fact F, ClassSizeDIM C
WHERE F.ClassSizeID = C.ClassSizeID
GROUP BY C.ClassSizeID, C.ClassSizeName
ORDER BY C.ClassSizeID;

-- Based on the provided assignment, which of the following instruments are missing enrollment from at 
-- least one age group? Please provide the instrument names along with the age group(s) that have no 
-- enrollment in those instruments.
select i.instrumentid, i.description, a.agegroupname, sum(f.totalenrollments) as totalenrollments
from enrolment_fact f, instrumentdim i, agegroupdim a
where f.instrumentid = i.instrumentid and f.agegroupid = a.agegroupid
group by i.instrumentid, i.description, a.agegroupname
order by i.instrumentid;

--Based on the provided assignment and the dataset, identify the instructors who teach more than one distinct 
--instrument. Please provide their names and ensure the results are ordered by instructor ID in ascending order.
select i.instructorid, i.firstname, i.lastname, count(distinct l.instrumentid) as distinct_instruments
from enrolment_fact f, instructordim i, instrumentdim l
where f.instructorid = i.instructorid and f.instrumentid = l.instrumentid
group by i.instructorid, i.firstname, i.lastname
having count(distinct l.instrumentid) > 1
order by i.instructorid asc;

-- Based on the provided assignment, what is the total number of enrolments for violin lessons in May?
select sum(f.totalenrollments) as totalenrollments
from enrolment_fact f, instrumentdim i, monthdim m
where f.instrumentid = i.instrumentid and f.monthid = m.monthid
and i.description = 'Violin' and m.monthname = 'May';

-- Based on the provided case study, management wants to compare the average revenue per enrollment for 
-- each instrument by month. Which instruments have increased in average revenue from May to June? 
-- If an instrument has no student enrollment in a given month, consider its average revenue to be 0.
select i.instrumentid, i.description, NVL(m.may_avg, 0) as may_avg, NVL(j.june_avg, 0) as june_avg
from instrumentdim i
left join (
    select f.instrumentid, sum(f.totalrevenue) / sum(f.totalenrollments) as may_avg
    from enrolment_fact f
    where f.monthid = 5
    group by f.instrumentid
) m on i.instrumentid = m.instrumentid
left join (
    select f.instrumentid, sum(f.totalrevenue) / sum(f.totalenrollments) as june_avg
    from enrolment_fact f
    where f.monthid = 6
    group by f.instrumentid
) j on i.instrumentid = j.instrumentid
where NVL(j.june_avg, 0) > NVL(m.may_avg, 0)
order by i.instrumentid;

---------------------------------------------------------------------------------------

-- Based on the provided assignment, what is the total number of enrollments for each instrument by month, 
-- where the instructors hold a Diploma? (Month answer as text not a number)
select i.instrumentid, i.description, m.monthname, sum(f.totalenrollments) as total_enrolments
from enrolment_fact f, instrumentdim i, monthdim m, instructordim ins
where f.instrumentid = i.instrumentid 
    and f.monthid = m.monthid 
    and f.instructorid = ins.instructorid
    and ins.qualification = 'Diploma'
group by i.instrumentid, i.description, m.monthname
order by i.instrumentid;

-- Based on the provided case study, management wants to know the average revenue per enrollment for each instructor. 
-- Please order the instructors from highest to lowest average revenue per enrollment in your answer.
select i.instructorid, i.firstname, i.lastname, sum(f.totalrevenue)/sum(totalenrollments)
from enrolment_fact f, instructordim i
where f.instructorid = i.INSTRUCTORID
group by i.instructorid, i.firstname, i.lastname
order by sum(f.totalrevenue)/sum(totalenrollments) DESC;

-- Based on the provided case study, identify which class size has the lowest total revenue and which class 
-- size has the lowest number of enrollments. Additionally, determine which class size would be worth expanding 
-- with additional classes based on the average revenue per enrollment.
select c.classsizeid, c.classsizename, sum(totalrevenue) as revenue, sum(totalenrollments) as enrolments, sum(totalrevenue)/sum(totalenrollments) revperenrol
from enrolment_fact f, classsizedim c
where f.classsizeid = c.CLASSSIZEID
group by c.classsizeid, c.classsizename;

-- Based on the provided assignment, which of the following instruments are missing enrollment from at 
-- least one age group? Please provide the instrument names along with the age group(s) that have no 
-- enrollment in those instruments.
select i.instrumentid, i.description, a.agegroupname, sum(totalenrollments)
from ENROLMENT_FACT f, instrumentdim i, agegroupdim a
where f.instrumentid = i.instrumentid
    and f.agegroupid = a.AGEGROUPID
group by i.instrumentid, i.description, a.agegroupname
having count(distinct i.instrumentid) < 3
order by i.instrumentid;

-- BETTER WAY
-- this one generates every instrument and age group combo and then finds which are missing from the fact table
-- A null fact key means no enrollment exists for that instrument and age group.
select i.instrumentid, i.description, a.AGEGROUPNAME
from instrumentdim i cross join agegroupdim a
left join enrolment_fact f on f.instrumentid = i.instrumentid and f.agegroupid = a.AGEGROUPID
where f.agegroupid is NULL;



--Based on the provided assignment and the dataset, identify the instructors who teach more than one distinct 
--instrument. Please provide their names and ensure the results are ordered by instructor ID in ascending order.
select ins.instructorid, ins.firstname, ins.lastname, count(distinct i.instrumentid) as num_instruments
from enrolment_fact f, instructordim ins, instrumentdim i
where f.INSTRUCTORID = ins.instructorid and f.instrumentid = i.instrumentid
group by ins.instructorid, ins.firstname, ins.lastname
having count(distinct i.instrumentid) > 1
order by ins.instructorid;

-- Based on the provided assignment, what is the total number of enrolments for violin lessons in May?
select sum(f.totalenrollments) as total_enrolments
from enrolment_fact f, monthdim m, instrumentdim i
where f.monthid = m.monthid and f.instrumentid = i.instrumentid 
and m.monthname = 'May' and i.description = 'Violin';