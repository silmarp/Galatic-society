DROP PACKAGE PG_Cientista;

/* Package Cientista */
CREATE OR REPLACE PACKAGE PG_Cientista AS
    e_not_cientista EXCEPTION;

    PROCEDURE criar_estrela (
        p_user USERS.ID_User%TYPE,
        p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE,
        p_nome IN ESTRELA.NOME%TYPE,
        p_classificacao IN ESTRELA.CLASSIFICACAO%TYPE,
        p_massa IN ESTRELA.MASSA%TYPE,
        p_x IN ESTRELA.X%TYPE,
        p_y IN ESTRELA.Y%TYPE,
        p_z IN ESTRELA.Z%TYPE
    );

    PROCEDURE atualizar_estrela (
        p_user USERS.ID_User%TYPE,
        p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE,
        p_nome IN ESTRELA.NOME%TYPE,
        p_classificacao IN ESTRELA.CLASSIFICACAO%TYPE,
        p_massa IN ESTRELA.MASSA%TYPE,
        p_x IN ESTRELA.X%TYPE,
        p_y IN ESTRELA.Y%TYPE,
        p_z IN ESTRELA.Z%TYPE
    );

    FUNCTION ler_estrela (
        p_user USERS.ID_User%TYPE,
        p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE
    ) RETURN ESTRELA%ROWTYPE;

    PROCEDURE deletar_estrela (
        p_user USERS.ID_User%TYPE,
        p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE
    );

    FUNCTION relatorio_estrelas (
        p_user USERS.ID_User%TYPE
    ) RETURN SYS_REFCURSOR;

    FUNCTION relatorio_planetas (
        p_user USERS.ID_User%TYPE
    ) RETURN SYS_REFCURSOR;

    FUNCTION relatorio_sistemas (
        p_user USERS.ID_User%TYPE
    ) RETURN SYS_REFCURSOR;
END PG_Cientista;
/

