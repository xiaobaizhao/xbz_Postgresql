# postgreSQL高级学习
## postgreSQL 约束

## postgreSQL 约束的概念
**什么是约束**
- 约束确保了数据库中数据的准确性和可靠性，用于确保数据的完整性
- 约束是用于规定数据表中的数据规则，如果存在违反约束的数据行为，行为会被约束终止
- 约束可以在创建数据表(create table)时规定，或者在表创建后规定(alter table)
- 约束分为两类：**行级约束** _直接在字段中添加约束_、**表级约束** _在表后添加约束_,多个列共用的约束放于表后

**PostgreSQL 约束的类型概述**
- **默认约束 default** ：没有赋值的字段默认填充null,可以通过默认约束修改默认填充值
- **非空约束 not null** ：指定某字段不能存储null值
- **唯一约束 unique** ：确保某列的值都是唯一的
- **主键约束 primary key** ：not null 和 unique的结合。确保某列或多个列的组合有唯一标识，有助于快速找到数据表中的指定数据
- **检查约束 check** ：保证列中的值符合指定的条件
- **外键约束 poreign key** ：保证一个数据表中的数据匹配另一个数据表中的值的参照完整性
- **排他约束 exclusion** ：保证如果将任何两行的指定列或表达式使用指定操作符号进行比较，至少其中一个操作符比较将会返回false或空值

<font color=red>排他约束 在其他关系型数据库中并未见到，待学习</font>

## 约束的使用与案例
### 默认约束 (default)
- 在插入数据时，如果对应字段没有赋值，并且没有相关约束时，该字段默认填充null，此时我们可以理解为每个字段使用了默认约束，且默认约束的默认值为空值
- 有些字段虽然可以不用赋值，但因为业务需要，要对默认值做特殊定制化，此时就需要修改默认约束的默认值，来实现当该字段没有赋值时，使用指定的默认值

**默认约束语法**
1. 增加默认约束
```
--创建表时添加默认约束     
CREATE TABLE tablename(
    columname datatype DEFAULT 'defaultValue'
);
--创建表后添加默认约束
ALTER TABLE tablename ALTER COLUMN columname SET DEFAULT 'defalutValue';
```
2. 修改默认约束的值
```
ALTER TABLE tablename ALTER COLUMN columname SET DEFAULT 'defaultValue2';
```
3. 删除默认约束
```
ALTER TABLE tablename ALTER COLUMN columname DEOP DEFAULT; 
```
> 参数说明：  
- tablename : 数据表名称
- columname : 数据字段名称
- datatype :  数据字段的数据类型
- defaultValue：默认约束所使用的默认值  

实例：创建数据表demo，给sex字段增加默认约束，默认值为"男"。数据表创建完毕后，给address添加默认约束，初始默认值为"tt"，然后修改默认值为"yld",最后将address的默认约束删除。
```
create table demo(
  id int primary key,
  name varchar(20) not null,
  sex varchar(20) default '男',
  address varchar(200)
); 
 
alter table demo alter column address set default 'tt';
alter table demo alter column address set default 'yld';
alter table demo alter column address drop default;
```

### 非空约束 (not null)
- 默认情况下，字段可以保存为null值。如果在数据表中不希望某字段有null值，可以使用此约束。
- <font color=red>null 与没有数据是不一样的，null表示未知的数据</font>  
  
**非空约束语法**
1. 增加非空约束
```
--创建表时添加非空约束     
CREATE TABLE tablename(
    columname datatype not null,
    columname2 datatype not null default 'defaultValue'
);
--创建表后添加非空约束
ALTER TABLE tablename ALTER COLUMN columname SET NOT NULL;
```
<font color=red>注意：字段添加非空约束前，必须先把该字段值为null的处理掉。否则非空约束添加失败。</font>
2. 删除非空约束
```
ALTER TABLE tablename ALTER COLUMN columname DROP NOT NULL;
```

实例： 创建名为company的数据表，id,name,age三个字段不接受空值。其中id为主键、name为创建数据表时添加约束、age为数据表创建后新增约束。
```
create table company(
  id int primary key,
  name text not null,
  age  int,
  address  char(50),
  salary  real
);
ALTER TABLE company ALTER COLUMN age SET not null; --添加非空约束前，必须把该字段已有数据中的null处理掉。 
```
上述案例中，已经设置id、name、age三个字段的非空约束(not null),其中id 直接使用主键约束来实现非空，此时如果插入一条数据，如果id、name、age有任意一个字段不给数据值，则此条插入语句失败。  
```
insert into company values (1,'alter',12,'null');
insert into company values (2,'table',25);  
insert into company values (3,'非空约束');  --下述语句，因为第三个字段age没有给数值，所以会触发非空约束
insert into company values (4,'null',12);  --下述语句，因为第二个字段name直接给了null当做数值，此时不会触发非空约束
 
test001=# select * from company;    

 id | name  | age | address  | salary 
----+-------+-----+----------+--------
  1 | alter |  12 | null                                               |       
  2 | table |  25 |                                                    |       
  4 | null  |  12 |                                                    |       
(3 行记录)
```

