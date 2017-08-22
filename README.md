# MySQL Partition Examples
In MySQL, `parititon key` has to be a part of unique key. 

### Range Partition (Numeric ID)
``RANGE PARTITION`` is commonly used. Normally it is based on a numeric ``ID`` field.  

```
CREATE TABLE test.`TABLE_NAME` (  
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `value` VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (`ID`)
)  PARTITION BY RANGE(ID)
(
   PARTITION p0 VALUES LESS THAN (1000),
   PARTITION p1 VALUES LESS THAN (2000),
   PARTITION p2 VALUES LESS THAN (3000),
   PARTITION p3 VALUES LESS THAN (4000),
   PARTITION p4 VALUES LESS THAN (MAXVALUE)
);
```

### Range Partition (DATE)
Another example is to create monthly partition based on a `DATE` field.

```
CREATE TABLE test.`MONTHLY_TABLE` (  
  `ID` INT(10) NOT NULL AUTO_INCREMENT,
  `value` VARCHAR(100) DEFAULT NULL,
  `DATA_DATE` DATE NOT NULL,
  PRIMARY KEY (`ID`,`DATA_DATE`)
) PARTITION BY RANGE( TO_DAYS(DATA_DATE) ) (
    PARTITION pmin VALUES LESS THAN (TO_DAYS('2017-01-01')),
    PARTITION p201701 VALUES LESS THAN (TO_DAYS('2017-02-01')),
    PARTITION p201702 VALUES LESS THAN (TO_DAYS('2017-03-01')),
    PARTITION p201703 VALUES LESS THAN (TO_DAYS('2017-04-01')),
    PARTITION p201704 VALUES LESS THAN (TO_DAYS('2017-05-01')),
    PARTITION p201705 VALUES LESS THAN (TO_DAYS('2017-06-01')),
    PARTITION p201706 VALUES LESS THAN (TO_DAYS('2017-07-01')),
    PARTITION p201707 VALUES LESS THAN (TO_DAYS('2017-08-01')),
    PARTITION p201708 VALUES LESS THAN (TO_DAYS('2017-09-01')),
    PARTITION p201709 VALUES LESS THAN (TO_DAYS('2017-10-01')),
    PARTITION p201710 VALUES LESS THAN (TO_DAYS('2017-11-01')),
    PARTITION p201711 VALUES LESS THAN (TO_DAYS('2017-12-01')),
    PARTITION p201712 VALUES LESS THAN (TO_DAYS('2018-01-01')),
    PARTITION p201801 VALUES LESS THAN (TO_DAYS('2018-02-01')),
    PARTITION p201802 VALUES LESS THAN (TO_DAYS('2018-03-01')),
    PARTITION p201803 VALUES LESS THAN (TO_DAYS('2018-04-01')),
    PARTITION p201804 VALUES LESS THAN (TO_DAYS('2018-05-01')),
    PARTITION p201805 VALUES LESS THAN (TO_DAYS('2018-06-01')),
    PARTITION p201806 VALUES LESS THAN (TO_DAYS('2018-07-01')),
    PARTITION p201807 VALUES LESS THAN (TO_DAYS('2018-08-01')),
    PARTITION p201808 VALUES LESS THAN (TO_DAYS('2018-09-01')),
    PARTITION p201809 VALUES LESS THAN (TO_DAYS('2018-10-01')),
    PARTITION p201810 VALUES LESS THAN (TO_DAYS('2018-11-01')),
    PARTITION p201811 VALUES LESS THAN (TO_DAYS('2018-12-01')),
    PARTITION p201812 VALUES LESS THAN (TO_DAYS('2019-01-01')),
    PARTITION pmax VALUES LESS THAN MAXVALUE
  );
  ```

A simple shell script `generate_partitions.sh` to generate all partitions is provided below.  It allows you to generate partition statments starting with any date for any number of parititions.

```
#!/bin/sh

# initial partition date
DATE=2017-01-01

# generate for 24 months parititions
for i in {0..24}
do
   START_MONTH_DATE=$(date -d "$DATE $i month" +%Y-%m-%d)
   NEXT_MONTH_DATE=$(date -d "$DATE $(($i+1)) month" +%Y-%m-%d)
   MONTH_CONVENTION=$(date -d "$START_MONTH_DATE" +%Y%m)
   #echo "$MONTH_END_DATE"
   #echo "$NEXT_MONTH_DATE"
   #echo "$MONTH_CONVENTION"
   echo "PARTITION p$MONTH_CONVENTION VALUES LESS THAN (TO_DAYS('$NEXT_MONTH_DATE')),"
done
```

### List Partition (Cyclic partition)

