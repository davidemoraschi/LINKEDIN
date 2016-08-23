DROP PACKAGE BODY PARSE;

CREATE OR REPLACE PACKAGE BODY parse
IS
   FUNCTION string_to_list (string_in IN VARCHAR2, delim_in IN VARCHAR2)
      RETURN items_tt
   IS
      c_end_of_list   CONSTANT PLS_INTEGER := -99;
      l_item          maxvarchar2_t;
      l_startloc      PLS_INTEGER := 1;
      items_out       items_tt;

      PROCEDURE add_item (item_in IN VARCHAR2)
      IS
      BEGIN
         IF item_in = delim_in
         THEN
            /* We don't put delimiters into the collection. */
            NULL;
         ELSE
            items_out (items_out.COUNT + 1) := item_in;
         END IF;
      END;

      PROCEDURE get_next_item (string_in         IN     VARCHAR2
                             , start_location_io IN OUT PLS_INTEGER
                             , item_out             OUT VARCHAR2
                              )
      IS
         l_loc   PLS_INTEGER;
      BEGIN
         l_loc := INSTR (string_in, delim_in, start_location_io);

         IF l_loc = start_location_io
         THEN
            /* A null item (two consecutive delimiters) */
            item_out := NULL;
         ELSIF l_loc = 0
         THEN
            /* We are at the last item in the list. */
            item_out := SUBSTR (string_in, start_location_io);
         ELSE
            /* Extract the element between the two positions. */
            item_out :=
               SUBSTR (string_in
                     , start_location_io
                     , l_loc - start_location_io
                      );
         END IF;

         IF l_loc = 0
         THEN
            /* If the delimiter was not found, send back indication
               that we are at the end of the list. */

            start_location_io := c_end_of_list;
         ELSE
            /* Move the starting point for the INSTR search forward. */
            start_location_io := l_loc + 1;
         END IF;
      END get_next_item;
   BEGIN
      IF string_in IS NULL OR delim_in IS NULL
      THEN
         /* Nothing to do except pass back the empty collection. */
         NULL;
      ELSE
         LOOP
            get_next_item (string_in, l_startloc, l_item);
            add_item (l_item);
            EXIT WHEN l_startloc = c_end_of_list;
         END LOOP;
      END IF;

      RETURN items_out;
   END string_to_list;

   FUNCTION string_to_list (string_in      IN VARCHAR2
                          , outer_delim_in IN VARCHAR2
                          , inner_delim_in IN VARCHAR2
                           )
      RETURN nested_items_tt
   IS
      l_elements   items_tt;
      l_return     nested_items_tt;
   BEGIN
      /* Separate out the different lists. */
      l_elements := string_to_list (string_in, outer_delim_in);

      /* For each list, parse out the separate items
         and add them to the end of the list of items
         for that list. */   
      FOR indx IN 1 .. l_elements.COUNT
      LOOP
         l_return (l_return.COUNT + 1) :=
            string_to_list (l_elements (indx), inner_delim_in);
      END LOOP;

      RETURN l_return;
   END string_to_list;

   FUNCTION string_to_list (string_in      IN VARCHAR2
                          , outer_delim_in IN VARCHAR2
                          , name_delim_in  IN VARCHAR2
                          , inner_delim_in IN VARCHAR2
                           )
      RETURN named_nested_items_tt
   IS
      c_name_position constant pls_integer := 1;
      c_items_position constant pls_integer := 2;
      l_elements          items_tt;
      l_name_and_values   items_tt;
      l_return            named_nested_items_tt;
   BEGIN
      /* Separate out the different lists. */
      l_elements := string_to_list (string_in, outer_delim_in);

      FOR indx IN 1 .. l_elements.COUNT
      LOOP
         /* Extract the name and the list of items that go with 
            the name. This collection always has just two elements:
              index 1 - the name
              index 2 - the list of values
         */
         l_name_and_values :=
            string_to_list (l_elements (indx), name_delim_in);
         /*
         Use the name as the index value for this list.
         */
         l_return (l_name_and_values (c_name_position)) :=
            string_to_list (l_name_and_values (c_items_position), inner_delim_in);
      END LOOP;

      RETURN l_return;
   END string_to_list;

   PROCEDURE display_list (string_in IN VARCHAR2
                         , delim_in  IN VARCHAR2:= ','
                          )
   IS
      l_items   items_tt;
   BEGIN
      DBMS_OUTPUT.put_line (
         'Parse "' || string_in || '" using "' || delim_in || '"'
      );

      l_items := string_to_list (string_in, delim_in);

      FOR indx IN 1 .. l_items.COUNT
      LOOP
         DBMS_OUTPUT.put_line ('> ' || indx || ' = ' || l_items (indx));
      END LOOP;
   END display_list;

   PROCEDURE display_list (string_in      IN VARCHAR2
                         , outer_delim_in IN VARCHAR2
                         , inner_delim_in IN VARCHAR2
                          )
   IS
      l_items   nested_items_tt;
   BEGIN
      DBMS_OUTPUT.put_line(   'Parse "'
                           || string_in
                           || '" using "'
                           || outer_delim_in
                           || '-'
                           || inner_delim_in
                           || '"');
      l_items := string_to_list (string_in, outer_delim_in, inner_delim_in);


      FOR outer_index IN 1 .. l_items.COUNT
      LOOP
         DBMS_OUTPUT.put_line(   'List '
                              || outer_index
                              || ' contains '
                              || l_items (outer_index).COUNT
                              || ' elements');

         FOR inner_index IN 1 .. l_items (outer_index).COUNT
         LOOP
            DBMS_OUTPUT.put_line(   '> Value '
                                 || inner_index
                                 || ' = '
                                 || l_items (outer_index) (inner_index));
         END LOOP;
      END LOOP;
   END display_list;

   PROCEDURE display_list (string_in      IN VARCHAR2
                         , outer_delim_in IN VARCHAR2
                         , name_delim_in  IN VARCHAR2
                         , inner_delim_in IN VARCHAR2
                          )
   IS
      l_items   named_nested_items_tt;
      l_index   maxvarchar2_t;
   BEGIN
      DBMS_OUTPUT.put_line(   'Parse "'
                           || string_in
                           || '" using "'
                           || outer_delim_in
                           || '-'
                           || name_delim_in
                           || '-'
                           || inner_delim_in
                           || '"');
      l_items :=
         string_to_list (string_in
                       , outer_delim_in
                       , name_delim_in
                       , inner_delim_in
                        );

      l_index := l_items.FIRST;

      WHILE (l_index IS NOT NULL)
      LOOP
         DBMS_OUTPUT.put_line(   'List "'
                              || l_index
                              || '" contains '
                              || l_items (l_index).COUNT
                              || ' elements');

         FOR inner_index IN 1 .. l_items (l_index).COUNT
         LOOP
            DBMS_OUTPUT.put_line(   '> Value '
                                 || inner_index
                                 || ' = '
                                 || l_items (l_index) (inner_index));
         END LOOP;

         l_index := l_items.NEXT (l_index);
      END LOOP;
   END display_list;

   PROCEDURE show_variations
   IS
      PROCEDURE show_header (title_in IN VARCHAR2)
      IS
      BEGIN
         DBMS_OUTPUT.put_line (RPAD ('=', 60, '='));
         DBMS_OUTPUT.put_line (title_in);
         DBMS_OUTPUT.put_line (RPAD ('=', 60, '='));
      END show_header;
   BEGIN
      show_header ('Single Delimiter Lists');
      display_list ('a,b,c');
      display_list ('a;b;c', ';');
      display_list ('a,,b,c');
      display_list (',,b,c,,');

      show_header ('Nested Lists');
      display_list ('a,b,c,d|1,2,3|x,y,z', '|', ',');

      show_header ('Named, Nested Lists');
      display_list ('letters:a,b,c,d|numbers:1,2,3|names:steven,george'
                  , '|'
                  , ':'
                  , ','
                   );
   END;

   FUNCTION nested_eq (list1_in    IN items_tt
                     , list2_in    IN items_tt
                     , nulls_eq_in IN BOOLEAN
                      )
      RETURN BOOLEAN
   IS
      l_return   BOOLEAN := list1_in.COUNT = list2_in.COUNT;
      l_index    PLS_INTEGER := 1;
   BEGIN
      WHILE (l_return AND l_index IS NOT NULL)
      LOOP
         l_return := list1_in (l_index) = list2_in (l_index);
         l_index := list1_in.NEXT (l_index);
      END LOOP;

      RETURN l_return;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN FALSE;
   END nested_eq;
END;
/
