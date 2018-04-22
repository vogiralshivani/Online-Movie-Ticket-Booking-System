\c movies

/*--------------------SIMPLE QUERY 1-----------------------------------*/
Select No_of_Screens from Theatre where Name_of_Theatre = 'INOX Movies'; 

/*--------------------SIMPLE QUERY 2-----------------------------------*/
Select distinct Name from Show, Movie where Show.Movie_id = Movie.Movie_id and Show.Show_time = '09:00:00 AM' and Show_Date = '4/4/18';

/*--------------------SIMPLE QUERY 3-----------------------------------*/
Select distinct (Show_Time, Show_Date) from Show, Movie where Show.Movie_id = Movie.Movie_id and Movie.Name = 'Hichki';

/*--------------------SIMPLE QUERY 4-----------------------------------*/
Select Screen_id, No_of_seats_gold, No_of_seats_silver,  SUM(No_of_seats_gold + No_of_seats_silver) from Screen, Theatre where Screen.Theatre_id = Theatre.Theatre_id and Name_of_Theatre = 'PVR Cinemas' GROUP BY Screen_id;

/*--------------------SIMPLE QUERY 5-----------------------------------*/
Select Name from Movie where Movie.Language = 'English';


/*-------------------------------------------------------------------------*/


/*--------------------COMPLEX QUERY 1-----------------------------------*/
drop view most_sales_made;
create view most_sales_made as
(select t.name_of_theatre as theatre_name,count(ticket_id) as ticket_sales
from theatre t,ticket tkt,show s,booking b, screen scr
where t.theatre_id=scr.theatre_id and s.screen_id=scr.screen_id and s.show_id=b.show_id 
and tkt.booking_id=b.booking_id and s.show_date='5/4/18'
group by t.name_of_theatre);

select theatre_name,ticket_sales
from most_sales_made
where ticket_sales=(select max(ticket_sales) from most_sales_made);

/*--------------------COMPLEX QUERY 2-----------------------------------*/
drop view blockbuster_movie;
create view blockbuster_movie as
(select (m.name) as name_of_movie,count(b.booking_id) as no_of_bookings
from booking b,show s,movie m
where s.show_id=b.show_id and m.movie_id=s.movie_id group by m.name);

select name_of_movie as blockbuster_movie_of_the_day
from blockbuster_movie 
where no_of_bookings=(select max(no_of_bookings) from blockbuster_movie);

/*--------------------COMPLEX QUERY 3-----------------------------------*/
drop view movie_nerd;
create view movie_nerd as
(select distinct w.first_name as firstname,w.last_name as lastname,count(b.booking_id) as no_of_bookings
from web_user w,booking b
where w.web_user_id=b.user_id group by w.first_name,w.last_name);



select firstname,lastname
from movie_nerd
where no_of_bookings=(select max(no_of_bookings) from movie_nerd);



/*--------------------COMPLEX QUERY 4-----------------------------------*/
drop view most_popular_theatre;
create view most_popular_theatre as
(select t.name_of_theatre as theatre_name,count(b.booking_id) as no_of_bookings_received
from theatre t,show s,booking b, screen scr
where t.theatre_id=scr.theatre_id and s.screen_id=scr.screen_id and s.show_id=b.show_id 
and b.show_id=s.show_id group by t.name_of_theatre);

select theatre_name
from most_popular_theatre 
where no_of_bookings_received=(select max(no_of_bookings_received) from most_popular_theatre);

/*--------------------COMPLEX QUERY 5-----------------------------------*/
drop table web_user_reward_point;
create table web_user_reward_point as
(select w.web_user_id,w.first_name,w.last_name,count(t.ticket_id) as no_of_tickets_bought
from web_user w,ticket t,booking b
where w.web_user_id=b.user_id and b.booking_id=t.booking_id
group by w.first_name,w.last_name,w.web_user_id);
alter table web_user_reward_point
add reward_points int;
update web_user_reward_point
set reward_points=5*no_of_tickets_bought;


delete from web_user_reward_point where no_of_tickets_bought<20;
select * from web_user_reward_point;

/*--------------------COMPLEX QUERY 6-----------------------------------*/
drop table genre;
Create Table Genre(                                                                                                                                      
GenType varchar(15)
);
insert into Genre 
values('Drama'),('Comedy'),('Fantasy'),('Sci-Fi'),('Horror'),('Fantasy'),('Adventure'),('Romance'),('Action'),('Thriller'),('History');
;
select genre.gentype, count(genre.gentype) as number_of_tickets_booked 
from genre JOIN (select * from movie JOIN (select * from booking JOIN show on booking.show_id = show.show_id)p 
	on movie.movie_id = p.movie_id)q on  q.genre like '%' || genre.gentype || '%'  group by genre.gentype;

