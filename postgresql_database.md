# postgreSQL基础学习
## 数据库的操作及模拟案例
- postgreSQL  **创建数据库**
- postgreSQL  **选择数据库**
- postgreSQL  **删除数据库**
- postgreSQL  **[模拟案例](E:\Python\xbz_Postgresql\database_case\create_database.sql)**

## 创建数据库(create database)
postgreSQL 创建数据库有三种方式，分别为：
> 1. 使用 **create database** SQL语句来创建  
> 2. 使用 **createdb** 命令来创建
> 3. 使用 **pgAdmin** 等第三方工具
   
因精力有限，目前只研究**create database**、**createdb**两种方式创建数据库。 
### create database SQL语句创建数据库：
**create database SQL语法：**
> CREATE DATABASE dbname;  
>> 参数说明：  
dbname：要创建的数据库名称  
  
如：在SQL脚本或psql中，在postgres用户下创建名为test001的数据库
```
postgres=# CREATE DATABASE test001;
```
### createdb 命令创建数据库：
- createdb是一个SQL命令CREATE DATABASE的封装。
在不使用psql进入数据库的情况下，通过调用$HOME/pgsql-12/bin下的createdb命令，可以直接创建数据库。
**createdb 命令语法：**
> CREATEDB  [option...] [dbname[description]]
>>参数说明：  
dbname：要创建的数据库名称  
description：关于新创建的数据库相关的说明  
options：参数可选项，参数说明如下：  

     -D tablespace ：指定数据库默认表空间
     -e            : 将createdb生成的命令发送到服务端
     -E encoding   : 指定数据库的编码
     -l locale     : 指定数据库的语言环境
     -T template   : 指定创建此数据库的模板
     --help        : 显示createdb命令的帮助信息
     -h host       : 指定服务器的主机名
     -p port       : 指定服务器监听的端口，或socket文件
     -U username   : 连接数据库的用户名
     -w            : 忽略输入密码
     -W            ：连接时强制输入密码
如： 在linux命令模式下，在postgres用户下使用createdb命令创建一个名为test002的数据库，其中主机地址为localhost，端口号为5432，并且强制认证密码。
```
-bash-4.2$ cd /usr/pgsql-12/bin/
-bash-4.2$ ./createdb -h localhost -p 5432 -W -U postgres test002
口令: 
-bash-4.2$ psql -U postgres
psql (12.3)
输入 "help" 来获取帮助信息.
postgres=# \l
                                  数据库列表
   名称    |  拥有者  | 字元编码 |  校对规则   |    Ctype    |       存取权限        
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | 
 template0 | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 test002   | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | 
(4 行记录)
```
## 选择数据库
postgreSQL 进入数据库有三种方式，分别为：
> 1. 在数据库的命令窗口下进入数据库 
> 2. 在系统命令行默认进入数据库
> 3. 使用 **pgAdmin** 等第三方工具进入数据库  

同样，目前只研究**create database**、**createdb**两种方式创建数据库。
### 数据库命令窗口方式：
>1. 使用 **\l** 命令，查询已经存在的数据库信息  
```
postgres=# \l
                                     数据库列表
   名称    |  拥有者  | 字元编码 |  校对规则   |    Ctype    |       存取权限        
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | 
 template0 | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 test      | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | 
 test001   | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | 
 test002   | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | 
(6 行记录)
```
>2. 使用 **\c dbname** 命令，进入到指定的数据库，如进入test001数据库
```
postgres=# \c test001
您现在已经连接到数据库 "test001",用户 "postgres".
test001=# 
```
<font color=red>注意：此时可以看到，数据库已经从postgrest切换到了test001。</font>
数据库从test001切换回postgres 执行如下命令：
```
test001=# \c postgres
您现在已经连接到数据库 "postgres",用户 "postgres".
postgres=#
```
拓展： 想要退出数据库模式，执行 **\q** 即可退出数据库模式。
### 系统命令行方式：
> 直接在当前系统用户下，执行 **psql** 命令即可  

