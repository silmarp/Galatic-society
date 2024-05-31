/* Trigger to encrypt user password */
CREATE OR REPLACE TRIGGER TG_Users_Password
BEFORE INSERT ON Users
FOR EACH ROW
BEGIN 
    :new.password := rawtohex(dbms_obfuscation_toolkit.md5(input => utl_raw.cast_to_raw(:new.password)));
END;
-- DROP TRIGGER TG_Users_Password;