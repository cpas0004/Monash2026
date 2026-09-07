drop table yearDIM;

select * from ptetest.test;

select * from ptetest.test_result;

create table yearDIM as
select distinct to_char(testdate, 'YYYY') as year
from ptetest.test;

select * from yearDIM;

select * from ptetest.test_venue;

create table CountryVenueDIM as
select distinct c.countrycode, c.countryname, t.testprice
from ptetest.test_venue t, ptetest.country c
where t.countrycode = c.countrycode;

select * from CountryVenueDIM;

create table CitizenshipDIM as
select distinct c.countrycode, c.countryname
from ptetest.country c, ptetest.student s
where c.countrycode = s.citizenship;

select * from CitizenshipDIM;

drop table gradeDIM;

create table gradeDIM (
    grade varchar2(3),
    description varchar2(20),
    minscore number,
    maxscore number
);

insert into gradeDIM values('4.5', 'Functional', 30, 35);
insert into gradeDIM values('5', 'Vocational', 36, 49);
insert into gradeDIM values('6', 'Competent', 50, 64);
insert into gradeDIM values('7', 'Proficient', 65, 78);
insert into gradeDIM values('8-9', 'Superior', 79, 90);

create table TestComponentDIM (
    TestComponent varchar2(20)
);

insert into TestComponentDIM values('Listening');
insert into TestComponentDIM values('Reading');
insert into TestComponentDIM values('Writing');
insert into TestComponentDIM values('Speaking');
insert into TestComponentDIM values('Overall');

create table tempfact as
select tv.countrycode, s.citizenship, to_char(t.testdate, 'YYYY') as year,
    tr.registrationid,
    tr.listeningscore,
    tr.readingscore,
    tr.writingscore,
    tr.speakingscore,
    tr.overallscore
from ptetest.test_venue tv, ptetest.test t, ptetest.student s, ptetest.test_result tr
where tv.venueid = t.venueid and t.testno = tr.testno and s.registrationid = tr.registrationid;

alter table tempfact add(
    gradeoverall varchar2(3),
    gradelistening varchar2(3),
    gradereading varchar2(3),
    gradewriting varchar2(3),
    gradespeaking varchar2(3)
);

commit;

-- update tempfact set gradeoverall = (select grade from gradeDIM where overallscore between minscore and maxscore);

update tempfact set gradeoverall = (
case
when overallscore between 30 and 35 then '4.5'
when overallscore between 36 and 49 then '5'
when overallscore between 50 and 64 then '6'
when overallscore between 65 and 78 then '7'
when overallscore between 79 and 90 then '8-9'
end
);

update tempfact set gradelistening = (
case
when listeningscore between 30 and 35 then '4.5'
when listeningscore between 36 and 49 then '5'
when listeningscore between 50 and 64 then '6'
when listeningscore between 65 and 78 then '7'
when listeningscore between 79 and 90 then '8-9'
end
);

update tempfact set gradereading = (
case
when readingscore between 30 and 35 then '4.5'
when readingscore between 36 and 49 then '5'
when readingscore between 50 and 64 then '6'
when readingscore between 65 and 78 then '7'
when readingscore between 79 and 90 then '8-9'
end
);

update tempfact set gradewriting = (
case
when writingscore between 30 and 35 then '4.5'
when writingscore between 36 and 49 then '5'
when writingscore between 50 and 64 then '6'
when writingscore between 65 and 78 then '7'
when writingscore between 79 and 90 then '8-9'
end
);

update tempfact set gradespeaking = (
case
when speakingscore between 30 and 35 then '4.5'
when speakingscore between 36 and 49 then '5'
when speakingscore between 50 and 64 then '6'
when speakingscore between 65 and 78 then '7'
when speakingscore between 79 and 90 then '8-9'
end
);

select * from tempfact;

create table overallfact as
select countrycode, citizenship, year, gradeoverall as grade, 'overall' as test_component, count(registrationid) as total_student_overall
from tempfact
group by countrycode, citizenship, year, gradeoverall, 'overall';

create table listeningfact as
select countrycode, citizenship, year, gradelistening as grade, 'listening' as test_component, count(registrationid) as total_student_listening
from tempfact
group by countrycode, citizenship, year, gradelistening, 'listening';

create table readingfact as
select countrycode, citizenship, year, gradereading as grade, 'reading' as test_component, count(registrationid) as total_student_reading
from tempfact
group by countrycode, citizenship, year, gradereading, 'reading';

create table writingfact as
select countrycode, citizenship, year, gradewriting as grade, 'writing' as test_component, count(registrationid) as total_student_writing
from tempfact
group by countrycode, citizenship, year, gradewriting, 'writing';

create table speakingfact as
select countrycode, citizenship, year, gradespeaking as grade, 'speaking' as test_component, count(registrationid) as total_student_speaking
from tempfact
group by countrycode, citizenship, year, gradespeaking, 'speaking';

create table finalfact as 
select countrycode, citizenship, year, grade, test_component, total_student_overall as total_students
from overallfact
union
select * from listeningfact
union
select * from readingfact
union
select * from writingfact
union
select * from speakingfact;

select * from finalfact;
select * from finalfact where countrycode = 'AU';

