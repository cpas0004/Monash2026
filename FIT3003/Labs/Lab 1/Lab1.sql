select *
  from tab;

-- CREATE TABLE LECTURER
-- (StaffNO 			NUMBER(6) 		NOT NULL, 
--  Title				VARCHAR2(3),
--  FName 				VARCHAR2(30),
--  LName				VARCHAR2(30),
--  StreetAddress		VARCHAR2(70), 
--  Suburb				VARCHAR2(40), 
--  City				VARCHAR2(40), 
--  PostCode			VARCHAR2(4), 
--  Country				VARCHAR2(30),
--  LecturerLevel		CHAR(2), 
--  BankNO				CHAR(20),
--  BankName			VARCHAR2(40),
--  Salary				NUMBER(8,2), 
--  WorkLoad			NUMBER(2,1) 	NOT NULL, 
--  ResearchArea			VARCHAR2(40),
--  PRIMARY KEY(StaffNo));

insert into lecturer (
   staffno,
   title,
   fname,
   lname,
   streetaddress,
   suburb,
   city,
   postcode,
   country,
   lecturerlevel,
   bankno,
   bankname,
   salary,
   workload,
   researcharea
) values
   ( 1000,
     'Dr',
     'David',
     'Taniar',
     '3 Robinson Av',
     'Kew',
     'Melbourne',
     '3080',
     'Australia',
     '5',
     '1000567237',
     'CommBank',
     89000.00,
     2.0,
     'O-R DB' );

insert into lecturer (
   staffno,
   title,
   fname,
   lname,
   streetaddress,
   suburb,
   city,
   postcode,
   country,
   lecturerlevel,
   bankno,
   bankname,
   salary,
   workload,
   researcharea
) values
   ( 2000,
     'Ms',
     'Julie',
     'Main',
     '6 Algorithm Av',
     'Montmorency',
     'Melbourne',
     '3089',
     'Australia',
     '5',
     '1000123456',
     'CommBank',
     89000.00,
     2.0,
     'CBR' );

insert into lecturer values
   ( 3000,
     'Mr',
     'Daniel',
     'Wright',
     '22 Crystal Cres',
     'Alphington',
     'Melbourne',
     '3790',
     'Australia',
     '5',
     '1000654321',
     'CommBank',
     89000.00,
     2.0,
     'DB' );

insert into lecturer (
   staffno,
   title,
   fname,
   lname,
   streetaddress,
   suburb,
   postcode,
   country,
   researcharea,
   workload
) values
   ( 4000,
     'Mr',
     'RaiHong',
     'Lam',
     '12 Oracle Dr',
     'Fitzroy',
     '3424',
     'Australia',
     'Data Mining',
     1 );

select *
  from lecturer;

create table student (
   studentno   number(6) not null,
   dob         date,
   fname       varchar2(30),
   lname       varchar2(30),
 -- city spelt CiTTy
   citty       varchar2(40),
   postcode    varchar2(4),
   country     varchar2(30),
   feepaid     number(8,2),
   lastfeedate date,
   primary key ( studentno )
);


insert into student values
   ( 30001,
     to_date('12-MAR-2001','DD-MON-YYYY'),
     'John',
     'Smith',
     'Melbourne',
     '3000',
     'Australia',
     10000.00,
     to_date('21-JUL-2026','DD-MON-YYYY') );
insert into student values
   ( 30002,
     to_date('15-APR-2002','DD-MON-YYYY'),
     'Jane',
     'Doe',
     'Melbourne',
     '3000',
     'Australia',
     12000.00,
     to_date('15-JUL-2026','DD-MON-YYYY') );
insert into student values
   ( 30003,
     to_date('20-MAY-2003','DD-MON-YYYY'),
     'Alice',
     'Johnson',
     'Sydney',
     '2000',
     'Australia',
     15000.00,
     to_date('10-JUL-2026','DD-MON-YYYY') );
insert into student values
   ( 30004,
     to_date('25-JUN-2001','DD-MON-YYYY'),
     'Bob',
     'Brown',
     'Brisbane',
     '4000',
     'Australia',
     8000.00,
     to_date('05-JUL-2026','DD-MON-YYYY') );
insert into student values
   ( 30005,
     to_date('30-JUL-2002','DD-MON-YYYY'),
     'Charlie',
     'Davis',
     'Sydney',
     '2000',
     'Australia',
     11000.00,
     to_date('12-JUL-2026','DD-MON-YYYY') );

