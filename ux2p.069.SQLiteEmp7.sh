# ux2p-XXX-SQLiteEmp7
# by mail@meo.bogliolo.name (c)
#
# HTML emp7 benchmark on SQLite Plugin
#
# Usage:
# called by ux2html.sh 
#
# Notes:

# History:
#   1 Apr 11 1.0.0       meo     First release

PL_VERSION=1.0.0
PL_DESCR="emp7 SQLite Benchmark"

echo '<P><A NAME="emp7"></A><H2>' $PL_DESCR '</h2>' 
echo 'Plug-in version:' $PL_VERSION

which sqlite3 2>/dev/null
RES=$?
if [ $RES -eq 0 ]
 then
echo '<p>SQLite version:'
sqlite3 -version

echo '<p>EMP7 Benchmark:'
echo '<pre>'
sqlite3 emp7.db << EOF
create table emp7(EMPNO integer not null,ENAME VARCHAR(10),JOB VARCHAR(9),
        MGR integer,HIREDATE DATE,SAL float,COMM float,DEPTNO integer);
create unique index pkemp7 on emp7(EMPNO);
insert into emp7(empno, ename, deptno) values(7369, 'SMITH', 10);
insert into emp7(empno, ename, deptno) values(7499, 'ALLEN', 10);
insert into emp7(empno, ename, deptno) values(7521, 'WARD',  10);
insert into emp7(empno, ename, deptno) values(7566, 'JONES', 10);
insert into emp7(empno, ename, deptno) values(7654, 'MARTIN',10);
insert into emp7(empno, ename, deptno) values(7698, 'BLAKE', 10);
insert into emp7(empno, ename, deptno) values(7782, 'CLARK', 10);
insert into emp7(empno, ename, deptno) values(7788, 'SCOTT', 10);
insert into emp7(empno, ename, deptno) values(7839, 'KING',  10);
insert into emp7(empno, ename, deptno) values(7844, 'TURNER',10);
insert into emp7(empno, ename, deptno) values(7876, 'ADAMS', 10);
insert into emp7(empno, ename, deptno) values(7900, 'JAMES', 10);
insert into emp7(empno, ename, deptno) values(7902, 'FORD',  10);
insert into emp7(empno, ename, deptno) values(7934, 'MILLER',10);
EOF

( time sqlite3 emp7.db << EOF
select count(*)
  from emp7 emp1, emp7 emp2, emp7 emp3, emp7 emp4, emp7 emp5, emp7 emp6, emp7 emp_7
  where emp_7.deptno=10;
EOF
)  >emp7.out 2>&1
cat emp7.out
rm emp7.db emp7.out

echo '</pre>'
echo '<p>'

else
    echo '<p>SQLite not found'
fi