### 唯一约束 (unique)
**唯一约束语法**
- 用于设置某一字段或几个字段不能有重复的值，多个字段组合的唯一约束字段之间是& 的关系
- 如果唯一约束要约束几个字段，那么唯一约束要作为表级约束来使用
1. 增加唯一约束
```
--创建表时增加唯一约束
CREATE TABLE tablename(
  columname1 datatype UNIQUE,
  columname2 datatype,
  columname3 datatype,
  columname4 datatype,
  UNIQUE(columname2,columname3)
);
--创建表后增加唯一约束
ALTER TABLE tablename ADD CONSTRAINT Tname_Cname_unkey UNIQUE (columname4);
```
2. 删除唯一约束
```
ALTER TABLE tablename DROP CONSTRAINT Tname_Cname_unkey;
```
> 参数说明：
- tablename ：创建数据表的表名称
- columname* ：数据表中的字段名称
- datatype ：数据表中字段的数据类型
- Tname_Cname_unkey ：外键的索引名(删除外键其实就是依旧外键索引名称进行删除)

案例：创建数据表demo，其中给tel字段添加行级唯一约束，给age、gender添加组合唯一约束。并在表创建完毕后，单独给name字段添加唯一约束，并删除name字段的唯一约束。
```
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
 
test001=# \d demo
                     数据表 "public.demo"
  栏位   |         类型          | 校对规则 |  可空的  | 预设 
---------+-----------------------+----------+----------+------
 id      | integer               |          | not null | 
 name    | character varying(50) |          | not null | 
 address | text                  |          |          | 
 age     | integer               |          | not null | 
 gender  | character(20)         |          |          | 
 tel     | integer               |          | not null | 
索引：
    "demo_pkey" PRIMARY KEY, btree (id)
    "demo_age_gender_key" UNIQUE CONSTRAINT, btree (age, gender)
    "demo_name" UNIQUE CONSTRAINT, btree (name)
    "demo_tel_key" UNIQUE CONSTRAINT, btree (tel)

test001=# \d demo
                     数据表 "public.demo"
  栏位   |         类型          | 校对规则 |  可空的  | 预设 
---------+-----------------------+----------+----------+------
 id      | integer               |          | not null | 
 name    | character varying(50) |          | not null | 
 address | text                  |          |          | 
 age     | integer               |          | not null | 
 gender  | character(20)         |          |          | 
 tel     | integer               |          | not null | 
索引：
    "demo_pkey" PRIMARY KEY, btree (id)
    "demo_age_gender_key" UNIQUE CONSTRAINT, btree (age, gender)
    "demo_tel_key" UNIQUE CONSTRAINT, btree (tel)
```
**拓展：**  
组合约束： 及两个或两个字段以上进行唯一约束的组合，只有当两个或两个以上字段的每个字段值都相同时才会触发唯一约束。如：（'张三',12）与('张三',13)因为第二个字段值不唯一，所以不会触发唯一约束。

### 主键约束 (primary key)
**主键约束语法**
- 主键约束是数据表中每一条记录的唯一标识
- 主键是非空约束和唯一约束的组合，即对应字段不能为空且不能有两个记录重复的值
- 一个表只能有一个主键，它可以由一个或多个字段组成，当多个字段作为主键时，称为复合键。

1. 增加主键约束
```
--创建数据表时设置主键
CREATE TABLE tablename(
  column1 datatype PRIMARY KEY,
  column2 datatype
);
 
CREATE TABLES tablename(
  column1 datatype,
  column2 datatype,
  CONSTRAINT Tname_Cname_pkey PRIMARY KEY (column1,column2)
);
--创建数据表后设置主键
ALTER TABLE tablename ADD CONSTRAINT Tname_Cname_pkey PRIMARY KEY (column1) 
```
2. 删除主键约束
```
ALTER TABLE tablename DROP CONSTRAINT Tname_Cname_pkey;
```
> 参数说明：
- tablename：创建数据表的表名称
- column* ：数据表中的字段名称
- datatype ：数据字段的数据类型
- Tname_Cname_pkey ：数据表中主键约束的约束名称

