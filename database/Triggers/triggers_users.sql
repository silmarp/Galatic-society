DROP TRIGGER TG_Users_Password;
DROP TRIGGER TG_Users_Insert;

/* Trigger to encrypt user password */
CREATE OR REPLACE TRIGGER TG_Users_Password
BEFORE INSERT ON Users
FOR EACH ROW
    BEGIN 
        :new.password := rawtohex(dbms_obfuscation_toolkit.md5(input => utl_raw.cast_to_raw(:new.password)));
END;
/

/* Trigger to insert user when insert on Lider table */
CREATE OR REPLACE TRIGGER TG_Users_Insert
AFTER INSERT ON Lider
FOR EACH ROW
    DECLARE
        v_lider Lider.CPI%TYPE;
        v_user Users.Id_user%TYPE;
    BEGIN
        v_lider := :new.cpi;
        v_user := 'U_' || v_lider;               
        INSERT INTO USERS (ID_USER, PASSWORD, ID_LIDER) VALUES (v_user, v_user, v_lider);
    
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, 'Erro ao registrar usuario' || CHR(10) || SQLERRM);
END;