--How many students received a Competent grade in their overall score?  
select sum(total_students) as total_competent_students
from finalfact f, gradedim g
where f.grade = g.grade and f.test_component = 'overall' and g.description = 'Competent';

-- How many students took the test in 2017? 
select sum(total_students) as total_2017_students
from finalfact f
where year = '2017' and test_component = 'overall';

-- How many Korean citizen students took test? 
select sum(total_students) as total_korean_students
from finalfact f, citizenshipdim c
where f.citizenship = c.countrycode and c.countryname = 'Korea' and f.test_component = 'overall';

-- How many students took the test in Australia? 
select sum(total_students) as total_australia_venue_students
from finalfact f, countryvenuedim c
where f.countrycode = c.countrycode and c.countryname = 'Australia' and f.test_component = 'overall';

-- How many Chinese students received a Proficient Grade in the  Listening part in 2017? 
select sum(total_students) as total_students
from finalfact f, citizenshipdim c, gradedim g
where f.citizenship = c.countrycode and f.grade = g.grade 
and c.countryname = 'China' and g.description = 'Proficient' and f.test_component = 'listening' and f.year = '2017';

----------------------------------------------------

-- Now to create a pivoted version of the fact table (moving the test_component dim to be part of the fact measure)

select * from citizenshipdim;

-- to keep track of zero counts, we need to create a table with all combinations of the dimensions
create table alldimensions as
select c.countrycode, ci.countrycode as citizenship, y.year, g.grade
from countryvenuedim c, citizenshipdim ci, yeardim y, gradedim g;

select * from alldimensions;

-- recreating the 5 tables to include all combinations and to track zeros by using outer joins
create table overallfactnew as
select a.countrycode, a.citizenship, a.year, a.grade, nvl(o.total_student_overall, 0) as total_students_overall
from alldimensions a left outer join overallfact o 
on a.countrycode = o.countrycode and a.citizenship = o.citizenship and a.year = o.year and a.grade = o.grade;

create table listeningfactnew as
select a.countrycode, a.citizenship, a.year, a.grade, nvl(o.total_student_listening, 0) as total_students_listening
from alldimensions a left outer join listeningfact o 
on a.countrycode = o.countrycode and a.citizenship = o.citizenship and a.year = o.year and a.grade = o.grade;

create table speakingfactnew as
select a.countrycode, a.citizenship, a.year, a.grade, nvl(o.total_student_speaking, 0) as total_students_speaking
from alldimensions a left outer join speakingfact o 
on a.countrycode = o.countrycode and a.citizenship = o.citizenship and a.year = o.year and a.grade = o.grade;

create table writingfactnew as
select a.countrycode, a.citizenship, a.year, a.grade, nvl(o.total_student_writing, 0) as total_students_writing
from alldimensions a left outer join writingfact o 
on a.countrycode = o.countrycode and a.citizenship = o.citizenship and a.year = o.year and a.grade = o.grade;

create table readingfactnew as
select a.countrycode, a.citizenship, a.year, a.grade, nvl(o.total_student_reading, 0) as total_students_reading
from alldimensions a left outer join readingfact o 
on a.countrycode = o.countrycode and a.citizenship = o.citizenship and a.year = o.year and a.grade = o.grade;

-- now creating the new final fact table (this is now a join, not a union)
create table finalfactnew as
select o.countrycode, o.citizenship, o.year, o.grade, 
o.total_students_overall, 
l.total_students_listening, 
r.total_students_reading, 
w.total_students_writing, 
s.total_students_speaking
from overallfactnew o, listeningfactnew l, readingfactnew r, writingfactnew w, speakingfactnew s
where o.countrycode = l.countrycode and o.citizenship = l.citizenship and o.year = l.year and o.grade = l.grade
and o.countrycode = r.countrycode and o.citizenship = r.citizenship and o.year = r.year and o.grade = r.grade
and o.countrycode = w.countrycode and o.citizenship = w.citizenship and o.year = w.year and o.grade = w.grade
and o.countrycode = s.countrycode and o.citizenship = s.citizenship and o.year = s.year and o.grade = s.grade;

select * from finalfactnew;

-- How many students received a Competent grade in their overall score?  
select sum(total_students_overall) as total_competent_students
from finalfactnew f, gradedim g
where f.grade = g.grade and g.description = 'Competent';

-- How many students took the test in 2017? 
select sum(total_students_overall) as total_2017_students
from finalfactnew f
where year = '2017';

-- How many Korean citizen students took test? 
select sum(total_students_overall) as total_korean_students
from finalfactnew f, citizenshipdim c
where f.citizenship = c.countrycode and c.countryname = 'Korea';

-- How many students took the test in Australia? 
select sum(total_students_overall) as total_australia_venue_students
from finalfactnew f, countryvenuedim c
where f.countrycode = c.countrycode and c.countryname = 'Australia';

-- How many Chinese students received a Proficient Grade in the  Listening part in 2017? 
select sum(total_students_listening) as total_students
from finalfactnew f, citizenshipdim c, gradedim g
where f.citizenship = c.countrycode and f.grade = g.grade
and c.countryname = 'China' and g.description = 'Proficient' and f.year = '2017';



