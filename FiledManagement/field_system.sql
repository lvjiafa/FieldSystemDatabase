--创建表空间field_data
drop tablespace field_data including contents and datafiles;
create tablespace field_data datafile 
'D:field_data01.dbf' size 1024M;
--创建临时表空间field_temp
drop tablespace field_temp including contents and datafiles;
create temporary tablespace field_temp tempfile 
'D:\field_temp01.dbf' size 512M;
--创建用户
drop user fielduser01 cascade;
create user fielduser01 identified by adim123
default tablespace field_data
temporary tablespace field_temp;
drop user fielduser02 cascade;
create user fielduser02 identified by adim123
temporary tablespace field_temp;
--创建角色deve_role
drop role deve_role;
create role deve_role not identified;
grant CREATE SESSION,
ALTER SESSION,
RESTRICTED SESSION,
CREATE TABLESPACE,
ALTER TABLESPACE,
MANAGE TABLESPACE,
DROP TABLESPACE,
CREATE USER,
BECOME USER,
ALTER USER,
DROP USER,
CREATE ROLLBACK SEGMENT,
ALTER ROLLBACK SEGMENT,
DROP ROLLBACK SEGMENT,
CREATE TABLE,
CREATE CLUSTER,
CREATE VIEW,
CREATE TRIGGER,
CREATE PROFILE,
ALTER PROFILE,
DROP PROFILE,
ALTER RESOURCE COST,
CREATE MATERIALIZED VIEW,
CREATE ANY LIBRARY,
CREATE INDEXTYPE,
QUERY REWRITE,
GLOBAL QUERY REWRITE,
CREATE DIMENSION,
CREATE RULE,
CREATE SEQUENCE,
create procedure,
ALTER DATABASE,
CREATE JOB,
unlimited tablespace,
CREATE ANY DIRECTORY
to deve_role
with admin option;
--将角色授予fielduser01
grant deve_role to fielduser01;
grant unlimited tablespace to fielduser01;
create or replace directory data_dir as 'D:\data\emp\data';
create or replace directory log_dir as 'D:\data\emp\log';
create or replace directory bad_dir as 'D:\data\emp\bad';
grant read on directory data_dir to fielduser01;
grant write on directory log_dir to fielduser01;
grant write on directory bad_dir to fielduser01;
/
--连接fielduser01用户
conn fielduser01/adim123@orcl
--创建基本表academy
drop table academy;
create  table academy(
a_number number(20) primary key,
a_name varchar2(40) not null
)
tablespace field_data;
--创建基本表teachers
drop table teachers;
create  table teachers(
t_number number(12) ,
t_name varchar2(20) not null,
a_number number(20) not null  references academy(a_number),
t_rank varchar2(40),
constraint pk_teachers primary key(t_number,t_name)
)
tablespace field_data;
--创建基本表major
drop table major;
create  table major(
m_number number(20) primary key,
m_name varchar2(40) not null,
a_nuber number(20)  references academy(a_number)
)
tablespace field_data;
--创建基本表stutdents
drop table students;
create  table students(
s_number number(12),
s_name varchar2(20) not null,
s_grade varchar2(10),
a_number number(20)  references academy(a_number),
m_number number(20) ,
constraint pk_students primary key(s_number,s_name)
)
tablespace field_data;
--创建基本表department
drop table department;
create  table department(
d_number number primary key,
d_name varchar2(40) not null,
l_name number(20),
d_phone varchar2(40)
)
tablespace field_data;
--创建基本表leader
drop table leader;
create  table leader(
l_number number(20) primary key,
l_name varchar2(20) not null,
d_number number(20)  references department(d_number)
)
tablespace field_data;
--创建基本表field
drop table field;
create  table field(
f_number number(20) primary key,
f_name varchar2(40) not null,
f_use varchar2(100),
f_starttime varchar2(40) not null,
f_endtime varchar2(40) not null,
l_number number(20) references leader(l_number),
f_location varchar2(40) not null
)
tablespace field_data;
--创建外部表exter_workers
drop table worker;
create  table worker(
w_number number(20) primary key,
w_name varchar2(20) not null,
d_number number(20)  references department(d_number),
f_number number(20)  references field(f_number),
l_number number(20)  references leader(l_number),
w_money number(6) check(w_money>0)
)
tablespace field_data;
--创建基本表pass
drop table pass;
create  table pass(
p_number number(11) not null,
p_password varchar2(20) not null,
constraint PK_pass primary key(p_number,p_password)
)
tablespace field_data;
--创建基本表auto_info，备份信息
drop table audit_info;
create table audit_info
(
  infomation varchar2(200)
);
--创建外部表exter_students
drop table exter_students;
create  table exter_students
(
s_number number(12),
s_name varchar2(20),
s_grade varchar2(10),
a_number number(20) ,
m_number number(20)
)
organization external
(
type oracle_loader
default directory data_dir
access parameters
(
records delimited by newline
badfile bad_dir:'students.bad'
logfile log_dir:'students.log'
fields terminated by ','
)
location ('studentsData.txt')
)
parallel
reject limit unlimited;
--创建外部表exter_leaders
drop table exter_leaders;
create  table exter_leaders
(
l_number number(20),
l_name varchar2(20),
d_number number(20)
)
organization external
(
type oracle_loader
default directory data_dir
access parameters
(
records delimited by newline
badfile bad_dir:'leader.bad'
logfile log_dir:'leader.log'
fields terminated by ','
)
location ('leadersData.txt')
)
parallel
reject limit unlimited;
--创建外部表exter_teachers
drop table exter_teachers;
create  table exter_teachers
(
t_number number(12) ,
t_name varchar2(20) ,
a_number number(20) ,
t_rank varchar2(40)
)
organization external
(
type oracle_loader
default directory data_dir
access parameters
(
records delimited by newline
badfile bad_dir:'teachers.bad'
logfile log_dir:'teachers.log'
fields terminated by ','
)
location ('teachersData.txt')
)
parallel
reject limit unlimited;
--创建外部表exter_workers
drop table exter_workers;
create  table exter_workers
(
w_number number(20),
w_name varchar2(20),
d_number number(20) ,
f_number number(20),
l_number number(20),
w_money number(6) 
)
organization external
(
type oracle_loader
default directory data_dir
access parameters
(
records delimited by newline
badfile bad_dir:'workers.bad'
logfile log_dir:'workers.log'
fields terminated by ','
)
location ('workersData.txt')
)
parallel
reject limit unlimited;
--在表students上创建索引stu_name_idx
drop index stu_name_idx;
create index stu_name_idx
on students (s_name);
--创建序列department_seq
drop sequence department_seq;
create sequence department_seq
increment by 1
start with 1
maxvalue 60
nocycle
nocache;
--创建序列field_seq
drop sequence field_seq;
create  sequence field_seq
increment by 1
start with 1
maxvalue 50
nocycle
nocache;
--创建teacher_view视图
create or replace view teachers_view
("教师编号","教师姓名","所属学院","职称")
as
select t.t_number,t.t_name,a.a_name,t.t_rank
from teachers t
join academy a
on t.a_number=a.a_number;
--创建field_view视图
create or replace view field_view
("场地编号","场地名称","场地用途","场地位置","开放时间","关闭时间")
as
select f_number,f_name,f_use,f_location,f_starttime,f_endtime
from field;
--创建员工视图返回员工平均工资、最高工资等信息
create or replace view workers_view
("员工人数","最高工资","最低工资","平均工资")
as
select
count(w_number),max(w_money),min(w_money),avg(w_money)
from worker;
--往academy表插入数据
delete academy;
insert into academy values(01,'五邑大学经济管理学院');
insert into academy values(02,'五邑大学文学院');
insert into academy values(03,'五邑大学信息管理学院');
insert into academy values(04,'五邑大学外国语学院');
insert into academy values(05,'五邑大学数学与计算科学学院');
insert into academy values(06,'五邑大学应用物理与材料学院');
insert into academy values(07,'五邑大学信息工程学院');
insert into academy values(08,'五邑大学计算机学院');
insert into academy values(09,'五邑大学机电工程学院');
insert into academy values(10,'五邑大学土木建筑学院');
insert into academy values(11,'五邑大学化学与环境学院');
insert into academy values(12,'五邑大学纺织服装学院');
insert into academy values(13,'五邑大学艺术设计学院');
insert into academy values(14,'五邑大学思想政治理论教学部');
insert into academy values(15,'五邑大学体育部');
insert into academy values(16,'五邑大学轨道交通学院');

