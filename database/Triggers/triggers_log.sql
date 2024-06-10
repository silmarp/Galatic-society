DROP TRIGGER TG_Log_Faccao;
DROP TRIGGER TG_Log_Nacao;
DROP TRIGGER TG_Log_Estrela;
DROP TRIGGER TG_Log_Planeta;
DROP TRIGGER TG_Log_Sistema;

/* Trigger to register log on Faccao */
CREATE OR REPLACE TRIGGER TG_Log_Faccao
    AFTER INSERT OR UPDATE OR DELETE ON Faccao
    FOR EACH ROW
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_table user_tables.table_name%TYPE;
        v_id_log VARCHAR(20);
        v_user USERS.ID_USER%TYPE;
        v_message LOG_TABLE.MESSAGE%TYPE;
    BEGIN
        v_table := 'Faccao';
        v_id_log := TO_CHAR(SEQ_Log.NEXTVAL, 'FM0000000000');
        v_user := PG_Users.get_user_id;
        IF INSERTING THEN v_message := 'Insert on ' || v_table;
        ELSIF UPDATING THEN v_message := 'Update on ' || v_table;
        ELSIF DELETING THEN v_message := 'Delete on ' || v_table;
        END IF;
        
        INSERT INTO LOG_TABLE (ID_LOG, USERID, TIMESTAMP, MESSAGE)
            VALUES (v_id_log, v_user, SYSTIMESTAMP, v_message);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'Erro no registro de log na tabela ' || v_table || CHR(10) || SQLERRM);
END TG_Log_Faccao;
/

/* Trigger to register log on Nacao */
CREATE OR REPLACE TRIGGER TG_Log_Nacao
    AFTER INSERT OR UPDATE OR DELETE ON Nacao
    FOR EACH ROW
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_table user_tables.table_name%TYPE;
        v_id_log VARCHAR(20);
        v_user USERS.ID_USER%TYPE;
        v_message LOG_TABLE.MESSAGE%TYPE;
    BEGIN
        v_table := 'Nacao';
        v_id_log := TO_CHAR(SEQ_Log.NEXTVAL, 'FM0000000000');
        v_user := PG_Users.get_user_id;
        IF INSERTING THEN v_message := 'Insert on ' || v_table;
        ELSIF UPDATING THEN v_message := 'Update on ' || v_table;
        ELSIF DELETING THEN v_message := 'Delete on ' || v_table;
        END IF;
        
        INSERT INTO LOG_TABLE (ID_LOG, USERID, TIMESTAMP, MESSAGE)
            VALUES (v_id_log, v_user, SYSTIMESTAMP, v_message);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'Erro no registro de log na tabela ' || v_table || CHR(10) || SQLERRM);
END TG_Log_Nacao;
/

/* Trigger to register log on Estrela */
CREATE OR REPLACE TRIGGER TG_Log_Estrela
    AFTER INSERT OR UPDATE OR DELETE ON Estrela
    FOR EACH ROW
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_table user_tables.table_name%TYPE;
        v_id_log VARCHAR(20);
        v_user USERS.ID_USER%TYPE;
        v_message LOG_TABLE.MESSAGE%TYPE;
    BEGIN
        v_table := 'Estrela';
        v_id_log := TO_CHAR(SEQ_Log.NEXTVAL, 'FM0000000000');
        v_user := PG_Users.get_user_id;
        IF INSERTING THEN v_message := 'Insert on ' || v_table;
        ELSIF UPDATING THEN v_message := 'Update on ' || v_table;
        ELSIF DELETING THEN v_message := 'Delete on ' || v_table;
        END IF;
        
        INSERT INTO LOG_TABLE (ID_LOG, USERID, TIMESTAMP, MESSAGE)
            VALUES (v_id_log, v_user, SYSTIMESTAMP, v_message);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'Erro no registro de log na tabela ' || v_table || CHR(10) || SQLERRM);
END TG_Log_Estrela;
/

/* Trigger to register log on Planeta */
CREATE OR REPLACE TRIGGER TG_Log_Planeta
    AFTER INSERT OR UPDATE OR DELETE ON Planeta
    FOR EACH ROW
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_table user_tables.table_name%TYPE;
        v_id_log VARCHAR(20);
        v_user USERS.ID_USER%TYPE;
        v_message LOG_TABLE.MESSAGE%TYPE;
    BEGIN
        v_table := 'Planeta';
        v_id_log := TO_CHAR(SEQ_Log.NEXTVAL, 'FM0000000000');
        v_user := PG_Users.get_user_id;
        IF INSERTING THEN v_message := 'Insert on ' || v_table;
        ELSIF UPDATING THEN v_message := 'Update on ' || v_table;
        ELSIF DELETING THEN v_message := 'Delete on ' || v_table;
        END IF;
        
        INSERT INTO LOG_TABLE (ID_LOG, USERID, TIMESTAMP, MESSAGE)
            VALUES (v_id_log, v_user, SYSTIMESTAMP, v_message);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'Erro no registro de log na tabela ' || v_table || CHR(10) || SQLERRM);
END TG_Log_Planeta;
/

/* Trigger to register log on Sistema */
CREATE OR REPLACE TRIGGER TG_Log_Sistema
    AFTER INSERT OR UPDATE OR DELETE ON Sistema
    FOR EACH ROW
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_table user_tables.table_name%TYPE;
        v_id_log VARCHAR(20);
        v_user USERS.ID_USER%TYPE;
        v_message LOG_TABLE.MESSAGE%TYPE;
    BEGIN
        v_table := 'Sistema';
        v_id_log := TO_CHAR(SEQ_Log.NEXTVAL, 'FM0000000000');
        v_user := PG_Users.get_user_id;
        IF INSERTING THEN v_message := 'Insert on ' || v_table;
        ELSIF UPDATING THEN v_message := 'Update on ' || v_table;
        ELSIF DELETING THEN v_message := 'Delete on ' || v_table;
        END IF;
        
        INSERT INTO LOG_TABLE (ID_LOG, USERID, TIMESTAMP, MESSAGE)
            VALUES (v_id_log, v_user, SYSTIMESTAMP, v_message);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'Erro no registro de log na tabela ' || v_table || CHR(10) || SQLERRM);
END TG_Log_Sistema;
/