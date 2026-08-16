-- Data exploration
select * from dw.pilot;
select * from dw.pilot_1;
select * from dw.charter;

select * from dw.customer;
select * from dw.employee;
select * from dw.aircraft;
select * from dw.model;

-- Checking if any flights have same pilot and copilot
select *
from dw.charter
where char_pilot = CHAR_COPILOT;

select *
from dw.charter
where char_pilot = NULL;

-- checking for duplicates in pilot table
select emp_num, count(*)
from dw.pilot
group by emp_num
having count(*) > 1;

-- checking for duplicated in charter table
select char_trip, count(*)
from dw.CHARTER
group by char_trip
having count(*) > 1;

-- inspecting the duplicate
select * from dw.charter
where char_trip = 10268;

-- making the dimensions
create table time_dim As
select Distinct to_char(char_date, 'YYYYMM') as Time_ID,
                to_char(char_date, 'Month') as Time_Month,
                to_char(char_date, 'YYYY') as Time_Year
from dw.Charter;

create table model_dim as
select * from dw.model;

create table pilot_dim as
select * from dw.pilot;

commit;

create table charter_fact as
select 
    to_char(c.char_date, 'YYYYMM') as time_id, 
    m.mod_code, 
    c.char_pilot as emp_num, 
    sum(c.char_hours_flown) as total_char_hours, 
    sum(c.char_fuel_gallons) as total_fuel, 
    sum(c.char_distance * m.mod_chg_mile) as total_revenue
from dw.charter c, dw.model m, dw.aircraft a
where c.ac_number = a.ac_number and a.mod_code = m.mod_code
group by to_char(c.char_date, 'YYYYMM'), m.mod_code, c.char_pilot;

-- Time flown for emp 101
select * from charter_fact
where emp_num = 101
order by time_id;

select sum(total_char_hours)
from charter_fact
where emp_num = 101 and time_id = '199704';

select *
from dw.CHARTER
where (char_pilot = 101 or char_copilot = 101) 
and to_char(char_date, 'YYYYMM') = '199704';

-- Creating another fact table just for copilot
create table charter_fact2 as
select 
    to_char(c.char_date, 'YYYYMM') as time_id, 
    m.mod_code, 
    c.char_copilot as emp_num, 
    sum(c.char_hours_flown) as total_char_hours, 
    sum(c.char_fuel_gallons) as total_fuel, 
    sum(c.char_distance * m.mod_chg_mile) as total_revenue
from dw.charter c, dw.model m, dw.aircraft a
where c.ac_number = a.ac_number and a.mod_code = m.mod_code
group by to_char(c.char_date, 'YYYYMM'), m.mod_code, c.char_copilot;

-- seeing how many entries in each fact table
select count(*) from charter_fact;
select count(*) from charter_fact2;

-- Merging the two fact tables into one to count for both pilot time and copilot time
create table charter_fact3 as
select 
time_id, 
mod_code, 
emp_num, 
sum(total_char_hours) as total_char_hours, 
sum(total_fuel) as total_fuel, 
sum(total_revenue) as total_revenue
from (
    select * from charter_fact
    union
    select * from charter_fact2)
group by time_id, mod_code, emp_num;