案例：创建数据表demo,分别使用创建表时，创建表后两种方式给id字段添加主键约束(demo_id_PK)，并将主键约束删除。并且重新创建demo表，将name、age两个字段设置为复合键(组合主键)
```
create table demo(
  id int primary key
);
drop table demo;
create table demo(
  id int
);
 
alter table demo add constraint demo_id_PK primary key(id);
alter table demo drop constraint demo_id_PK;
 
drop table demo;
create table demo(
  name varchar(50),
  age int,
  primary key (name,age)
);
```

### 检查约束 (check)
**检查约束语法**
- 用于保证字段中的数据值满足某一条件
- 用于对输入的一条数据进行检查，如果条件为false,则违反了余数，且不能输入到数据表中

1. 增加检查约束
```
--创建数据表时添加检查约束
CREATE TABLE tablename(
  column1 datatype CHECK(condition),
  colume2 datatype,
  column3 datatype,
  column4 datatype,
  CHECK(condition)
);
--创建数据表后添加检查约束
ALTER TABLE tablename ADD CONSTRAINT Tname_Cname_CK CHECK(condition);
```
2. 删除检查约束
```
ALTER TABLE tablename DROP CONSTRAINT Tname_Cname_CK;
```
> 参数说明：
- tablename：创建数据表的表名称
- colume* : 数据表中字段的名称
- datatype : 字段的数据类型
- value* : 检查约束的检查条件
- Tname_Cname_CK ：检查约束的约束名称  
- condition：检查约束的约束条件，如(gerder='男' or gerder='女')或（salary>0）等


案例：创建数据表demo,给gender字段添加检查约束，检查此字段值只能为'男'或'女'，同时判断salary字段大于0。在数据表创建完毕后，给age字段添加检查约束，检查age字段值范围在（0,100]之间。并删除age字段的约束。
```
create table demo(
  id int primary key,
  name varchar(50) not null,
  age int not null,
  gender char(10) not null check(gender='男' or gender='女'),
  salary int not null check(salary>0)
);
alter table demo add constraint demo_age_CK check(age>0 and age<=100);
alter table demo drop constraint demo_age_CK;
```

### 外键约束 (foreign key)
**外键约束语法**
- 指定某个字段或一组字段中的值必须匹配另一个表的某一行中出现的值
- 通常一个表的foreign key 指向另一个表中的unique key ，用于维护两个相关表之间的引用完整性

1. 增加外键约束
```
--创建数据表时添加外键约束
CREATE TABLE tablename1(
  column1 datatype primary key,
  column2 datatype,
);
CREATE TABLE tablename2(
  column3 datatype REFERENCES tablename1(column2)
);
 
--创建数据表后添加外键约束（无可选项）
ALTER TABLE tablename ADD CONSTRAINT Tname_Cname_FK FOREIGN KEY (column3) REFERENCES tablename1(column2);
 
--创建数据表后添加外键约束 (有可选项)
ALTER TABLE tablename ADD CONSTRAINT Tname_Cname_FK FOREIGN KEY (column3) REFERENCES tablename1(column2) [ON Optional];
```
2. 删除外键约束
```
ALTER TABLE tablename DROP CONSTRAINT Tname_Cname_FK;
``` 
> 参数说明：
- tablename1：创建数据表的表名称(被外键引用表，也称为父表)
- tablenmae2：创建数据表的表名称(外键引用表)
- column* : 数据表中字段名称
- datatype：字段的数据类型
- Tname_Cname_FK：外键约束的约束名称
- [ON Optional] ：这是是关联的关键。具体介绍如下
> **Optional可选项说明：**
- no action：更新或删除父表中的数据时，如果会使子表中的外键违反引用完整性，该动作将被禁止执行
- cascade：当父表中被引用列的数据被更新或删除时，子表中的相应的数据也被更新或删除
- set null：当父表数据被更新或删除时，子表总的相应数据被设置为null值，前提是子表中对应字段允许null值
- set default：当父表数据被更新或删除时，子表中的数据被设置成默认值。前提是子表中对应字段设置有默认值
- on update cascade: 被引用行更新时，引用行自动更新
- on update restrict：被引用行禁止更新
- on delete cascade：被引用行删除时，引用行也一起删除
- on delete restrict：被引用的行禁止删除

案例：创建被引用父表company,创建引用子表department，设置子表EMP_ID 关联父表id字段。创建表完毕后，将外键约束删除，并重新添加相同外键约束，约束名为：department_emp_id_FK
```
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
```

### 排他约束 (exclusion)
<font color=yellow>#### 待测试与补全：https://www.runoob.com/postgresql/postgresql-constraints.html</font>

**排他约束语法**
1. 增加排他约束
```

```
2. 删除排他约束
```

```

案例：


**参考链接：**  
https://www.jianshu.com/p/c2b1d5394214  postgreSQL外键约束详解

<font color=gray>文档内容仅用于学习使用。如有侵权，请及时联系QQ群：647934871</font>