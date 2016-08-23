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


