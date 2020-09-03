# postgreSQL 服务管理
## postgreSQL 主从配置及切换  
- 简介
- 主从环境简介
- 主从配置详解
- 主从切换及恢复

### 一、简介
本文主要记录了如何实现对数据库的主从同步。做主从同步的意义在于：
1. 能有效防止因单个数据服务器宕机，导致的数据丢失
2. 组从数据库能实现对数据库的访问压力的分流 (具体方案视实际情况进行判定)  

主从同步的实现有两种方式：
1. 基于文件的日志传输
2. 基于流复制

本文主要记录如何通过postgreSQL的流复制功能配置主从同步。 

**拓展：**   
PostgreSQL 在9.X之后引入了主从的流复制机制，所谓的流复制，就是备份服务器通过tcp流从主服务器中同步相应的数据，主服务器在WAL记录产生过时，即将它们以流式传送给备份服务器，而不必等到WAL文件被填充。
1. 默认情况下流复制是异步的，这种情况下主服务器上提交一个事务与该变化在备服务器上变得可见之间客观上存在短暂的延迟，但这种延迟相比基于文件的日志传送方式依旧要小的多，在备服务器的能力满足负载的前提下，延迟通常小于一秒;
2. 在流复制中，备服务器比使用基于文件的日志传送具有更小的数据丢失窗口，不需要采用archive_timeout来缩减数据丢失窗口

### 二、主从环境简介
- 主库IP：192.168.23.205
- 从库IP：192.168.23.206  

目录说明：  
- /home/postgres/data ： postgreSQL数据安装目录  

前置说明：
- 已完成postgreSQL的相关搭建工作，主从服务器均处于可用状态

### 三、主从配置详解  
#### 3.1. 主服务器  
**3.1.1. 创建数据用户**  
创建具有流复制操作权限的postgreSQL用户： replica (用户可自定义名称)
```
[root@localhost ~]# su - postgres
上一次登录：一 8月 31 17:05:06 CST 2020pts/1 上
-bash-4.2$ psql -U postgres
psql (12.4)
输入 "help" 来获取帮助信息.

postgres=# create role replica login replication encrypted password 'replicaPW';
postgres=# \q
```
**3.1.2. 修改配置文件：pg_hba.conf**  
在文件尾部添加信任的从服务器参数信息:  
**host  replication replica 192.168.23.206/32 md5**
```
-bash-4.2$ vi /home/postgres/data/pg_hba.conf  
 
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
host    all             all             0.0.0.0/0               md5
# IPv6 local connections:
host    all             all             ::1/128                 trust
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     trust
host    replication     all             127.0.0.1/32            trust
host    replication     all             ::1/128                 trust
# 新增从服务器信息
host    replication     replica         192.168.23.206/32       md5  
```
> 参数说明：
- 192..198.23.206：从节点的完成IP
- 32： 如果为网段配置则此处就不是32
- md5： 允许密码验证，可将md5变更为 trust (trust 为免密)

**3.1.3. 修改配置文件：postgresql.conf**  
修改postgresql.conf 配置文件，开启主从相关配置参数。参数具体描述请自行查看[官方文献][1]  
```
-bash-4.2$ mkdir /home/postgres/pg_archivedir  # 创建归档存放目录
```
- listen_addresses = '*'   # 监听所有IP
```
-bash-4.2$  vi /home/postgres/data/postgresql.confv
 
#listen_addresses = 'localhost'         # what IP address(es) to listen on;
listen_addresses = '*'
                                        # comma-separated list of addresses;
                                        # defaults to 'localhost'; use '*' for all
                                        # (change requires restart)
```
- max_connections = 100    # 最大连接数，从服务器要大于或等于该值
```
max_connections = 120                   # (change requires restart)
```
- archive_mode = on  # 开启归档
- archive_command = '....'  # 开启归档文件名及存放地址
```
#archive_mode = off             # enables archiving; off, on, or always
                                # (change requires restart)
archive_mode = on
#archive_command = ''           # command to use to archive a logfile segment
                                # placeholders: %p = path of file to archive
                                #               %f = file name only
                                # e.g. 'test ! -f /mnt/server/archivedir/%f && cp %p /mnt/server/archivedir/%f'
archive_command = 'test ! -f /home/postgres/pg_archivedir/%f && cp %p /home/postgres/pg_archivedir/%f'
```
- wal_level = replca  # WAL日志信息的输出级别，minimal、replica、logical三种模式
````
#wal_level = replica                    # minimal, replica, or logical
wal_level = replica
                                        # (change requires restart)
````
- wal_keep_segments = 16    # 越大越好，根据归档存储空间定，默认单个WAL文件大小为16M，这里为512×16MB=8GB
- wal_sender_timeout = 60s  # 流复制超时时间
```
#wal_keep_segments = 0          # in logfile segments; 0 disables
wal_keep_segments = 16
#wal_sender_timeout = 60s       # in milliseconds; 0 disables
wal_sender_timeout = 60s
```
**3.1.4. 重启服务**  
> **systemctl status postgresql-12**  # 查看服务启动状态  
> **systemctl restart postgresql-12**  # 重启postgresq服务  