alter table department drop (l_name);
alter table worker drop (l_number);
alter table exter_workers drop (l_number);
--往department插入数据
delete department;
insert into department values(department_seq.nextval,'党政办公室','5236458');
insert into department values(department_seq.nextval,'纪委办公室','75238');
insert into department values(department_seq.nextval,'宣传部','7656236416');
insert into department values(department_seq.nextval,'学生工作处','8656921');
insert into department values(department_seq.nextval,'武装部','525121');
insert into department values(department_seq.nextval,'离退老干处','76239');
insert into department values(department_seq.nextval,'工会','8273639');
insert into department values(department_seq.nextval,'团委','6291877');
insert into department values(department_seq.nextval,'教务处','2153846');
insert into department values(department_seq.nextval,'科技处','521386');
insert into department values(department_seq.nextval,'研究生处','217394421');
insert into department values(department_seq.nextval,'后勤处','213642132');
insert into department values(department_seq.nextval,'财务处','2136492121');
insert into department values(department_seq.nextval,'处事处','2136499');
insert into department values(department_seq.nextval,'实验室与设备管理处','26134123');
insert into department values(department_seq.nextval,'人事处','721368482');
insert into department values(department_seq.nextval,'招生办公室','281639412');
insert into department values(department_seq.nextval,'招生服务中心','213948213');
insert into department values(department_seq.nextval,'学业指导与服务中心','2716394');
insert into department values(department_seq.nextval,'心理教育服务中心','2173649');
insert into department values(department_seq.nextval,'就业指导与服务中心','721358');
insert into department values(department_seq.nextval,'校友服务中心','76239222');
insert into department values(department_seq.nextval,'教师教学发展中心','7263723222');
insert into department values(department_seq.nextval,'教育教学评估中心','62376411234');
insert into department values(department_seq.nextval,'企业联盟联络服务中心','82876364');
insert into department values(department_seq.nextval,'基建工程管理中心','762873723');
insert into department values(department_seq.nextval,'综合信息管理中心','128731122');
insert into department values(department_seq.nextval,'招投标服务中心','23837877123');
insert into department values(department_seq.nextval,'图书馆','18723812');
insert into department values(department_seq.nextval,'网络管理中心','1727638912');
insert into department values(department_seq.nextval,'高教研究所','12683');
insert into department values(department_seq.nextval,'广东侨乡文化研究中心','8123721');
insert into department values(department_seq.nextval,'LED研究院','12382344');
insert into department values(department_seq.nextval,'江门邑大文化交流中心','237823479');
insert into leader select * from exter_leaders;
--往field表插入数据
delete field;
insert into field values(field_seq.nextval,'伍威权体育运动中心','游泳','16:00','18:00',199342378,'北区操场旁');
insert into field values(field_seq.nextval,'谭兆体育馆','羽毛球、乒乓球','19:00','22:00',197067793,'北区操场对面');
insert into field values(field_seq.nextval,'田径场','跑步、足球','08:00','22:00',356106749,'游泳池旁');
insert into field values(field_seq.nextval,'沙土网球场','网球','08:00','18:00',250229644,'北区操场旁');
insert into field values(field_seq.nextval,'吕赵锦屏网球场','网球','08:00','21:30',397719208,'北主楼前');
insert into field values(field_seq.nextval,'户外篮球场','游泳','08:00','22:00',247696212,'马兰芳教学楼旁');
insert into field values(field_seq.nextval,'马观适运动馆','健身、乒乓球、舞蹈','16:00','18:00',518642049,'第四饭堂旁');
insert into field values(field_seq.nextval,'风雨篮球场','篮球、排球','08:00','21:00',555512015,'马观适运动馆对面');
--使用外部表往students表中插入数据
insert into  students select * from exter_students;
--使用外部表往teachers表中插入数据
insert into  teachers select * from exter_teachers;
--使用外部表往woker表插入数据
delete worker;
insert into  worker select * from exter_workers;
--创建学生视图
create or replace view students_view
("学生学号","学生姓名","学生年级","学院名称")
as
select s.s_number,s.s_name,s.s_grade,a.a_name
from students s, academy a
where s.a_number=a.a_number;
drop table emp_back_worker;
create table emp_back_worker as select * from worker;
--创建触发器实现插入成功信息反馈
create or replace trigger sayMessage_trigger
after insert
on students
declare
begin
dbms_output.put_line('你已成功插入学生信息');
end;
/
--创建触发器实现非工作段禁止对学生表进行插入操作
create or replace trigger securitystudents_trigger
before insert
on students
declare
begin
if to_char(sysdate,'day') in ('星期六','星期日') or
   to_number(to_char(sysdate,'hh24')) not between 9 and 17 then
   raise_application_error(-20001,'禁止在非工作时间操作');