如: 在超级系统账户root下，进入端口为5432，数据地址为localhost，数据用户为postgres的test001数据库。
```
[root@localhost ~]# psql -h localhost -p 5432 -U postgres test001
psql (12.3)
输入 "help" 来获取帮助信息.
test001=# 
```
## 删除数据库
postgreSQL 删除数据库有三种方式，分别为：
> 1. 使用 **drop database** SQL语句来删除  
> 2. 使用 **dropdb** 命令来删除  
> 3. 使用 **pgAdmin** 等第三方工具    
 
<font color=red>注意：删除数据库要谨慎操作，一旦删除，所有信息都会消失。</font>  
目前只研究**create database**、**createdb**两种方式创建数据库。 
### drop database SQL语句删除数据库：
- DROP DATABASE 会删除数据库的系统目录项并且删除包含数据的文件目录;
- DROP DATABASE 只能由超级管理员或数据库拥有者来执行;
- DROP DATABASE 命令需要在PostgreSQL 命令窗口来执行;
**drop database SQL语法：**
> drop database [IF EXISTS] dbname
>> 参数说明：  
IF EXISTS ：如果数据库不存在则发出提示信息，而不是错误信息
dbname ：要删除的数据库名称

如: 在SQL脚本或psql中，使用postgres用户删除该用户名下的test002数据库
```
-bash-4.2$ psql -U postgres
psql (12.3)
输入 "help" 来获取帮助信息.

postgres=# \l
                                     数据库列表
   名称    |  拥有者  | 字元编码 |  校对规则   |    Ctype    |       存取权限        
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | 
 template0 | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 test001   | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | 
 test002   | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | 
(5 行记录)

postgres=# drop database test002;
DROP DATABASE
postgres=# \l
                                     数据库列表
   名称    |  拥有者  | 字元编码 |  校对规则   |    Ctype    |       存取权限        
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | 
 template0 | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 test001   | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | 
(4 行记录)
```
### dropdb  命令删除数据库

- dropdb 是一个SQL命令DROP DATABASE的封装。
- dropdb 用于删除PostgreSQL数据库
- dropdb 命令只能由超级管理员或数据库拥有者执行

在不使用psql进入数据库的情况下，通过调用$HOME/pgsql-12/bin下的dropdb命令，可以删除数据库。
**createdb 命令语法：**
> dropdb  [connection-option...] [option...] dbname
>>参数说明：  
dbname：要删除的数据库名称   
options：参数可选项，参数说明如下：  

    -e : 显示dropdb生成的命令并发送
    -i : 在做删除的工作之前发出一个验证提示
    -V ：打印dropdb 版本并退出
    --if-exists : 如果数据库不存在则发出提示信息，而不是错误信息
    --help : 显示有关dropdb命令的帮助信息
    -h host : 指定运行服务器的主机名称
    -p port : 指定服务器监听的端口，或者socket文件
    -U username : 连接数据库的用户名
    -w : 连接数据库的用户名
    -W ：连接时强制要求输入密码
    --maintenance-db=dbname ：删除数据库时指定连接的数据库，默认为postgres,如果它不存在则使用template1
如：在linux命令模式下，在postgres用户下使用dropdb命令删除名为test001的数据库，其中主机地址为localhost，端口号为5432。
```
postgres=# \l
                                     数据库列表
   名称    |  拥有者  | 字元编码 |  校对规则   |    Ctype    |       存取权限        
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | 
 template0 | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 test      | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | 
 test001   | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | 
(5 行记录)

postgres=# \q
[root@localhost bin]# ./dropdb -h localhost -p 5432 -U postgres test001
[root@localhost bin]# psql -h localhost -p 5432 -U postgres 
psql (12.3)
输入 "help" 来获取帮助信息.

postgres=# \l
                                     数据库列表
   名称    |  拥有者  | 字元编码 |  校对规则   |    Ctype    |       存取权限        
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | 
 template0 | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 test      | postgres | UTF8     | zh_CN.UTF-8 | zh_CN.UTF-8 | 
(4 行记录)  
```

**参考链接：**  
https://www.runoob.com/postgresql/postgresql-drop-database.html
<font color=>文档内容仅用于学习使用。如有侵权，请及时联系QQ群：647934871</font>