**3.1.5. 在从节点上验证访问**
主要验证从服务器是否能访问到主服务，测试数据是否能正常流入。
```
[root@localhost ~]# su - postgres
上一次登录：二 9月  1 16:49:39 CST 2020pts/0 上
-bash-4.2$ psql -h 192.168.23.205 -U postgres
用户 postgres 的口令：
psql (12.4)
输入 "help" 来获取帮助信息.
postgres=#  
```
当能登录到主服务postgreSQL数据页面时，代表主、从服务之间数据可以正常传输。
   
<font color=red>注意： 如果不知道postgreSQL用户密码时，请联系管理官重置账户密码信息。</font>
**修改postgres用户密码命令:**  
> ALTER USER postgres WITH PASSWORD 'postgresPW';  

#### 3.2. 备服务器
**3.2.1. 停止postgresql服务**
```
[root@localhost ~]# su - postgres   # 切换到postgres用户进行相关操作
上一次登录：一 8月 31 17:27:01 CST 2020pts/1 上
 
-bash-4.2$ systemctl stop postgresql-12  # 停止postgresql服务命令
```  
**3.2.2. 清除数据文件夹**
```
-bash-4.2$ cp -r /home/postgres/data /home/postgres/data_int2 # 可以先将数据目录备份，防止因操作失误导致数据服务无法还原
-bash-4.2$ cd  /home/postgres/data
-bash-4.2$ rm -rf *  # 注意谨慎使用rm -rf *
```
**3.2.3. 从节点获取数据**
为了实现主从同步，首先要使用在主服务器PG中创建的replica用户，从主节点获取备份数据
```
-bash-4.2$ pwd
/home/postgres/data 
 
-bash-4.2$ pg_basebackup -h 192.168.23.205 -p 5432 -U replica -Fp -Xs -Pv -R -D /home/postgres/data
```
> 参数说明：  
>> -h：指定连接的数据库的主机名或IP地址，这里就是主库的ip
>> -U：指定连接的用户名，此处是我们刚才创建的专门负责流复制的repl用户
>> -F：指定了输出的格式，支持p（原样输出）或者t（tar格式输出）
>> -x：表示备份开始后，启动另一个流复制连接从主库接收WAL日志
>> -P：表示允许在备份过程中实时的打印备份的进度
>> -R：表示会在备份结束后自动生成recovery.conf文件，这样也就避免了手动创建
>> -D：指定把备份写到哪个目录
>> -l：表示指定一个备份的标识，运行命令后看到如下进度提示就说明生成基础备份成功
<font color=red> 获取备份相关参数及实现原理详见[官方文献][1]</font>

**3.2.4. 编辑standby.signal 文件**
此文件是PG-12的标志文件，默认为空白文件，具体用途未探索。新增内容为：  
**standby_mode = 'on'**
```
-bash-4.2$ vi /home/postgres/data/standby.signal 
 
standby_mode = 'on'
```
拓展：当从节点提升为主节点后，此文件会自动删除  
 
**3.2.5. 修改postgresql.conf 文件**
```
-bash-4.2$ vi /home/postgres/data/postgresql.conf
```
- primary_connifo = '....' # 用于与主服务进行连接
```
#primary_conninfo = ''                  # connection string to sending server
                                        # (change requires restart)
primary_conninfo = 'host=192.168.23.205 port=5432 user=replica password=replicaPW'
```

>参数说明：  
>- host : 填写主服务器ip地址
>- port : 填写主服务器通信端口，默认为5432
>- user ：填写主服务器开通了流复制权限的PG用户，案例为replica
>-  password：填写replica用户的密码，案例为 replicaPW。  
(密码验证，是因为开启在主服务器的pg_hba.conf文件添加信任从服务器信息时，使用了md5密码验证机制)

- recovery_target_timeline = latest # 默认参数，说明恢复到最新状态
```
#recovery_target_timeline = 'latest'    # 'current', 'latest', or timeline ID
                                        # (change requires restart)
recovery_target_timeline = latest
```
- max_connections = 120   # 大于等于主节点，正式环境应当重新考虑此值的大小
```
max_connections = 120                   # (change requires restart)
``` 
- hot_standby = on  # 开启归档
- max_standby_streaming_delay # 设置流复制的最大延迟时间
- wal_receiver_status_interval # 向主机汇报本机状态的间隔时间
- hot_standby_feedback # 出现错误复制，想主机反馈
```
#hot_standby = on                       # "off" disallows queries during recovery
                                        # (change requires restart)
hot_standby = on
#max_standby_archive_delay = 30s        # max delay before canceling queries
                                        # when reading WAL from archive;
                                        # -1 allows indefinite delay
#max_standby_streaming_delay = 30s      # max delay before canceling queries
                                        # when reading streaming WAL;
                                        # -1 allows indefinite delay
max_standby_streaming_delay = 30s
#wal_receiver_status_interval = 10s     # send replies at least this often
                                        # 0 disables
wal_receiver_status_interval = 10s
#hot_standby_feedback = off             # send info from standby to prevent
                                        # query conflicts
hot_standby_feedback = on
```
<font color=red>注意： postgresql.conf 配置文件中的所有配置项仅做参考，具体配置建议根据实际场景，在了解每个配置含义后自行调整。</font>