end if;
end;
/
--创建语句触发器，使员工涨薪不能低于涨薪前
create or replace trigger checkmoney_trigger
before update
on worker
for each row
declare
begin
if :new.w_money<:old.w_money then
raise_application_error(-20002,'涨后薪水不能低于涨前薪水,
  涨后薪水：'||:new.w_money||' 涨前薪水:'||:old.w_money);
end if;
end;
/
--创建行级触发器当员工工资大于5000，自动插入auto_info
create or replace trigger audit_money_trigger
after update
on worker
for each row
declare
begin
	if :new.w_money>5000 then
		insert into audit_info values(:new.w_number||'  '||:new.w_name||'  '||:new.w_money);
	end if;
end;
/
--创建行级触发器，自动备份插入的员工信息
create or replace trigger sync_money_trigger
after update
on worker
for each row
declare
begin
update emp_back_worker set w_money=:new.w_money where w_number=:new.w_number;
end;
/
--创建存储过程，统计总人数
create or replace procedure count_number_pro
as
	count_stu_number number(10);
	count_tea_number number(10);
	count_wor_number number(10);
	count_lead_number number(10);
begin
	select count(*) into count_stu_number from students;
	select count(*) into count_tea_number from teachers;
	select count(*) into count_lead_number from leader;
	select count(*) into count_wor_number from worker;
	dbms_output.put_line('学生总人数：'||count_stu_number);
	dbms_output.put_line('教师总人数：'||count_tea_number);
	dbms_output.put_line('领导总人数：'||count_lead_number);
	dbms_output.put_line('员工总人数：'||count_wor_number);
end;
/
--创建存储过程给指定员工涨工资
create or replace procedure raise_money_pro(p_number in number,p_raisemoney in number)
as
	p_money worker.w_money%type;
begin
	select w_money into p_money from worker where w_number=p_number;
	update worker set w_money=w_money+p_raisemoney;
	dbms_output.put_line('涨薪成功');
	dbms_output.put_line('该员工薪水为:'||(p_money+p_raisemoney));
exception
	when no_data_found then
	dbms_output.put_line('没有此员工');
end;
/
--授权给用户fileduser02
grant select on students to fielduser02 with grant option;
grant select on teachers to fielduser02 with grant option;
grant select on academy to fielduser02 with grant option;
grant select on major to fielduser02 with grant option;
grant select on worker to fielduser02 with grant option;
grant select on leader to fielduser02 with grant option;
grant select on department to fielduser02 with grant option;
grant select on field to fielduser02 with grant option;
grant select on pass to fielduser02 with grant option;
grant select on students_view to fielduser02 with grant option;
grant select on teachers_view to fielduser02 with grant option;
grant select on field_view to fielduser02 with grant option;
/