/*--------------------COMPLEX QUERY 7-----------------------------------*/
select movie.movie_id,movie.Name,sum(p.total_cost) 
from movie 
JOIN (select * from booking JOIN show on booking.show_id = show.show_id)p 
on movie.movie_id = p.movie_id group by movie.movie_id order by sum;

/*--------------------COMPLEX QUERY 8-----------------------------------*/
select language, sum(No_of_tickets) number_of_tickets_bought 
from movie JOIN (select * from booking JOIN show on booking.show_id = show.show_id)p 
on movie.movie_id = p.movie_id group by language;

/*--------------------COMPLEX QUERY 9-----------------------------------*/
select show_time,sum(No_of_tickets) as number_of_tickets_bought 
from movie JOIN (select * from booking JOIN show on booking.show_id = show.show_id)p 
on movie.movie_id = p.movie_id group by show_time;

/*--------------------COMPLEX QUERY 10-----------------------------------*/
drop view best_customer;
create view best_customer as
(select web_user_id,first_name,last_name,sum 
from Web_user 
JOIN (select user_id,sum(total_cost)  
from booking group by user_id)cost on Web_User.web_User_id=cost.user_id);

select * from best_customer
where sum=(select max(sum) from best_customer);
/*--------------------COMPLEX QUERY 11-----------------------------------*/
select t.name_of_theatre,scr.screen_id,s.show_time,s.Seats_Remaining_Gold,s.Seats_Remaining_Silver
from movie m,show s,theatre t,screen scr
where m.name='Hichki' and s.show_date='5/4/18' and scr.theatre_id=t.theatre_id 
and s.screen_id=scr.screen_id;

/*--------------------COMPLEX QUERY 12-----------------------------------*/
drop table Refund;
create table Refund as 
Select Booking_ID, web_user_id, first_name, last_name, total_cost as refunded_amount 
from Booking 
join Web_User on booking.user_id = web_user.web_user_id 
where Show_Id = (Select Show_Id from Show where Movie_ID = (Select Movie_ID from Movie where Name = 'Pacific Rim Uprising') and Screen_Id IN (Select Screen_ID from Screen where Theatre_ID = (Select Theatre_ID from Theatre where Name_of_Theatre = 'Cinepolis') ) and Show_Date = '6/4/18');

Delete from booking b where b.booking_id IN (Select Booking_ID from refund);

/*--------------------COMPLEX QUERY 13-----------------------------------*/
select m.name as requires_parental_guidance
from movie m
where m.genre='Fantasy/Scifi' or m.genre='Drama/Comedy' or m.genre='Romance/Comedy'
or m.genre='Horror' ;

/*--------------------COMPLEX QUERY 14-----------------------------------*/
select distinct(w.first_name,w.last_name) as name
from movie m,web_user w, booking b
where b.user_id=w.web_user_id and m.language='English' and m.language!='Kannada' and m.language!='Hindi';

/*--------------------COMPLEX QUERY 15-----------------------------------*/
create view gold as select count(Class) as gold, booking_id from ticket where class = 'GLD' group by booking_id;
create view silver as select count(Class) as silver, booking_id from ticket where class = 'SLV' group by booking_id;
create view gold_silver as Select * from gold natural join silver;
drop view user_booking;
create view user_booking as select booking_id, user_id from booking;
create view gs_users as Select * from gold_silver natural join user_booking;
Select First_Name, Last_Name from Web_User where Web_User_ID IN (Select user_id from gs_users group by user_id having sum(gold) > sum(silver));
drop view gs_users;
drop view gold_silver;
drop view gold;
drop view silver;


/*--------------------COMPLEX QUERY 16-----------------------------------*/
drop view total;
create view total as select (no_of_seats_gold + no_of_seats_silver) as total_seats, show_id 
from screen, show where show.screen_id = screen.screen_id;
drop view booked;
create view booked as select (seats_remaining_gold + seats_remaining_silver) as total_remaining, show_id from show;
select * from total natural join booked where total_remaining < 0.1 * total_seats;

/*--------------------COMPLEX QUERY 17-----------------------------------*/
drop view total;
create view total as select (no_of_seats_gold + no_of_seats_silver) as total_seats, show_id 
from screen, show where show.screen_id = screen.screen_id;
drop view booked;
create view booked as select (seats_remaining_gold + seats_remaining_silver) as total_remaining, show_id from show;
select * from total natural join booked where total_remaining > 0.3 * total_seats;

/*--------------------COMPLEX QUERY 18-----------------------------------*/
select language,count(b.booking_id)  
from movie m,booking b,show s
where b.show_id=s.show_id group by language;

/*--------------------COMPLEX QUERY 19-----------------------------------*/
Select First_Name, Last_Name from Web_User 
where Web_User_ID IN 
	(Select distinct User_ID from Booking where No_of_Tickets > 10);

/*--------------------COMPLEX QUERY 20-----------------------------------*/
Select First_Name, Last_Name from Web_User 
where Web_User_ID IN 
	(Select distinct User_ID from Booking where No_of_Tickets = 1);