**3.2.6. 重启从节点**
```
[root@localhost ~]# su - postgres   # 切换到postgres用户进行相关操作
上一次登录：一 8月 31 17:27:01 CST 2020pts/1 上
 
-bash-4.2$ systemctl restart postgresql-12  # 停止postgresql服务命令
```
#### 3.3. 验证
有多种方式可以验证，具体操作如下：
- **方式一： psql 数据查询语句方式**  
登录主节点数据库执行如下查询命令：
```
-bash-4.2$ psql -U postgres
psql (12.4)
输入 "help" 来获取帮助信息.

postgres=# select client_addr,sync_state from pg_stat_replication;
  client_addr   | sync_state 
----------------+------------
 192.168.23.206 | async
(1 行记录)
```
根据上述信息可以看出，192.168.23.206 服务器是从节点，而且是异步流复制。  
拓展：流复制有同步流复制、异步流复制两种方式，但同步流复制虽然能很好地保护数据，但同时也带来了性能问题，请慎重。
- **方式二：基于PG进程信息查看**
在主节点、从节点分别执行进程查看命令，通过查看wal receiver进程信息来确定流复制。
  
主节点(192.168.23.205)
```
-bash-4.2$ ps -ef|grep postgres|grep wal
postgres 17790 17785  0 8月31 ?       00:00:02 postgres: walwriter   
postgres 17812 17785  0 8月31 ?       00:00:04 postgres: walsender replica 192.168.23.206(39750) streaming 0/A000378
postgres 21261 20985  0 13:46 pts/1    00:00:00 grep --color=auto wal
```
- walsender replica： 可以从此处看到当前从节点的相关信息
  
从节点(192.168.23.206)
```
-bash-4.2$ ps -ef|grep postgres |grep wal
postgres 13822 10714  0 9月01 ?       00:01:32 postgres: walreceiver   
postgres 14469 13894  0 10:51 pts/0    00:00:00 grep --color=auto wal
```
### 四、主从切换及恢复
当主库出现故障时，需要将备库提升为主库进行读写操作。  

**4.1. 主从操作简述**  
在pg12以前的主备切换方式：
- 1. pg_ctl方式： 在备库主机执行pg_ctl promote shell 脚本
- 2. 触发器文件方式： 备库配置recovery.conf 文件的trigger_file 参数，之后在备库主机上创建触发器文件

在pg12以后新增了一个**pg_promote()** 函数，可以通过SQL命令激活备库：  
pg_promote()语法：
```
pg_promote(wait boolean DEFAULT ture, wait_seconds integer DEFAULT 60)
```
参数说明：
- wait： 表示是否等待备库的promotion完成或者wait_seconds秒之后返回成功，默认值为true
- wait_seconds：等待时间，单位秒，默认 60

**4.2. 主从操作案例**
1. 主库操作：关闭主库，模拟主库故障
```
systemctl stop postgresql-12
```
2. 备库操作： 激活备库
```
[root@localhost ~]# su - postgres
上一次登录：二 9月  1 16:50:20 CST 2020pts/0 上
-bash-4.2$ psql
psql (12.4)
输入 "help" 来获取帮助信息.

postgres=# select pg_promote(true,60);
```
3. 验证
主节点(192.168.23.205)
```
-bash-4.2$ /usr/pgsql-12/bin/pg_controldata /home/postgres/data
pg_control 版本:                      1201
Catalog 版本:                         201909212
数据库系统标识符:                     6866964125929260218
数据库簇状态:                         在运行中   # 数据库簇状态
```
从节点(192.168.23.206)
```
-bash-4.2$ /usr/pgsql-12/bin/pg_controldata /home/postgres/data
pg_control 版本:                      1201
Catalog 版本:                         201909212
数据库系统标识符:                     6866964125929260218
数据库簇状态:                         正在归档恢复    # 数据库簇状态

```

**参考链接:**  
一文彻底弄懂PostgreSQL流复制 
https://blog.csdn.net/luxingjyp/article/details/104647447  
PostgreSQL 流复制异步转同步
https://blog.csdn.net/strawberry1019/article/details/104717126/
CentOS PostgreSQL 12 主从复制(主从切换)
https://www.cnblogs.com/VicLiu/p/12993542.html


<font color=gray>文档内容仅用于学习使用。如有侵权，请及时联系QQ群：647934871</font>

[1]: http://www.postgres.cn/docs/12/index.html "PostgreSQL 官文档"
