DROP PROCEDURE TEST_SPEED;

CREATE OR REPLACE PROCEDURE test_speed AS
  v_number  NUMBER;
BEGIN
  FOR i IN 1 .. 10000000 LOOP
    v_number := i / 1000;
  END LOOP;
END;
/