/* queries and updates for working with the raw nickname data */

/* I manually imported names.csv into Oracle 
 * putting EACH COMPLETE ROW into the column RAW_DATA.
 * I created a table like this to hold the data.
 */
CREATE TABLE NICKNAMES (
  RAW_DATA VARCHAR2(256), 
	GIVEN_NAME VARCHAR2(100), 
	TOP_NICKNAME VARCHAR2(100), 
	ALL_NICKNAMES VARCHAR2(100)
);

/* The GIVEN_NAME is the first name. */
select substr( RAW_DATA, 1, INSTR(RAW_DATA, ',') - 1 ) from NICKNAMES;

/* Populate the field GIVEN_NAME */
update NICKNAMES
   set GIVEN_NAME = substr( RAW_DATA, 1, INSTR(RAW_DATA, ',') - 1 ) ;

/* Populate the field ALL_NICKNAMES. The nicknames are all of the names after the first one. */
update NICKNAMES
   set ALL_NICKNAMES = substr( RAW_DATA, INSTR(RAW_DATA, ',') + 1 ) ;


select RAW_DATA, 
instr( RAW_DATA, ',', 1, 2 ) as two, 
substr( RAW_DATA, INSTR(RAW_DATA, ',') + 1 ) as topNick 
from NICKNAMES ;

/* There are many cases where only 1 nickname is proposed.
 * In these cases, set the TOP_NICKNAME to this value.
 */
update NICKNAMES
   set TOP_NICKNAME = CASE WHEN instr( RAW_DATA, ',', 1, 2 ) > 0 THEN NULL
                      ELSE substr( RAW_DATA, INSTR(RAW_DATA, ',') + 1 ) END ;

select RAW_DATA, substr( RAW_DATA, INSTR(RAW_DATA, ',') + 1 )
from NICKNAMES ;

select 
   case when TOP_NICKNAME is null then 'bad' else 'good' end as known_top_nickname
  ,count(*) 
from NICKNAMES 
group by case when TOP_NICKNAME is null then 'bad' else 'good' end;


/* For the large number of remaining records... manually select the TOP_NICKNAME. Yuck. */

/* Having manually set all of the TOP_NICKNAME values, now we clean up the raw data. */
/* names.csv was alphabetical, but the nicknames following the GIVEN_NAME were not alphabetical. */

/* note the hard-coded use of '14' below because the data is known to have a maximum of 14 nicknames (but this could change in the future!! */
/* I found the value 14 like this: */
select max(regexp_count(ALL_NICKNAMES, ',')) num_names from NICKNAMES;

/* test on just a few rows */
select n.*, REGEXP_SUBSTR(ALL_NICKNAMES, '[^,]+', 1, rn) as split_string
from 
  (select * from NICKNAMES where RAW_DATA like 'aaron%' or RAW_DATA like 'agnes%' or RAW_DATA like 'abiel%' or RAW_DATA like 'adelaide%') n
  cross join (select rownum as rn from dual connect by level <= 14)
where REGEXP_SUBSTR(ALL_NICKNAMES, '[^,]+', 1, rn) IS NOT NULL
order by 1, 5
;

/* Get a record for each nickname. Stated otherwise: normalize the data */
select n.*, REGEXP_SUBSTR(ALL_NICKNAMES, '[^,]+', 1, rn) as split_string
from NICKNAMES n
cross join (select rownum as rn from dual connect by level <= 14)
where REGEXP_SUBSTR(ALL_NICKNAMES, '[^,]+', 1, rn) IS NOT NULL
order by 1, 5
;

/* Now aggregate them back together, but this time the nicknames are put in alphabetical order. */
select RAW_DATA, max(GIVEN_NAME) GIVEN_NAME, max(TOP_NICKNAME) TOP_NICKNAME, listagg(split_string, ',') within group (order by split_string) ALL_NICKNAMES_ORDERED 
from (
  select n.*, REGEXP_SUBSTR(ALL_NICKNAMES, '[^,]+', 1, rn) as split_string
  from NICKNAMES n
  cross join (select rownum as rn from dual connect by level <= 14)
  where REGEXP_SUBSTR(ALL_NICKNAMES, '[^,]+', 1, rn) IS NOT NULL
)
group by RAW_DATA
order by RAW_DATA
;

/* Save the output of this final query to names_enhanced.csv. */
/* This "csv" file is pipe-separated, but that doesn't bother me. */




