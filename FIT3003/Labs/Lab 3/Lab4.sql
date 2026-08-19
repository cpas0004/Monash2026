-- solution model 1

-- creating the database
Create Table Warehouse
(WarehouseID  Varchar2(10) Not Null,
 Location     Varchar2(10) Not Null,
 Primary Key (WarehouseID)
);

Create Table Truck
(TruckID        Varchar2(10) Not Null,
 VolCapacity    Number(5,2), 
 WeightCategory Varchar2(10),
 CostPerKm      Number(5,2),
 Primary Key (TruckID)
);

Create Table Trip 
(TripID   Varchar2(10) Not Null,
 TripDate Date,
 TotalKm  Number(5),
 TruckID  Varchar2(10),
 Primary Key (TripID),
 Foreign Key (TruckID) References Truck(TruckID)
);

Create Table TripFrom
(TripID      Varchar2(10) Not Null,
 WarehouseID Varchar2(10) Not Null,
 Primary Key (TripID, WarehouseID),
 Foreign Key (TripID) References Trip(TripID),
 Foreign Key (WarehouseID) References Warehouse(WarehouseID)
);

Create Table Store
(StoreID      Varchar2(10) Not Null,
 StoreName    Varchar2(20),
 StoreAddress Varchar2(20),
 Primary Key (StoreID)
);

Create Table Destination
(TripID       Varchar2(10) Not Null,
 StoreID      Varchar2(10) Not Null,
 Primary Key (TripID, StoreID),
 Foreign Key (TripID) References Trip(TripID),
 Foreign Key (StoreID) References Store(StoreID)
);

--Insert Records to Operational Database
Insert Into Warehouse Values ('W1','Warehouse1');
Insert Into Warehouse Values ('W2','Warehouse2');
Insert Into Warehouse Values ('W3','Warehouse3');
Insert Into Warehouse Values ('W4','Warehouse4');
Insert Into Warehouse Values ('W5','Warehouse5');

Insert Into Truck Values ('Truck1', 250, 'Medium', 1.2);
Insert Into Truck Values ('Truck2', 300, 'Medium', 1.5);
Insert Into Truck Values ('Truck3', 100, 'Small',  0.8);
Insert Into Truck Values ('Truck4', 550, 'Large',  2.3);
Insert Into Truck Values ('Truck5', 650, 'Large',  2.5);

Insert Into Trip Values ('Trip1', to_date('14-Apr-2013', 'DD-MON-YYYY'), 370, 'Truck1');
Insert Into Trip Values ('Trip2', to_date('14-Apr-2013', 'DD-MON-YYYY'), 570, 'Truck2');
Insert Into Trip Values ('Trip3', to_date('14-Apr-2013', 'DD-MON-YYYY'), 250, 'Truck3');
Insert Into Trip Values ('Trip4', to_date('15-Jul-2013', 'DD-MON-YYYY'), 450, 'Truck1');
Insert Into Trip Values ('Trip5', to_date('15-Jul-2013', 'DD-MON-YYYY'), 175, 'Truck2');

Insert Into TripFrom Values ('Trip1', 'W1');
Insert Into TripFrom Values ('Trip1', 'W4');
Insert Into TripFrom Values ('Trip1', 'W5');
Insert Into TripFrom Values ('Trip2', 'W1');
Insert Into TripFrom Values ('Trip2', 'W2');
Insert Into TripFrom Values ('Trip3', 'W1');
Insert Into TripFrom Values ('Trip3', 'W5');
Insert Into TripFrom Values ('Trip4', 'W1');
Insert Into TripFrom Values ('Trip5', 'W4');
Insert Into TripFrom Values ('Trip5', 'W5');

Insert Into Store Values ('M1', 'Myer City', 'Melbourne');
Insert Into Store Values ('M2', 'Myer Chaddy', 'Chadstone');
Insert Into Store Values ('M3', 'Myer HiPoint', 'High Point');
Insert Into Store Values ('M4', 'Myer West', 'Doncaster');
Insert Into Store Values ('M5', 'Myer North', 'Northland');
Insert Into Store Values ('M6', 'Myer South', 'Southland');
Insert Into Store Values ('M7', 'Myer East', 'Eastland');
Insert Into Store Values ('M8', 'Myer Knox', 'Knox');

Insert Into Destination Values ('Trip1', 'M1');
Insert Into Destination Values ('Trip1', 'M2');
Insert Into Destination Values ('Trip1', 'M4');
Insert Into Destination Values ('Trip1', 'M3');
Insert Into Destination Values ('Trip1', 'M8');

Insert Into Destination Values ('Trip2', 'M4');
Insert Into Destination Values ('Trip2', 'M1');
Insert Into Destination Values ('Trip2', 'M2');

Insert into Destination Values ('Trip3', 'M1');
Insert into Destination Values ('Trip3', 'M5');
Insert into Destination Values ('Trip3', 'M6');

Insert into Destination Values ('Trip4', 'M8');
Insert into Destination Values ('Trip4', 'M2');

Insert into Destination Values ('Trip5', 'M3');
Insert into Destination Values ('Trip5', 'M7');
Insert into Destination Values ('Trip5', 'M4');
Insert into Destination Values ('Trip5', 'M1');