alter table student add (
   streetaddress varchar2(70),
   suburb        varchar2(40)
);

DESCRIBE STUDENT;

alter table student drop ( citty );

alter table student add (
   city char(40)
);

alter table student modify (
   city varchar2(40)
);

update student
   set
   streetaddress = '12 New St'
 where studentno = 30001;

select *
  from student;

commit;

create table subject
   as
      select *
        from dtaniar.subject;

create table lecture
   as
      select *
        from dtaniar.lecture;

create table tutor
   as
      select *
        from dtaniar.tutor;

create table lab
   as
      select *
        from dtaniar.lab;

create table student_enrolment
   as
      select *
        from dtaniar.student_enrolment;

create table lab_signup
   as
      select *
        from dtaniar.lab_signup;

-- Write an SQL statement to list all the lecturers and their lecture schedules
select l.fname,
       l.lname,
       s.name as subjectname,
       le.lectday,
       TO_CHAR(le.lecttime, 'HH24:MI') as lecttime
  from lecturer l
  join lecture le
on l.staffno = le.staffno
  join subject s
on le.subjectcode = s.subjectcode
 order by l.lname,
          le.lectday,
          le.lecttime;

-- Are there any lecturers who are not teaching?
select l.fname,
       l.lname
  from lecturer l
  left join lecture le
on l.staffno = le.staffno
where le.staffno is null;

-- or

select l.staffno, l.fname, l.lname
from lecturer l
where l.staffno not in (select distinct staffno from lecture);

-- List all the subjects offered in the first semester.
select * from subject where semester = 1;

-- List all the students by first-name, last-name, date-of-birth, and fee-paid details, who are born after 1990 and before 1995.
select s.fname,
        s.lname,
        s.dob,
        s.feepaid,
        s.lastfeedate
from student s
where s.DOB between to_date('01-JAN-1991','DD-MON-YYYY') and to_date('31-DEC-1994','DD-MON-YYYY');

-- List all the students enrolled in the database subject. (Note: database = CSE21DB, CSE31DB, CSE41FDB)
select distinct s.fname, s.lname
from student s join student_enrolment se
on s.studentno = se.studentno
where se.subjectcode in ('CSE21DB', 'CSE31DB', 'CSE41FDB');

-- List the students who are tutors.
select distinct s.fname, s.lname
from student s join tutor t
on s.studentno = t.studentno;

-- Select the lecturer(s) whose research area is 'Network Management'.
select l.staffno, l.fname, l.lname
from lecturer l
where l.researcharea = 'Network Management';

-- Calculate the average salary of a lecturer.
select AVG(l.salary) as average_salary
from lecturer l;

-- Calculate the minimum and maximum salary of the lecturers.
select MIN(l.salary) as minimum_salary,
       MAX(l.salary) as maximum_salary
from lecturer l;

-- List the number of tutors by each subject and semester.
select s.subjectcode,
       s.name,
       s.semester,
       count(distinct t.tutorno) as number_of_tutors
from tutor t
join lab l
    on t.tutorno = l.tutorno
join subject s
    on l.subjectcode = s.subjectcode
group by s.subjectcode,
    s.name,
    s.semester;

-- List the total number of students in each lab, for each subject, with the tutor's name.
select su.subjectcode, 
    su.name as subject_name, 
    la.labno, la.labday, 
    TO_CHAR(TO_DATE(la.labtime, 'HH24:MI'), 'HH24:MI') as labtime, 
    s.fname||' '||s.lname as tutor_name, 
    count(ls.STUDENTNO) as number_of_students
from subject su join lab la on su.subjectcode = la.SUBJECTCODE
join tutor tu on la.tutorno = tu.tutorno
join student s on s.studentno = tu.studentno
left join lab_signup ls on la.labno = ls.labno -- left join to capture labs with no students
group by 
    su.subjectcode, 
    su.name, 
    la.labno, 
    la.labday, 
    la.labtime, 
    s.fname, 
    s.lname
order by 
    su.subjectcode, 
    la.labno;

-- Calculate the cost of running all the database labs per week. (Hint: lab duration * tutors' SALARYPERHOUR)
select SUM(la.duration*tu.salaryperhour) as total_cost
from lab la join tutor tu on la.tutorno = tu.tutorno
where la.subjectcode in ('CSE21DB', 'CSE31DB', 'CSE41FDB');
