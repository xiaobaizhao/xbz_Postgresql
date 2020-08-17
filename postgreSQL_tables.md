# postgreSQL基础学习
## 数据表的操作及模拟案例
基础玩法：
- postgresql **创建数据表**
- postgresql **删除数据表**  

高级玩法：  
**postgresql ALTER TABLE 命令**
- postgresql **增加数据表字段**
- postgersql **删除数据表字段**
- postgresql **变更数据表字段的数据类型**
- postgresql [**数据表字段的约束**][2]

## 创建表格 (create table)
**create table SQL语法**
```
CREATE TABLE table_name(
    column1 datatype,
    column2 datatype,
    colume3 datatype
    ....
);
```
> 参数说明：
> - table_name：要创建的数据表名称
> - column：要创建的字段名称
> - datatype：创建字段所对应的[数据类型][1]  

案例：创建一个数据表，表名company 主键为ID 字段可以自定义即可
```
create table company(
  id int primary key not null,
  name text not null,
  age int not null,
  address char(50),
  salary real
)
```
**快捷键拓展**
- \d： 用于查看当前数据库中有哪些数据表
- \d tablename：用于查看当前数据库中指定数据表的表结构信息

## 删除表格 (drop table)
**drop table SQL语法**
> DROP TABLE tablename1,tablename2;
>> 参数说明：  
- tablename：要删除的数据表名称，多个表之间用英文逗号隔开

案例：将创建的数据表company 删除
```
drop table company
```
## 增加数据表字段
**增加表字段语法**
> ALTER TABLE tablename ADD columname datatype;
>> 参数说明：  
- tablename: 要添加字段的数据表名称
- columnane: 要添加的字段名称
- datatype: 要添加字段的数据类型

<font color=red>注意：在增加数据表字段时，也可以添加行级约束条件。添加约束条件时，如果已有数据不满足约束，则字段添加会因约束而报错并且天字段添加失败。</font>
如：数据表demo中添加address字段，数据类型为text，添加tel 字段，数据类型为int。
```
alter table demo add address text;
alter table demo add tel int;
```
<font color=green>思考：   
1、一条alter table...add...语句如何添加多个字段  
2、 在添加tel字段时，如何实现同时添加非空约束
</font>

## 删除数据表字段
**删除表字段语法**
> ALTER TABLE tablename DROP COLUMN columname;
>> 参数说明：
- tablename: 要删除字段的数据表名称
- columname：要删除字段的名称

如：数据表demo中删除address字段
```
alter table demo drop column address;
```
<font color=green>思考：  
1、一条alter table...drop column...语句如何删除多个字段
2、如果address字段存在约束(如外键约束)时，如何删除字段
</font>

## 变更数据表字段的数据类型
**变更数据表字段类型语法**
> ALTER TABLE tablename ALTER COLUMN columname TYPE datatype;
>> 参数说明：  
- tablename: 要修改字段的数据类型的数据表名称
- columname: 要修改数据类型的字段名称
- datatype: 要修改数据类型的字段的新数据类型

如：把数据表demo中tel字段的数据字段类型从int修改为char(20)
```
alter table demo alter column tel type char(20);
```
<font color=green>思考：  
1、如果数据表中已有数据，此时如何使字段修改数据类型生效
</font>

## 数据表字段的约束
详见postgreSQL [约束][2]


**参考链接**

<font color=gray>文档内容仅用于学习使用。如有侵权，请及时联系QQ群：647934871</font>





[1]: http://数据类型文档待补全 "数据类型" 
[2]: https://github.com/xiaobaizhao/xbz_Postgresql/blob/master/postgreSQL_constraint.md "数据表约束"