Create a Cyclic Partition for last 30 days data using List Partition. Sometimes, we only want to keep archive data for the last several days. It is necessary to create a cyclic partition for daily data. The example below shows how to create a cyclic partition table for last 30 days data using ``LIST PARTITION``. 

```
CREATE TABLE test.`CYCLIC_TABLE` (  
  `ID` INT(10) NOT NULL AUTO_INCREMENT,
  ...
  `DATA_DATE` DATE NOT NULL,
  PRIMARY KEY (`ID`,`DATA_DATE`)
  ) PARTITION BY LIST(MOD(TO_DAYS(DATA_DATE), 30)) (
    PARTITION p0 VALUES IN (0),
    PARTITION p1 VALUES IN (1),
    PARTITION p2 VALUES IN (2),
    PARTITION p3 VALUES IN (3),
    PARTITION p4 VALUES IN (4),
    PARTITION p5 VALUES IN (5),
    PARTITION p6 VALUES IN (6),
    PARTITION p7 VALUES IN (7),
    PARTITION p8 VALUES IN (8),
    PARTITION p9 VALUES IN (9),
    PARTITION p10 VALUES IN (10),
    PARTITION p11 VALUES IN (11),    
    PARTITION p12 VALUES IN (12),
    PARTITION p13 VALUES IN (13),
    PARTITION p14 VALUES IN (14),
    PARTITION p15 VALUES IN (15),
    PARTITION p16 VALUES IN (16),    
    PARTITION p17 VALUES IN (17),
    PARTITION p18 VALUES IN (18),
    PARTITION p19 VALUES IN (19),    
    PARTITION p20 VALUES IN (20),
    PARTITION p21 VALUES IN (21),    
    PARTITION p22 VALUES IN (22),
    PARTITION p23 VALUES IN (23),
    PARTITION p24 VALUES IN (24),
    PARTITION p25 VALUES IN (25),
    PARTITION p26 VALUES IN (26),    
    PARTITION p27 VALUES IN (27),
    PARTITION p28 VALUES IN (28),
    PARTITION p29 VALUES IN (29)    
);
```

### Hash Partition

There is another partition - `HASH PARTITION`. When PARTITION BY HASH is used, MySQL determines which partition of num partitions to use based on the modulus of the result of the expression. In other words, for a given expression expr, the partition in which the record is stored is partition number N, where N = MOD(expr, num). Suppose table HASH_TABLE is defined as follows, it has 10 partitions based on the year of a ``DATE`` field. 

```
CREATE TABLE test.`HASH_TABLE` (  
  `ID` NOT NULL AUTO_INCREMENT,
  `DATA_DATE` DATE NOT NULL,
  PRIMARY KEY (`ID`,`DATA_DATE`)
  ) PARTITION BY HASH(YEAR(DATA_DATE))
  PARTITIONS 10;
```

If we insert a record with ``DATA_DATE = '2010-01-10'``, the partition number = MOD(year(DATE_DATE), 10) --- partition 0 is its partition. 
For the Cyclic example in the last section, it can be redefined using HASH partition as below. 

```
CREATE TABLE test.`CYCLIC_TABLE2` (
  `ID` INT(10) NOT NULL AUTO_INCREMENT,
  `DATA_DATE` DATE NOT NULL,
  PRIMARY KEY (`ID`,`DATA_DATE`)
  ) PARTITION BY HASH(TO_DAYS(DATA_DATE))
  PARTITIONS 30;
```


### Some basic partition SQLs

#### Select one partition data

```
SELECT * FROM MONTHLY_TABLE PARTITION(p201707);
```

#### Truncate one partition

```
ALTER TABLE MONTHLY_TABLE TRUNCATE PARTITION p201707;
```

#### Explain partitions

```
EXPLAIN PARTITIONS SELECT * FROM MONTHLY_TABLE WHERE data_date = '2017-08-01';
```

#### Add new partition

```
ALTER TABLE MONTHLY_TABLE ADD PARTITION (PARTITION p201912 VALUES LESS THAN (TO_DAYS('2020-12-01')));
```

With tables that are partitioned by range, you can use ADD PARTITION to add new partitions to the ``high end of the partitions list only``. Trying to add a new partition in this manner between or before existing partitions results in an error like: ``ERROR 1463 (HY000): VALUES LESS THAN value must be strictly``.   In this case, you can reorganize your partition. 

#### Reorganize existing partition 

```
ALTER TABLE MONTHLY_TABLE
    REORGANIZE PARTITION pmax INTO (
        PARTITION p201912 VALUES LESS THAN (TO_DAYS('2020-12-01')),
        PARTITION pmax VALUES LESS THAN MAXVALUE
);
```

