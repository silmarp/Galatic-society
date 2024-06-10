DROP PACKAGE PG_Users;

/* Package Users */
CREATE OR REPLACE PACKAGE PG_Users AS
    e_all_registered EXCEPTION;
    
    PROCEDURE register_users;
    PROCEDURE set_user_id (p_user_id USERS.ID_USER%TYPE);
    FUNCTION get_user_id RETURN USERS.ID_USER%TYPE;
END PG_Users;
/

CREATE OR REPLACE PACKAGE BODY PG_Users AS
    g_user_id USERS.ID_USER%TYPE;

    PROCEDURE register_users AS 
        CURSOR c_lideres IS
            SELECT L.CPI
            FROM LIDER L
            WHERE L.CPI NOT IN (SELECT U.ID_LIDER FROM USERS U);
        TYPE t_tab_lideres IS TABLE OF Lider.CPI%TYPE INDEX BY PLS_INTEGER;
        v_lideres t_tab_lideres;
        v_lote CONSTANT PLS_INTEGER := 1000;
        v_count NUMBER := 0;
        v_lider Lider.CPI%TYPE;
        v_user Users.Id_user%TYPE;
        
        BEGIN
            OPEN c_lideres;
            LOOP
                FETCH c_lideres BULK COLLECT INTO v_lideres LIMIT v_lote;
                EXIT WHEN v_lideres.COUNT = 0;    
                FOR i IN 1 .. v_lideres.COUNT LOOP
                    v_lider := v_lideres(i);
                    v_user := 'U_' || v_lider;               
                    INSERT INTO USERS (ID_USER, PASSWORD, ID_LIDER) VALUES(v_user, v_user, v_lider);
                    COMMIT;
                    v_count := v_count + 1;
                END LOOP;
            END LOOP;
            CLOSE c_lideres;
            IF v_count = 0 THEN RAISE e_all_registered;
            END IF;
            
        EXCEPTION
            WHEN e_all_registered THEN 
                RAISE_APPLICATION_ERROR(-20001, 'Todos os lideres ja estao cadastrados');
    END register_users;
    
    PROCEDURE set_user_id (p_user_id USERS.ID_USER%TYPE) IS
        BEGIN
            g_user_id := p_user_id;
    END set_user_id;
    
    FUNCTION get_user_id RETURN USERS.ID_USER%TYPE IS
        BEGIN
            RETURN g_user_id;
    END get_user_id;
END PG_Users;