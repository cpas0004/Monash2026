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


