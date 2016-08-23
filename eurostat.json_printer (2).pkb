DROP PACKAGE BODY JSON_PRINTER;

CREATE OR REPLACE package body          "JSON_PRINTER" as
  max_line_len number := 0;
  cur_line_len number := 0;
  
  function llcheck(str in varchar2) return varchar2 as
  begin
    --dbms_output.put_line(cur_line_len || ' : '|| str);
    if(max_line_len > 0 and length(str)+cur_line_len > max_line_len) then
      cur_line_len := length(str);
      return newline_char || str;
    else 
      cur_line_len := cur_line_len + length(str);
      return str;
    end if;
  end llcheck;  

  function escapeString(str varchar2) return varchar2 as
    sb varchar2(32767) := '';
    buf varchar2(40);
    num number;
  begin
    if(str is null) then return '""'; end if;
    for i in 1 .. length(str) loop
      buf := substr(str, i, 1);
      --backspace b = U+0008
      --formfeed  f = U+000C
      --newline   n = U+000A
      --carret    r = U+000D
      --tabulator t = U+0009
      case buf
      when chr( 8) then buf := '\b';
      when chr( 9) then buf := '\t';
      when chr(10) then buf := '\n';
      when chr(13) then buf := '\f';
      when chr(14) then buf := '\r';
      when chr(34) then buf := '\"';
      when chr(47) then if(escape_solidus) then buf := '\/'; end if;
      when chr(92) then buf := '\\';
      else 
        if(ascii(buf) < 32) then
          buf := '\u'||replace(substr(to_char(ascii(buf), 'XXXX'),2,4), ' ', '0');
        elsif (ascii_output) then 
          buf := replace(asciistr(buf), '\', '\u');
        end if;
      end case;      
      
      sb := sb || buf;
    end loop;
  
    return '"'||sb||'"';
  end escapeString;

  function newline(spaces boolean) return varchar2 as
  begin
    cur_line_len := 0;
    if(spaces) then return newline_char; else return ''; end if;
  end;

/*  function get_schema return varchar2 as
  begin
    return sys_context('userenv', 'current_schema');
  end;  
*/  
  function tab(indent number, spaces boolean) return varchar2 as
    i varchar(200) := '';
  begin
    if(not spaces) then return ''; end if;
    for x in 1 .. indent loop i := i || indent_string; end loop;
    return i;
  end;
  
  function getCommaSep(spaces boolean) return varchar2 as
  begin
    if(spaces) then return ', '; else return ','; end if;
  end;

  function getMemName(mem json_value, spaces boolean) return varchar2 as
  begin
    if(spaces) then
      return llcheck(escapeString(mem.mapname)) || llcheck(' : ');
    else 
      return llcheck(escapeString(mem.mapname)) || llcheck(':');
    end if;
  end;

/* Clob method start here */
  procedure add_to_clob(buf_lob in out nocopy clob, buf_str in out nocopy varchar2, str varchar2) as
  begin
    if(length(str) > 32767 - length(buf_str)) then
      dbms_lob.append(buf_lob, buf_str);
      buf_str := str;
    else
      buf_str := buf_str || str;
    end if;  
  end add_to_clob;

  procedure flush_clob(buf_lob in out nocopy clob, buf_str in out nocopy varchar2) as
  begin
    dbms_lob.append(buf_lob, buf_str);
  end flush_clob;

  procedure ppObj(obj json, indent number, buf in out nocopy clob, spaces boolean, buf_str in out nocopy varchar2);

  procedure ppEA(input json_list, indent number, buf in out nocopy clob, spaces boolean, buf_str in out nocopy varchar2) as
    elem json_value; 
    arr json_value_array := input.list_data;
    numbuf varchar2(4000);
  begin
    for y in 1 .. arr.count loop
      elem := arr(y);
      if(elem is not null) then
      case elem.get_type
        when 'number' then 
          numbuf := '';
          if (elem.get_number < 1 and elem.get_number > 0) then numbuf := '0'; end if;
          if (elem.get_number < 0 and elem.get_number > -1) then 
            numbuf := '-0'; 
            numbuf := numbuf || substr(to_char(elem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,'''),2);
          else
            numbuf := numbuf || to_char(elem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
          end if;
          add_to_clob(buf, buf_str, llcheck(numbuf));
        when 'string' then 
          if(elem.num = 1) then 
            add_to_clob(buf, buf_str, llcheck(escapeString(elem.get_string)));
          else 
            add_to_clob(buf, buf_str, llcheck(elem.get_string));
          end if;
        when 'bool' then
          if(elem.get_bool) then 
            add_to_clob(buf, buf_str, llcheck('true'));
          else
            add_to_clob(buf, buf_str, llcheck('false'));
          end if;
        when 'null' then
          add_to_clob(buf, buf_str, llcheck('null'));
        when 'array' then
          add_to_clob(buf, buf_str, llcheck('['));
          ppEA(json_list(elem), indent, buf, spaces, buf_str);
          add_to_clob(buf, buf_str, llcheck(']'));
        when 'object' then
          ppObj(json(elem), indent, buf, spaces, buf_str);
        else add_to_clob(buf, buf_str, llcheck(elem.get_type));
      end case;
      end if;
      if(y != arr.count) then add_to_clob(buf, buf_str, llcheck(getCommaSep(spaces))); end if;
    end loop;
  end ppEA;

  procedure ppMem(mem json_value, indent number, buf in out nocopy clob, spaces boolean, buf_str in out nocopy varchar2) as
    numbuf varchar2(4000);
  begin
    add_to_clob(buf, buf_str, llcheck(tab(indent, spaces)) || llcheck(getMemName(mem, spaces)));
    case mem.get_type
      when 'number' then 
        if (mem.get_number < 1 and mem.get_number > 0) then numbuf := '0'; end if;
        if (mem.get_number < 0 and mem.get_number > -1) then 
          numbuf := '-0'; 
          numbuf := numbuf || substr(to_char(mem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,'''),2);
        else
          numbuf := numbuf || to_char(mem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
        end if;
        add_to_clob(buf, buf_str, llcheck(numbuf));
      when 'string' then 
        if(mem.num = 1) then 
          add_to_clob(buf, buf_str, llcheck(escapeString(mem.get_string)));
        else 
          add_to_clob(buf, buf_str, llcheck(mem.get_string));
        end if;
      when 'bool' then
        if(mem.get_bool) then 
          add_to_clob(buf, buf_str, llcheck('true'));
        else
          add_to_clob(buf, buf_str, llcheck('false'));
        end if;
      when 'null' then
        add_to_clob(buf, buf_str, llcheck('null'));
      when 'array' then
        add_to_clob(buf, buf_str, llcheck('['));
        ppEA(json_list(mem), indent, buf, spaces, buf_str);
        add_to_clob(buf, buf_str, llcheck(']'));
      when 'object' then
        ppObj(json(mem), indent, buf, spaces, buf_str);
      else add_to_clob(buf, buf_str, llcheck(mem.get_type));
    end case;
  end ppMem;

  procedure ppObj(obj json, indent number, buf in out nocopy clob, spaces boolean, buf_str in out nocopy varchar2) as
  begin
    add_to_clob(buf, buf_str, llcheck('{') || newline(spaces));
    for m in 1 .. obj.json_data.count loop
      ppMem(obj.json_data(m), indent+1, buf, spaces, buf_str);
      if(m != obj.json_data.count) then 
        add_to_clob(buf, buf_str, llcheck(',') || newline(spaces));
      else 
        add_to_clob(buf, buf_str, newline(spaces)); 
      end if;
    end loop;
    add_to_clob(buf, buf_str, llcheck(tab(indent, spaces)) || llcheck('}')); -- || chr(13);
  end ppObj;
  
  procedure pretty_print(obj json, spaces boolean default true, buf in out nocopy clob, line_length number default 0) as 
    buf_str varchar2(32767);
  begin
    max_line_len := line_length;
    cur_line_len := 0;
    ppObj(obj, 0, buf, spaces, buf_str);  
    flush_clob(buf, buf_str);
  end;

  procedure pretty_print_list(obj json_list, spaces boolean default true, buf in out nocopy clob, line_length number default 0) as 
    buf_str varchar2(32767);
  begin
    max_line_len := line_length;
    cur_line_len := 0;
    add_to_clob(buf, buf_str, llcheck('['));
    ppEA(obj, 0, buf, spaces, buf_str);  
    add_to_clob(buf, buf_str, llcheck(']'));
    flush_clob(buf, buf_str);
  end;

  procedure pretty_print_any(json_part json_value, spaces boolean default true, buf in out nocopy clob, line_length number default 0) as
    buf_str varchar2(32767) := '';
    numbuf varchar2(4000);
  begin
    case json_part.get_type
      when 'number' then 
        if (json_part.get_number < 1 and json_part.get_number > 0) then numbuf := '0'; end if;
        if (json_part.get_number < 0 and json_part.get_number > -1) then 
          numbuf := '-0'; 
          numbuf := numbuf || substr(to_char(json_part.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,'''),2);
        else
          numbuf := numbuf || to_char(json_part.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
        end if;
        add_to_clob(buf, buf_str, numbuf);
      when 'string' then 
        if(json_part.num = 1) then 
          add_to_clob(buf, buf_str, escapeString(json_part.get_string));
        else 
          add_to_clob(buf, buf_str, json_part.get_string);
        end if;
      when 'bool' then
	      if(json_part.get_bool) then
          add_to_clob(buf, buf_str, 'true');
        else
          add_to_clob(buf, buf_str, 'false');
        end if;
      when 'null' then
        add_to_clob(buf, buf_str, 'null');
      when 'array' then
        pretty_print_list(json_list(json_part), spaces, buf, line_length);
        return;
      when 'object' then
        pretty_print(json(json_part), spaces, buf, line_length);
        return;
      else add_to_clob(buf, buf_str, 'unknown type:'|| json_part.get_type);
    end case;
    flush_clob(buf, buf_str);
  end;

/* Clob method end here */

/* Varchar2 method start here */

  procedure ppObj(obj json, indent number, buf in out nocopy varchar2, spaces boolean);

  procedure ppEA(input json_list, indent number, buf in out varchar2, spaces boolean) as
    elem json_value; 
    arr json_value_array := input.list_data;
    str varchar2(400);
  begin
    for y in 1 .. arr.count loop
      elem := arr(y);
      if(elem is not null) then
      case elem.get_type
        when 'number' then 
          str := '';
          if (elem.get_number < 1 and elem.get_number > 0) then str := '0'; end if;
          if (elem.get_number < 0 and elem.get_number > -1) then 
            str := '-0' || substr(to_char(elem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,'''),2);
          else
            str := str || to_char(elem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
          end if;
          buf := buf || llcheck(str);
        when 'string' then 
          if(elem.num = 1) then 
            buf := buf || llcheck(escapeString(elem.get_string));
          else 
            buf := buf || llcheck(elem.get_string);
          end if;
        when 'bool' then
          if(elem.get_bool) then           
            buf := buf || llcheck('true');
          else
            buf := buf || llcheck('false');
          end if;
        when 'null' then
          buf := buf || llcheck('null');
        when 'array' then
          buf := buf || llcheck('[');
          ppEA(json_list(elem), indent, buf, spaces);
          buf := buf || llcheck(']');
        when 'object' then
          ppObj(json(elem), indent, buf, spaces);
        else buf := buf || llcheck(elem.get_type); /* should never happen */
      end case;
      end if;
      if(y != arr.count) then buf := buf || llcheck(getCommaSep(spaces)); end if;
    end loop;
  end ppEA;

  procedure ppMem(mem json_value, indent number, buf in out nocopy varchar2, spaces boolean) as
    str varchar2(400) := '';
  begin
    buf := buf || llcheck(tab(indent, spaces)) || getMemName(mem, spaces);
    case mem.get_type
      when 'number' then 
        if (mem.get_number < 1 and mem.get_number > 0) then str := '0'; end if;
        if (mem.get_number < 0 and mem.get_number > -1) then 
          str := '-0' || substr(to_char(mem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,'''),2);
        else
          str := str || to_char(mem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
        end if;
        buf := buf || llcheck(str);
      when 'string' then 
        if(mem.num = 1) then 
          buf := buf || llcheck(escapeString(mem.get_string));
        else 
          buf := buf || llcheck(mem.get_string);
        end if;
      when 'bool' then
        if(mem.get_bool) then 
          buf := buf || llcheck('true');
        else 
          buf := buf || llcheck('false');
        end if;
      when 'null' then
        buf := buf || llcheck('null');
      when 'array' then
        buf := buf || llcheck('[');
        ppEA(json_list(mem), indent, buf, spaces);
        buf := buf || llcheck(']');
      when 'object' then
        ppObj(json(mem), indent, buf, spaces);
      else buf := buf || llcheck(mem.get_type); /* should never happen */
    end case;
  end ppMem;
  
  procedure ppObj(obj json, indent number, buf in out nocopy varchar2, spaces boolean) as
  begin
    buf := buf || llcheck('{') || newline(spaces);
    for m in 1 .. obj.json_data.count loop
      ppMem(obj.json_data(m), indent+1, buf, spaces);
      if(m != obj.json_data.count) then buf := buf || llcheck(',') || newline(spaces);
      else buf := buf || newline(spaces); end if;
    end loop;
    buf := buf || llcheck(tab(indent, spaces)) || llcheck('}'); -- || chr(13);
  end ppObj;
  
  function pretty_print(obj json, spaces boolean default true, line_length number default 0) return varchar2 as
    buf varchar2(32767) := '';
  begin
    max_line_len := line_length;
    cur_line_len := 0;
    ppObj(obj, 0, buf, spaces);
    return buf;
  end pretty_print;

  function pretty_print_list(obj json_list, spaces boolean default true, line_length number default 0) return varchar2 as
    buf varchar2(32767);
  begin
    max_line_len := line_length;
    cur_line_len := 0;
    buf := llcheck('[');
    ppEA(obj, 0, buf, spaces);
    buf := buf || llcheck(']');
    return buf;
  end;

  function pretty_print_any(json_part json_value, spaces boolean default true, line_length number default 0) return varchar2 as
    buf varchar2(32767) := '';    
  begin
    case json_part.get_type
      when 'number' then 
        if (json_part.get_number() < 1 and json_part.get_number() > 0) then buf := buf || '0'; end if;
        if (json_part.get_number() < 0 and json_part.get_number() > -1) then 
          buf := buf || '-0'; 
          buf := buf || substr(to_char(json_part.get_number(), 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,'''),2);
        else
          buf := buf || to_char(json_part.get_number(), 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
        end if;
      when 'string' then 
        if(json_part.num = 1) then 
          buf := buf || escapeString(json_part.get_string);
        else 
          buf := buf || json_part.get_string;
        end if;
      when 'bool' then
      	if(json_part.get_bool) then buf := 'true'; else buf := 'false'; end if;
      when 'null' then
        buf := 'null';
      when 'array' then
        buf := pretty_print_list(json_list(json_part), spaces, line_length);
      when 'object' then
        buf := pretty_print(json(json_part), spaces, line_length);
      else buf := 'weird error: '|| json_part.get_type;
    end case;
    return buf;
  end;
  
  procedure dbms_output_clob(my_clob clob, delim varchar2, jsonp varchar2 default null) as 
    prev number := 1;
    indx number := 1;
    size_of_nl number := length(delim);
  begin
    if(jsonp is not null) then dbms_output.put_line(jsonp||'('); end if;
    while (indx != 0) loop
      indx := dbms_lob.instr(my_clob, delim, prev+1);
      --dbms_output.put_line(prev || ' to ' || indx);
      if(indx = 0) then 
        dbms_output.put_line(dbms_lob.substr(my_clob, dbms_lob.getlength(my_clob)-prev+size_of_nl, prev));
      else 
        dbms_output.put_line(dbms_lob.substr(my_clob, indx-prev, prev));
      end if;
      prev := indx+size_of_nl;
    end loop;
    if(jsonp is not null) then dbms_output.put_line(')'); end if;
  end;
  
  procedure htp_output_clob(my_clob clob, jsonp varchar2 default null) as 
    amount number := 8192;
    pos number := 1;
    len number;
  begin
    if(jsonp is not null) then htp.prn(jsonp||'('); end if;
    len := dbms_lob.getlength(my_clob);
    while(pos < len) loop
      htp.prn(dbms_lob.substr(my_clob, amount, pos)); 
      --dbms_output.put_line(dbms_lob.substr(my_clob, amount, pos)); 
      pos := pos + amount;
    end loop;
    if(jsonp is not null) then htp.prn(')'); end if;
  end;

end json_printer;
/