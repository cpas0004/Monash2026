select * from DTANIAR.REVIEW5;
select * from DTANIAR.SALES5;
select * from DTANIAR.STORE5;
select * from DTANIAR.CATEGORY5;
select * from DTANIAR.BOOK5;

-- Creating the dimensions
drop table timeDIM;

create table timeDIM as
select distinct 
    to_char(salesdate, 'YYYYMM') as timeID,
    to_char(salesdate, 'YYYY') as year,
    to_char(salesdate, 'MM') as month
from DTANIAR.SALES5;

select * from timedim;

create table storeDIM as
select * from DTANIAR.STORE5;

create table categoryDIM as
select * from DTANIAR.CATEGORY5;

create table starratingDIM (
    StarID number(1) primary key,
    StarDescription varchar2(20) not null
);

insert into starratingDIM values (0, 'Unknown');
insert into starratingDIM values (1, 'Poor');
insert into starratingDIM values (2, 'Not Good');
insert into starratingDIM values (3, 'Average');
insert into starratingDIM values (4, 'Good');
insert into starratingDIM values (5, 'Excellent');

-- Creating the ReviewFact
create table ReviewFact as
select c.categoryID, r.stars as starID, count(*) as num_of_reviews
from DTANIAR.CATEGORY5 c, DTANIAR.BOOK5 b, DTANIAR.REVIEW5 r
where c.categoryid = b.categoryid and b.isbn = r.isbn
group by c.categoryid, r.stars;

select * from ReviewFact;

-- Working towards the BookSalesFact

create table TempBookWithStar as
select b.isbn, b.categoryid, nvl(r.stars, 0) as stars
from DTANIAR.BOOK5 b LEFT OUTER JOIN DTANIAR.REVIEW5 r ON b.ISBN = r.ISBN;

select * from TempBookWithStar;

drop table TempBookWithAvgStarTest;

create table TempBookWithAvgStarTest as
select isbn, categoryid, round(sum(stars)/count(*)) as avg_stars
from TempBookWithStar
group by isbn, categoryid;

select * from TempBookWithAvgStarTest;

create table TempBookWithAvgStar as
select ISBN, CategoryID, round(avg(Stars)) as Avg_Stars
from TempBookWithStar
group by ISBN, CategoryID;

select * from TempBookWithAvgStar;

-- Creating the BookSalesFact

create table BookSalesFact as
select s.storeid, b.categoryid, to_char(s.salesdate, 'YYYYMM') as timeid, b.avg_stars as starid, sum(sd.quantity) as num_of_books, sum(sd.totalprice) as total_sales
from TempBookWithAvgStar b, DTANIAR.SALESDETAILS5 sd, DTANIAR.SALES5 s
where b.isbn = sd.isbn and sd.salesid = s.salesid
group by s.storeid, b.categoryid, to_char(s.salesdate, 'YYYYMM'), b.avg_stars;

select * from BookSalesFact;

-- What are the total sales for each bookstore in a Feb 2015?
select storeID, sum(total_sales) as total_sales
from booksalesfact b, timeDIM t
where b.timeid = t.TIMEID
and t.year = '2015' and t.month = '02'
group by storeID
order by storeID;

-- What is the number of books sold for each category?
select c.categorydescription, sum(num_of_books) as num_of_books
from booksalesfact b, categorydim c
where b.categoryid = c.CATEGORYID
group by c.categorydescription;

-- What is the book category with the highest number of books sold?
select c.categorydescription, sum(num_of_books) as num_of_books
from booksalesfact b, categorydim c
where b.categoryid = c.CATEGORYID
group by c.categorydescription
order by num_of_books desc
fetch first 1 row only;

-- What is the number of reviews for each category?
select c.categorydescription, sum(num_of_reviews) as num_of_reviews
from reviewfact r, categorydim c
where r.categoryid = c.CATEGORYID
group by c.categorydescription;

-- How many 5-star reviews for each category?
select * from reviewfact;

select c.categorydescription, sum(num_of_reviews) as num_of_reviews
from reviewfact r, categorydim c
where r.categoryid = c.CATEGORYID AND r.starid = 5
group by c.categorydescription;