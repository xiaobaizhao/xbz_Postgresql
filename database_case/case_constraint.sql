--=create datebaes test;
--\c test
--创建数据表demo
create table demo(
  id int primary key,
  name char(50),
  age int
);
insert into demo values (1,'database',18);
insert into demo values (2,'table',12);
--测试主键约束
insert into demo values (1,'drop database',20);  --报错提示：违反唯一约束，键值id=1 已经存在

insert into demo values (3,'drop database');
--在数据表中新增address字段，字段类型为：text
alter table demo add address text;

--测试当address字段存在数据时，此时删除字段效果
insert into demo values (4,'alter table',33,'alter table tabName add columName datatype');
alter table demo drop column address;
--结论：当address字段存在数据时，可以直接删除，此时字段中的数据直接删除。(有外键依赖情况除外)


select * from demo;
--在数据表demo中新增address字段
alter table demo add address text;
alter table demo add sex char(50);
--删除shujubiaodemo中的address,sex 两个字段 (一条删除语句无法同时删除两个字段)
alter table demo drop column address;
alter table demo drop column sex;
-- 修改address字段text数据类型为char(100)
alter table demo alter column address type char(100);


--测试默认约束的使用
drop table demo;
create table demo(
  id int primary key,
  name varchar(20) not null,
  sex varchar(20) default '男',
  address varchar(200)
);
alter table demo alter column address set default 'tt';
alter table demo alter column address set default 'yld';
alter table demo alter column address drop default;

--测试唯一约束的使用
drop table demo;
create table demo(
  id int primary key,
  name varchar(50) not null,
  address text,
  age int not null,
  gender  char(20),
  tel int not null unique,
  unique(age,gender)
);
alter table demo add constraint demo_name unique (name);
alter table demo drop constraint demo_name;

-- 测试主键约束的使用
drop table demo;
create table demo(
  id int primary key
);
drop table demo;
create table demo(
  name varchar(50),
  age int,
  primary key (name,age)
);
drop table demo;
create table demo(
  id int
);
alter table demo add constraint demo_id_PK primary key(id);
alter table demo drop constraint demo_pkey;

-- 测试检查约束的使用
drop table demo;
create table demo(
  id int primary key,
  name varchar(50) not null,
  age int not null,
  gender char(10) not null check(gender='男' or gender='女'),
  salary int not null check(salary>0)
);
alter table demo add constraint demo_age_CK check(age>0 and age<=100);
alter table demo drop constraint demo_age_CK;

--测试外键约束
drop table company;
drop table department;
create table company(
  id int primary key,
  name varchar(20) not null,
  age int not null,
  address char(50),
  salary real
);
create table department(
  id int primary key,
  dept char(50) not null,
  EMP_ID int references company(id)
);
alter table department drop constraint department_emp_id_fkey;
alter table department add constraint  department_emp_id_FK foreign key (EMP_ID) references company(id);
