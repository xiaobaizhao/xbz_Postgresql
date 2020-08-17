create database test001;

drop table demo;
create table demo(
  id int primary key,
  name char(50) not null,
  age int not null,
  address text,
  salary real,
  join_date date
);

--标准insert写法
insert into demo (id,name,age,address,salary,join_date) values(3,'update',24,'postgreSQL',12000,'2020-08-17');
--简化写法（默认插入所有字段）
insert into demo values(1,'insert',12,'postgreSQL',8000,'2020-08-17');
insert into demo values(2,'select',32,'postgresSQL',10000,'2020-08-17');
--给指定字段插入数据
insert into demo (id,name,age,salary) values(4,'delete',23,14000);
--join_date使用default设置默认值
insert into demo (id,name,age,address,salary,join_date) values(5,'where',50,'postgreSQL',16000,DEFAULT);
--同时插入多行数据
insert into demo (id,name,age,address,salary,join_date) values(6,'view',12,'postgreSQL',18000,'20200-08-17'),(7,'index',13,'postgreSQL',6000,'2020-08-17');
--插入null或空格方式
insert into demo (id,name,age,address,salary,join_date) values(8,'transaction',25,NULL,4500,'2020-08-17');
insert into demo (id,name,age,address,salary,join_date) values(9,'transaction',25, ,4500,'2020-08-17'); --会报错
insert into demo (id,name,age,address,salary,join_date) values(10,'transaction',25,'',4500,'2020-08-17');
--改变字段插入顺序
insert into demo (name,id,address,age,join_date,salary) values('trigger',11,'postgreSQL',18,'2020-08-17',3000);

--select基本用法
select id from demo;
select * from demo;
select id,name from demo;
select * from demo where salary > 10000;
select * from demo where age in (select age from demo where salary>15000);

--update基本用法
update demo set join_date='2020-08-18';
update demo set address='postgreSQL' where name='delete';
update demo set age=22,salary=7500 where name='insert';

--delete基本用法
insert into demo values(12,'mysql',324,'mysql',9090,'20200818');
delete from demo where address='mysql';

--where用法
select * from demo where id=1;
select * from demo where salary>10000;
select id,name from demo where address='postgreSQL';
select * from demo where id>=3 and salary<20000;
select * from demo where age>30 or salary<15000;
select * from demo where address is not null;
select * from demo where name in ('select','update');
select * from demo where name not in ('select','update');
select * from demo where age between 20 and 40;
select * from demo where age in (select age from demo where salary>15000);

--limit用法
select * from demo;
select * from demo limit 4;
select * from demo limit 4 offset 2;
select * from demo where salary<15000 limit 4;

--like 用法
select * from demo where name like '%e%';
select * from demo where age like '2_';--因为age字段的数据类型不是字符型，所有报错，需要做数据类型转换

--order by 排序的用法
select * from demo order by age ASC ;
select * from demo order by age DESC ;
select * from demo order by age ASC,salary DESC;
select * from demo where address is not null order by age ASC,salary DESC;

--distinct 去重的用法
select * from demo;
select DISTINCT  name ,age ,id from demo;
select DISTINCT  name ,age ,id,salary from demo;