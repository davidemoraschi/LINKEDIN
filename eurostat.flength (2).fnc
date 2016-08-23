DROP FUNCTION FLENGTH;

CREATE OR REPLACE FUNCTION          flength (location_in IN VARCHAR2, file_in IN VARCHAR2)
   RETURN PLS_INTEGER
IS
   TYPE fgetattr_t IS RECORD (fexists BOOLEAN, file_length PLS_INTEGER, block_size PLS_INTEGER);

   fgetattr_rec   fgetattr_t;
BEGIN
   UTL_FILE.fgetattr (location      => location_in,
                      filename      => file_in,
                      fexists       => fgetattr_rec.fexists,
                      file_length   => fgetattr_rec.file_length,
                      block_size    => fgetattr_rec.block_size);
   RETURN fgetattr_rec.file_length;
END flength;
/
