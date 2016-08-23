DROP PACKAGE BODY CSV_UTIL_PKG;

CREATE OR REPLACE package body csv_util_pkg
as

/*

Purpose: Package handles comma-separated values (CSV)

Remarks:

Who Date Description
------ ---------- --------------------------------
MBR 31.03.2010 Created

*/


function csv_to_array (p_csv_line in varchar2,
p_separator in varchar2 := g_default_separator) return t_str_array
as
l_returnvalue t_str_array := t_str_array();
l_start_separator pls_integer := 0 ;
l_stop_separator pls_integer := 0 ;
l_length pls_integer := 0 ;
l_idx binary_integer := 0 ;
l_quote_enclosed boolean := false ;
l_offset pls_integer := 1 ;
begin

/*

Purpose: convert CSV line to array of values

Remarks: based on code from http://www.experts-exchange.com/Database/Oracle/PL_SQL/Q_23106446.html

Who Date Description
------ ---------- --------------------------------
MBR 31.03.2010 Created

*/

l_length := length(p_csv_line) ;

if l_length > 0 then
loop
l_idx := l_idx + 1;

l_quote_enclosed := false;
if substr(p_csv_line, l_start_separator + 1, 1) = '"' then
l_quote_enclosed := true;
l_offset := 2;
l_stop_separator := instr(p_csv_line, '"', l_start_separator + l_offset, 1);
else
l_offset := 1;
l_stop_separator := instr(p_csv_line, p_separator, l_start_separator + l_offset, 1);
end if;

if l_stop_separator = 0 then
l_stop_separator := l_length + 1;
end if;

l_returnvalue.extend;
l_returnvalue(l_idx) := substr(p_csv_line, l_start_separator + l_offset, (l_stop_separator - l_start_separator - l_offset));
exit when l_stop_separator >= l_length;

if l_quote_enclosed then
l_stop_separator := l_stop_separator + 1;
end if ;
l_start_separator := l_stop_separator;
end loop;

end if;

return l_returnvalue;

end csv_to_array;


function array_to_csv (p_values in t_str_array,
p_separator in varchar2 := g_default_separator) return varchar2
as
l_value varchar2(32000);
l_returnvalue varchar2(32000);
begin

/*

Purpose: convert array of values to CSV

Remarks:

Who Date Description
------ ---------- --------------------------------
MBR 31.03.2010 Created

*/

for i in p_values.first .. p_values.last loop
l_value := p_values(i);
if instr(l_value, p_separator) > 0 then
l_value := '"' || l_value || '"';
end if;
if l_returnvalue is null then
l_returnvalue := l_value;
else
l_returnvalue := l_returnvalue || p_separator || l_value;
end if;
end loop;

return l_returnvalue;

end array_to_csv;


function get_array_value (p_values in t_str_array,
p_position in number,
p_column_name in varchar2 := null) return varchar2
as
l_returnvalue varchar2(4000);
begin

/*

Purpose: get value from array by position

Remarks:

Who Date Description
------ ---------- --------------------------------
MBR 31.03.2010 Created

*/

if p_values.count >= p_position then
l_returnvalue := p_values(p_position);
else
if p_column_name is not null then
raise_application_error (-20000, 'Column number ' || p_position || ' does not exist. Expected column: ' || p_column_name);
else
l_returnvalue := null;
end if;
end if;

return l_returnvalue;

end get_array_value;


function clob_to_csv (p_csv_clob in clob,
p_separator in varchar2 := g_default_separator,
p_skip_rows in number := 0) return t_csv_tab pipelined
as
l_line_separator varchar2(2) := chr(13) || chr(10);
l_last pls_integer;
l_current pls_integer;
l_line varchar2(32000);
l_line_number pls_integer := 0;
l_from_line pls_integer := p_skip_rows + 1;
l_line_array t_str_array;
l_row t_csv_line := t_csv_line (null, null, -- line number, line raw
null, null, null, null, null, null, null, null, null, null, -- lines 1-10
null, null, null, null, null, null, null, null, null, null); -- lines 11-20
begin

/*

Purpose: convert clob to CSV

Remarks: based on code from http://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:1352202934074
and http://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:744825627183

Who Date Description
------ ---------- --------------------------------
MBR 31.03.2010 Created

*/

-- If the file has a DOS newline (cr+lf), use that
-- If the file does not have a DOS newline, use a Unix newline (lf)
if (nvl(dbms_lob.instr(p_csv_clob, l_line_separator, 1, 1),0) = 0) then
l_line_separator := chr(10);
end if;

l_last := 1;

loop

l_current := dbms_lob.instr (p_csv_clob || l_line_separator, l_line_separator, l_last, 1);
exit when (nvl(l_current,0) = 0);

l_line_number := l_line_number + 1;

if l_from_line <= l_line_number then

l_line := dbms_lob.substr(p_csv_clob || l_line_separator, l_current - l_last + 1, l_last);
--l_line := replace(l_line, l_line_separator, '');
l_line := replace(l_line, chr(10), '');
l_line := replace(l_line, chr(13), '');

l_line_array := csv_to_array (l_line, p_separator);

l_row.line_number := l_line_number;
l_row.line_raw := substr(l_line,1,4000);
l_row.c001 := get_array_value (l_line_array, 1);
l_row.c002 := get_array_value (l_line_array, 2);
l_row.c003 := get_array_value (l_line_array, 3);
l_row.c004 := get_array_value (l_line_array, 4);
l_row.c005 := get_array_value (l_line_array, 5);
l_row.c006 := get_array_value (l_line_array, 6);
l_row.c007 := get_array_value (l_line_array, 7);
l_row.c008 := get_array_value (l_line_array, 8);
l_row.c009 := get_array_value (l_line_array, 9);
l_row.c010 := get_array_value (l_line_array, 10);
l_row.c011 := get_array_value (l_line_array, 11);
l_row.c012 := get_array_value (l_line_array, 12);
l_row.c013 := get_array_value (l_line_array, 13);
l_row.c014 := get_array_value (l_line_array, 14);
l_row.c015 := get_array_value (l_line_array, 15);
l_row.c016 := get_array_value (l_line_array, 16);
l_row.c017 := get_array_value (l_line_array, 17);
l_row.c018 := get_array_value (l_line_array, 18);
l_row.c019 := get_array_value (l_line_array, 19);
l_row.c020 := get_array_value (l_line_array, 20);

pipe row (l_row);

end if;

l_last := l_current + length (l_line_separator);

end loop;

return;

end clob_to_csv;


end csv_util_pkg;
/