-- creating the dimensions

create table truckdim1 as
select * from truck;

create table tripdim1 as
select tripid, tripdate, totalkm from trip;

create table bridgetabledim1 as
select * from destination;

create table storedim1 as
select * from store;

create table tripseasondim1 (
    SeasonID number primary key,
    Seasonperiod varchar2(20) Not Null
);

insert into tripseasondim1 values (1, 'Summer');
insert into tripseasondim1 values (2, 'Autumn');
insert into tripseasondim1 values (3, 'Winter');
insert into tripseasondim1 values (4, 'Spring');

commit;

-- creating temp fact table
create table temptruckfact1 as
select tr.truckid, t.tripid, t.tripdate
from truck tr, trip t
where tr.truckid = t.truckid;

alter table temptruckfact1 add (seasonid number);

update temptruckfact1
set seasonid = 1
where to_char(tripdate, 'MMDD') >= '1201'
and to_char(tripdate, 'MMDD') <= '0228';

update temptruckfact1
set seasonid = 2
where to_char(tripdate, 'MMDD') >= '0301'
and to_char(tripdate, 'MMDD') <= '0531';

update temptruckfact1
set seasonid = 3
where to_char(tripdate, 'MMDD') >= '0601'
and to_char(tripdate, 'MMDD') <= '0831';

update temptruckfact1
set seasonid = 4
where to_char(tripdate, 'MMDD') >= '0901'
and to_char(tripdate, 'MMDD') <= '1130';

-- creating the fact table
create table truckfact1 as
select t.truckid, tf.seasonid, t.tripid, t.totalkm*tr.costperkm as total_delivery_cost
from temptruckfact1 tf, trip t, truck tr
where tf.tripid = t.tripid and tf.truckid = tr.truckid;

select * from truckfact1;


-- solution model 2

create table truckdim2 as
select * from truck;

create table bridgetabledim2 as
select * from destination;

create table storedim2 as
select * from store;

create table tripseasondim2 (
    SeasonID number primary key,
    Seasonperiod varchar2(20) Not Null
);

insert into tripseasondim2 values (1, 'Summer');
insert into tripseasondim2 values (2, 'Autumn');
insert into tripseasondim2 values (3, 'Winter');
insert into tripseasondim2 values (4, 'Spring');

commit;

select * from trip;
select * from destination;

-- creating the trip dimension with weight factor

select t.tripid, t.tripdate, t.totalkm, count(*) as total_stores
from trip t join destination d on t.tripid = d.tripid
group by t.tripid, t.tripdate, t.totalkm;

select t.tripid, t.tripdate, t.totalkm, 1/count(*) as weight_factor
from trip t join destination d on t.tripid = d.tripid
group by t.tripid, t.tripdate, t.totalkm;

create table tripdim2 as
select t.tripid, t.tripdate, t.totalkm, 1/count(*) as weight_factor
from trip t join destination d on t.tripid = d.tripid
group by t.tripid, t.tripdate, t.totalkm;

-- creating the temp fact table
drop table temptruckfact2;

create table temptruckfact2 as 
select t.tripid, t.tripdate, tr.truckid, t.totalkm*tr.costperkm as total_delivery_cost
from trip t, truck tr
where t.truckid = tr.truckid;

alter table temptruckfact2 add (seasonid number);

update temptruckfact2
set seasonid = 1
where to_char(tripdate, 'MMDD') >= '1201'
and to_char(tripdate, 'MMDD') <= '0228';

update temptruckfact2
set seasonid = 2
where to_char(tripdate, 'MMDD') >= '0301'
and to_char(tripdate, 'MMDD') <= '0531';

update temptruckfact2
set seasonid = 3
where to_char(tripdate, 'MMDD') >= '0601'
and to_char(tripdate, 'MMDD') <= '0831';

update temptruckfact2
set seasonid = 4
where to_char(tripdate, 'MMDD') >= '0901'
and to_char(tripdate, 'MMDD') <= '1130';

-- creating the fact table
drop table truckfact2;

create table truckfact2 as
select tf.truckid, tf.seasonid, tf.tripid, tf.total_delivery_cost
from temptruckfact2 tf;

-- having a look to compare the two models
select * from temptruckfact1;
select * from truckfact1;
select * from temptruckfact2;
select * from truckfact2;

--What is the total delivery cost for each store?

-- This finds the cost for each store for each trip, but does not aggregate the cost for each store
select s.storeid, s.storename, tf.total_delivery_cost*tr.weight_factor as store_delivery_cost
from storedim2 s, bridgetabledim2 b, tripdim2 tr, truckfact2 tf
where s.storeid = b.storeid and tr.tripid = b.tripid and tr.tripid = tf.tripid;

-- This aggregates the trip costs for each store, giving the total delivery cost for each store
select s.storeid, s.storename, sum(tf.total_delivery_cost*tr.weight_factor) as store_delivery_cost
from storedim2 s, bridgetabledim2 b, tripdim2 tr, truckfact2 tf
where s.storeid = b.storeid and tr.tripid = b.tripid and tr.tripid = tf.tripid
group by s.storeid, s.storename;

-- 