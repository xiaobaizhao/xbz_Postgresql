# postgreSQL基础学习
## postgreSQL 数据
[数据操作案例][1]
基础玩法：
- 查询数据
- 插入数据
- 修改数据
- 删除数据  

中级玩法：
- where 按条件查询
- limit 指定查询的数据的数量
- like  模糊匹配
- order by  数据按字段进行排序
- group by  数据分组
- having  筛选分组后的数据
- distinct  去重
- with <font color=yellow>待确认使用方式</font>

高级玩法：
- 运算符详解
- 表达式的使用
- join 语法的使用
- union 语法的使用
- 子查询
- 常用函数

<font color=red>本篇仅对基础玩法、中级玩法做描述。高级玩法单独讲解</font>

### 查询语句（select）
- 查询语句用于从数据库中选取数据
- 选取结果被存储在一个结果表中，称为结果集
- 使用 * 用于读取该表的所有字段  
- 常使用 **where 子句**,对数据表中的数据进行过滤

**select 语法** 
```
SELECT column1,column2,...,columnN FROM tablename;
```
>参数说明：
- column*：要查询数据的字段名称
- tablename：要查询数据的数据表名称

案例：查询demo数据表中的数据
```
-- 查询demo表中的所有字段的所有数据
select * from demo;
-- 查询demo表中id,name两个字段的所有数据
select id,name from demo;
-- 查询demo表中salary字段大于10000的所有数据
select * from demo where salary > 10000;
```

### 插入语句（insert into）
- insert插入数据时，要遵守数据表已存在的相关约束
- insert插入数据时，字段和数据值的数量要一一对应，并且顺序也要一一对应  
-- 可以插入一行数据，也可以同时插入多行数据

**insert into 语法** 
```
INSERT INTO tablename (column1,column2,...,columnN)VALUES (value1,value2,...,valueN); 
```
>参数说明：
- tablename ： 要插入数据的数据表名称
- column* ：要插入数据的字段名称
- value* ：要插入的数据值，数据值与字段一一对应

案例：在demo表中插入一行标准数据值。
```
test001-# \d demo
                  数据表 "public.demo"
   栏位    |     类型      | 校对规则 |  可空的  | 预设 
-----------+---------------+----------+----------+------
 id        | integer       |          | not null | 
 name      | character(50) |          | not null | 
 age       | integer       |          | not null | 
 address   | text          |          |          | 
 salary    | real          |          |          | 
 join_date | date          |          |          | 
索引：
    "demo_pkey" PRIMARY KEY, btree (id)
 
insert into demo (id,name,age,address,salary,join_date) values(3,'update',24,'postgreSQL',12000,'2020-08-17');
```

### 修改语句（update ）
**update 语法** 
```
UPDATE tablename SET column1=new_value1,column2=new_value2 where [condition];
```
>参数说明：
- tablename：要修改数据值所在的数据表名称
- column* ：要修改数据值对应的字段名称
- new_value* : 修改后的数据值内容
- condition ：通过指定条件来筛选要修改数据值的数据集

案例：
```
-- 修改单行数据的address字段值为postgreSQL
update demo set address='postgreSQL' where name='delete';
-- 修改单行数据的age、salary两个字段
update demo set age=22,salary=7500 where name='insert';
```
### 删除语句（delete）
**delete语法** 
```
DELETE FROM tablename WHERE [condition];
```
>参数说明：
- tablename：要删除的数据所在数据表名称
- condition：要删除数据的筛选条件，以便找出要删除的数据  
<font color=red>注意：</font> 如果不指定WHERE子句，数据表中的所有记录数据将被删除

案例：
```
insert into demo values(12,'mysql',324,'mysql',9090,'20200818');
 
delete from demo where address='mysql';
```

### 条件(where)
- where 用于根据指定条件从单张或多张表中查询数据，从而过滤掉不需要的数据  

常见的几种用法：  

**以select语句中使用为案例**  
```
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
```
### 限制行数(limit)
- limit 子句用于限制SELECT语句中查询的数据的数量
**limit 语法**
```
-- limit子句
SELECT column1,column2,...,columnN FROM tablename LIMIT num;
-- limit子句与offset子句
SELECT column1,column2,...,columnN FROM tablename LIMIT num OFFSET num;
```
>参数说明：
- column* : 要查询数据的字段名称
- tablename： 要查询数据的数据表名称
- num：   
  在LIMIT num中代表要查询几行数据，如LIMIT 4 代表查询前四行数据     
  在 OFFSET num中代表要查询数据的起始行数，如 OFFSET 3 代表跳过前三行数据，从第四行数据开始
 
案例:
```
select * from demo;
 
select * from demo limit 4;
 
select * from demo limit 4 offset 2;
 
select * from demo where salary<15000 limit 4;
```
### 模糊匹配 (like)
- 如果需要对数据是否包含某些字符进行模糊匹配，可以使用like 子句
- 在数据库中要慎用like子句，因为模糊匹配在查询过程中消耗性能较大
- 在like 子句中，通常与通配符结合使用，通配符表示任意字符。常用通配符主要有：
>- 百分号 % ：用于匹配多个字符
>- 下划线 _ ：用于匹配单个字符

常见用法如下：
```
select * from demo where name like '%e%';
 
select * from demo where age like '2_';--因为age字段的数据类型不是字符型，所有报错，需要做数据类型转换
```

### 排序 (order by)
- 用于对一列或者多列数据进行排序。排序方式有两种，分别为：
>- 升序 ASC ：自上而下，从小往大
>- 降序 DESC ：自上而下，从大往小

常见用法：
```
select * from demo order by age ASC ; 
 
select * from demo order by age DESC ;
 
select * from demo order by age ASC,salary DESC;
 
select * from demo where address is not null order by age ASC,salary DESC;
```

### 分组 (group by)
- 与SELECT 语句一起使用，用来对相同的数据进行分组。
- group by 语句要放在where子句的后边，order by 语句的前面
- group by 子句中，可以对一列或多列进行分组，但是被分组的列必须存在与列清单中

常见用法：
```
select * from demo;
 
select name,sum(salary) from demo group by name;
 
select name,sum(salary) from demo group by name order by name ASC;
 
select name from demo group by name;
```

### having
- where 子句在所选列上设置条件，而having 子句则是在由group by 子句创建的分组上设置条件
- having 子句必须放置在group by 子句后面，order by子句前面

案例：
```
select * from demo;
 
update demo set salary=4500 where id=8;
 
select name,sum(salary) from demo group by name having sum(salary)>15000;
```
### 去重 (distinct)
- distinct 关键字与select 子句一起使用，用于去除重复记录，只获取唯一的记录
- distinct 关键字可以与一个或多个列进行组合，多个列同时去重时，列与列之间是或的关系 <font color=red>待测试验证</font>

**distinct 语法**
```
SELECT DISTINCT column1,colume2,...,columnN FROM tablename where [condition]
```
> 参数说明
- column1: 要去重的字段名称
- column* : 要查询的数据的字段名称
- tablename ： 要查询数据所在的数据表名称

案例：
```
select * from demo; 
 
select DISTINCT  name ,age ,id from demo;
 
select DISTINCT  name ,age ,id,salary from demo;
```

**参考链接**


<font color=gray>文档内容仅用于学习使用。如有侵权，请及时联系QQ群：647934871</font>


[1]: http://www.com.cn "数据操作案例"
