DROP PACKAGE PARSE;

CREATE OR REPLACE PACKAGE parse
/*
   Generalized delimited string parsing package

   Author: Steven Feuerstein, steven@stevenfeuerstein.com

   Latest version always available on PL/SQL Obsession: 

   www.ToadWorld.com/SF

   Click on "Trainings, Seminars and Presentations" and
   then download the demo.zip file.

   Modification History
      Date          Change
      10-APR-2009   Add support for nested list variations

   Notes:
     * This package does not validate correct use of delimiters.
       It assumes valid construction of lists.
     * Import the Q##PARSE.qut file into an installation of 
       Quest Code Tester 1.8.3 or higher in order to run
       the regression test for this package.

*/
IS
   SUBTYPE maxvarchar2_t IS VARCHAR2 (32767);

   /*
   Each of the collection types below correspond to (are returned by)
   one of the parse functions.

   items_tt - a simple list of strings
   nested_items_tt - a list of lists of strings
   named_nested_items_tt - a list of named lists of strings

   This last type also demonstrates the power and elegance of string-indexed
   collections. The name of the list of elements is the index value for
   the "outer" collection.
   */
   TYPE items_tt IS TABLE OF maxvarchar2_t
                       INDEX BY PLS_INTEGER;

   TYPE nested_items_tt IS TABLE OF items_tt
                              INDEX BY PLS_INTEGER;

   TYPE named_nested_items_tt IS TABLE OF items_tt
                                    INDEX BY maxvarchar2_t;

   /*
   Parse lists with a single delimiter.
   Example: a,b,c,d

   Here is an example of using this function:

   DECLARE
      l_list parse.items_tt;
   BEGIN
      l_list := parse.string_to_list ('a,b,c,d', ',');
   END;
   */
   FUNCTION string_to_list (string_in IN VARCHAR2, delim_in IN VARCHAR2)
      RETURN items_tt;

   /*
   Parse lists with nested delimiters.
   Example: a,b,c,d|1,2,3|x,y,z

   Here is an example of using this function:

   DECLARE
      l_list parse.nested_items_tt;
   BEGIN
      l_list := parse.string_to_list ('a,b,c,d|1,2,3,4', '|', ',');
   END;
   */
   FUNCTION string_to_list (string_in      IN VARCHAR2
                          , outer_delim_in IN VARCHAR2
                          , inner_delim_in IN VARCHAR2
                           )
      RETURN nested_items_tt;

   /*
   Parse named lists with nested delimiters.
   Example: letters:a,b,c,d|numbers:1,2,3|names:steven,george

   Here is an example of using this function:

   DECLARE
      l_list parse.named_nested_items_tt;
   BEGIN
   l_list := parse.string_to_list ('letters:a,b,c,d|numbers:1,2,3,4', '|', ':', ',');
   END;
   */
   FUNCTION string_to_list (string_in      IN VARCHAR2
                          , outer_delim_in IN VARCHAR2
                          , name_delim_in  IN VARCHAR2
                          , inner_delim_in IN VARCHAR2
                           )
      RETURN named_nested_items_tt;

   PROCEDURE display_list (string_in IN VARCHAR2
                         , delim_in  IN VARCHAR2:= ','
                          );

   PROCEDURE display_list (string_in      IN VARCHAR2
                         , outer_delim_in IN VARCHAR2
                         , inner_delim_in IN VARCHAR2
                          );

   PROCEDURE display_list (string_in      IN VARCHAR2
                         , outer_delim_in IN VARCHAR2
                         , name_delim_in  IN VARCHAR2
                         , inner_delim_in IN VARCHAR2
                          );

   PROCEDURE show_variations;

   /* Helper function for automated testing */
   FUNCTION nested_eq (list1_in    IN items_tt
                     , list2_in    IN items_tt
                     , nulls_eq_in IN BOOLEAN
                      )
      RETURN BOOLEAN;

END parse;
/