CREATE OR REPLACE PACKAGE BODY PG_Cientista AS
    PROCEDURE verificar_cientista (
        p_user USERS.ID_User%TYPE
    ) IS
        v_user LIDER%ROWTYPE;
        BEGIN
            v_user := PG_Users.get_user_info(p_user);
            IF v_user.CARGO != 'CIENTISTA' THEN
                RAISE e_not_cientista;
            END IF;
        EXCEPTION
            WHEN e_not_cientista THEN
                RAISE_APPLICATION_ERROR(-20141, 'Usuario nao e cientista');
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20145, 'Usuario nao encontrado');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20140, 'Erro em verificar_cientista ' || CHR(10) || SQLERRM);
    END verificar_cientista;

    PROCEDURE criar_estrela (
        p_user USERS.ID_User%TYPE,
        p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE,
        p_nome IN ESTRELA.NOME%TYPE,
        p_classificacao IN ESTRELA.CLASSIFICACAO%TYPE,
        p_massa IN ESTRELA.MASSA%TYPE,
        p_x IN ESTRELA.X%TYPE,
        p_y IN ESTRELA.Y%TYPE,
        p_z IN ESTRELA.Z%TYPE
    ) IS
        v_lider Lider%ROWTYPE;
        BEGIN
            v_lider := PG_Users.get_user_info(p_user);
            IF v_lider.cargo != 'CIENTISTA' THEN RAISE e_not_cientista; END IF;
    
            INSERT INTO ESTRELA (ID_ESTRELA, NOME, CLASSIFICACAO, MASSA, X, Y, Z)
                VALUES (p_id_estrela, p_nome, p_classificacao, p_massa, p_x, p_y, p_z);
            COMMIT;
            
        EXCEPTION
            WHEN e_not_cientista THEN
                RAISE_APPLICATION_ERROR(-20141, 'Usuario nao e cientista');
            WHEN DUP_VAL_ON_INDEX THEN
                RAISE_APPLICATION_ERROR(-20146, 'Estrela ja existe');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20140, 'Erro em criar_estrela ' || CHR(10) || SQLERRM);
    END criar_estrela;

    PROCEDURE atualizar_estrela (
        p_user USERS.ID_User%TYPE,
        p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE,
        p_nome IN ESTRELA.NOME%TYPE,
        p_classificacao IN ESTRELA.CLASSIFICACAO%TYPE,
        p_massa IN ESTRELA.MASSA%TYPE,
        p_x IN ESTRELA.X%TYPE,
        p_y IN ESTRELA.Y%TYPE,
        p_z IN ESTRELA.Z%TYPE
    ) IS
        v_lider Lider%ROWTYPE;
        BEGIN
            v_lider := PG_Users.get_user_info(p_user);
            IF v_lider.cargo != 'CIENTISTA' THEN RAISE e_not_cientista; END IF;

            UPDATE ESTRELA
            SET NOME = p_nome,
                CLASSIFICACAO = p_classificacao,
                MASSA = p_massa,
                X = p_x,
                Y = p_y,
                Z = p_z
            WHERE ID_ESTRELA = p_id_estrela;
            COMMIT;

        EXCEPTION
            WHEN e_not_cientista THEN
                RAISE_APPLICATION_ERROR(-20141, 'Usuario nao e cientista');
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20145, 'Estrela nao encontrada');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20140, 'Erro em atualizar_estrela ' || CHR(10) || SQLERRM);
    END atualizar_estrela;

    FUNCTION ler_estrela (
        p_user USERS.ID_User%TYPE,
        p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE
    ) RETURN ESTRELA%ROWTYPE
    IS
        v_estrela ESTRELA%ROWTYPE;
        BEGIN
            verificar_cientista(p_user);
    
            SELECT * INTO v_estrela FROM ESTRELA WHERE ID_ESTRELA = p_id_estrela;    
            RETURN v_estrela;
            
        EXCEPTION
            WHEN e_not_cientista THEN
                RAISE_APPLICATION_ERROR(-20141, 'Usuario nao e cientista');
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20145, 'Estrela nao encontrada');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20140, 'Erro em ler_estrela ' || CHR(10) || SQLERRM);
    END ler_estrela;

    PROCEDURE deletar_estrela (
        p_user USERS.ID_User%TYPE,
        p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE
    ) IS
        BEGIN
            verificar_cientista(p_user);
    
            DELETE FROM ESTRELA WHERE ID_ESTRELA = p_id_estrela;
            COMMIT;
            
        EXCEPTION
            WHEN e_not_cientista THEN
                RAISE_APPLICATION_ERROR(-20141, 'Usuario nao e cientista');
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20145, 'Estrela nao encontrada.');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20140, 'Erro em deletar_estrela ' || CHR(10) || SQLERRM);
    END deletar_estrela;

    FUNCTION relatorio_estrelas (
        p_user USERS.ID_User%TYPE
    ) RETURN SYS_REFCURSOR
    IS
        cur SYS_REFCURSOR;
        v_lider Lider%ROWTYPE;
        BEGIN
            v_lider := PG_Users.get_user_info(p_user);
            IF v_lider.cargo != 'CIENTISTA' THEN RAISE e_not_cientista; END IF;
    
            OPEN cur FOR
                SELECT * FROM ESTRELA;
            RETURN cur;
            
        EXCEPTION
            WHEN e_not_cientista THEN
                RAISE_APPLICATION_ERROR(-20141, 'Usuario nao e cientista');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20140, 'Erro em relatorio_estrelas ' || CHR(10) || SQLERRM);
    END relatorio_estrelas;

    FUNCTION relatorio_planetas (
        p_user USERS.ID_User%TYPE
    ) RETURN SYS_REFCURSOR
    IS
        cur SYS_REFCURSOR;
        v_lider Lider%ROWTYPE;
        BEGIN
            v_lider := PG_Users.get_user_info(p_user);
            IF v_lider.cargo != 'CIENTISTA' THEN RAISE e_not_cientista; END IF;

            OPEN cur FOR
                SELECT * FROM PLANETA;
            RETURN cur;
            
        EXCEPTION
            WHEN e_not_cientista THEN
                RAISE_APPLICATION_ERROR(-20141, 'Usuario nao e cientista');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20140, 'Erro em relatorio_planetas ' || CHR(10) || SQLERRM);
    END relatorio_planetas;

    FUNCTION relatorio_sistemas (
        p_user USERS.ID_User%TYPE
    ) RETURN SYS_REFCURSOR
    IS
        cur SYS_REFCURSOR;
        v_lider Lider%ROWTYPE;
        BEGIN
            v_lider := PG_Users.get_user_info(p_user);
            IF v_lider.cargo != 'CIENTISTA' THEN RAISE e_not_cientista; END IF;
    
            OPEN cur FOR
                SELECT S.NOME AS SISTEMA, E.ID_ESTRELA, E.NOME AS NOME_ESTRELA, E.CLASSIFICACAO, E.MASSA, E.X, E.Y, E.Z
                FROM SISTEMA S
                JOIN ORBITA_ESTRELA OE ON S.ESTRELA = OE.ORBITADA
                JOIN ESTRELA E ON OE.ORBITANTE = E.ID_ESTRELA;
            RETURN cur;
            
        EXCEPTION
            WHEN e_not_cientista THEN
                RAISE_APPLICATION_ERROR(-20141, 'Usuario nao e cientista');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20140, 'Erro em relatorio_sistemas ' || CHR(10) || SQLERRM);
    END relatorio_sistemas;
END PG_Cientista;
/