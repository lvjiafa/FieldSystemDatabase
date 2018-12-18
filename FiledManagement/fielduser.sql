--通过视图查询所有场地的基本信息
set line 300
select * from field_view;
--通过视图查询员工人数、工资等信息
 select * from workers_view;
--往学生表插入信息，在工作时间则输出成功插入，否则输出禁止在非工作时间操作
set serveroutput on
insert into students (s_number,s_name) values (311313321,'小明');
--更新员工薪水，若薪水高于当前薪水则成功更新，否则输出错误信息涨后薪水不能低于涨前薪水
update worker set w_money=5000 where  w_number=999581944;
update worker set w_money=3000 where  w_number=728135026;
--更新员工信息，自动备份到员工备份表中
select * from emp_back_worker where w_number=627151605;
update worker set w_money=4700 where  w_number=627151605;
select * from emp_back_worker where w_number=627151605;
--更新员工薪水，薪水大于5000时，自动把该员工信息保存到audit_info表
select * from audit_info;
update worker set w_money=5200 where w_number=754430612;
select * from audit_info;
--调用count_number_pro过程，得到学生、教师、领导、员工的总人数
set serveroutput on
exec count_number_pro();
--调用存储过程给指定员工涨指定工资并存入员工表中，否则则输出无此员工
set serveroutput on
exec raise_money_pro(412938168,300);
exec raise_money_pro(15552,100);







