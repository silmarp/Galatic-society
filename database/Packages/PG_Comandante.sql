DROP PACKAGE PG_Comandante;

/* Package Comandante */
CREATE OR REPLACE PACKAGE PG_Comandante AS
    e_not_comandante EXCEPTION;
    e_atrib_notnull EXCEPTION;
    e_not_valid_federacao EXCEPTION;
    e_not_valid_planeta EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_atrib_notnull, -01400);
    PRAGMA EXCEPTION_INIT(e_not_valid_federacao, -02291);

    PROCEDURE include_federacao (
        p_user USERS.ID_User%TYPE,
        p_federacao_nome Federacao.Nome%TYPE DEFAULT NULL
    );
    
    PROCEDURE delete_federacao (
        p_user USERS.ID_User%TYPE
    );
    
    PROCEDURE create_federacao (
        p_user USERS.ID_User%TYPE,
        p_federacao_nome Federacao.Nome%TYPE,
        p_federacao_dt_fund Federacao.DATA_FUND%TYPE DEFAULT TO_DATE(SYSDATE, 'dd/mm/yyyy')
    );
    
    PROCEDURE insert_dominancia (
        p_user USERS.ID_User%TYPE,
        p_dominancia_planeta Dominancia.Planeta%TYPE,
        p_dominancia_data_ini Dominancia.Data_ini%TYPE DEFAULT TO_DATE(SYSDATE, 'dd/mm/yyyy'),
        p_dominancia_data_fim Dominancia.Data_fim%TYPE DEFAULT NULL
    );

    FUNCTION relatorio_dominancia_planetas (
        p_user USERS.ID_User%TYPE
    ) RETURN SYS_REFCURSOR;
    
    FUNCTION relatorio_planetas_dominados (
        p_user USERS.ID_User%TYPE
    ) RETURN SYS_REFCURSOR;
    
    FUNCTION relatorio_planetas_nao_dominados (
        p_user USERS.ID_User%TYPE
    ) RETURN SYS_REFCURSOR;
END PG_Comandante;
/

CREATE OR REPLACE PACKAGE BODY PG_Comandante AS    
    PROCEDURE include_federacao (
        p_user USERS.ID_User%TYPE,
        p_federacao_nome Federacao.Nome%TYPE
    ) IS
        v_lider Lider%ROWTYPE;
        BEGIN
            v_lider := PG_Users.get_user_info(p_user);
            IF v_lider.cargo != 'COMANDANTE' THEN RAISE e_not_comandante; END IF;
            PG_Users.set_user_id(p_user);

            UPDATE NACAO N SET FEDERACAO = p_federacao_nome WHERE N.NOME = v_lider.nacao;
            COMMIT;    

        EXCEPTION
            WHEN e_not_comandante THEN
                RAISE_APPLICATION_ERROR(-20111, 'Usuario nao e comandante');
            WHEN e_atrib_notnull THEN
                RAISE_APPLICATION_ERROR(-20112, 'Valor obrigatorio nao fornecido');
            WHEN VALUE_ERROR THEN
                RAISE_APPLICATION_ERROR(-20113, 'Erro de atribuicao. Verifique os dados fornecidos');
            WHEN e_not_valid_federacao THEN
                RAISE_APPLICATION_ERROR(-20114, 'Informe o nome de uma federacao existente');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20110, 'Erro em include_federacao ' || CHR(10) || SQLERRM);
    END include_federacao;
    
    PROCEDURE delete_federacao (
        p_user USERS.ID_User%TYPE
    ) IS
        v_lider Lider%ROWTYPE;
        BEGIN
            v_lider := PG_Users.get_user_info(p_user);
            IF v_lider.cargo != 'COMANDANTE' THEN RAISE e_not_comandante; END IF;
            PG_Users.set_user_id(p_user);

            UPDATE NACAO N SET FEDERACAO = NULL WHERE N.NOME = v_lider.nacao;
            COMMIT;    

        EXCEPTION
            WHEN e_not_comandante THEN
                RAISE_APPLICATION_ERROR(-20111, 'Usuario nao e comandante');
            WHEN e_atrib_notnull THEN
                RAISE_APPLICATION_ERROR(-20112, 'Valor obrigatorio nao fornecido');
            WHEN VALUE_ERROR THEN
                RAISE_APPLICATION_ERROR(-20113, 'Erro de atribuicao. Verifique os dados fornecidos');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20110, 'Erro em delete_federacao' || CHR(10) || SQLERRM);
    END delete_federacao;
    
    PROCEDURE create_federacao (
        p_user USERS.ID_User%TYPE,
        p_federacao_nome Federacao.Nome%TYPE,
        p_federacao_dt_fund Federacao.DATA_FUND%TYPE DEFAULT TO_DATE(SYSDATE, 'dd/mm/yyyy')
    ) IS
        v_lider Lider%ROWTYPE;
        BEGIN
            v_lider := PG_Users.get_user_info(p_user);
            IF v_lider.cargo != 'COMANDANTE' THEN RAISE e_not_comandante; END IF;
            PG_Users.set_user_id(p_user);

            INSERT INTO FEDERACAO VALUES (p_federacao_nome, p_federacao_dt_fund);
            UPDATE NACAO N SET FEDERACAO = p_federacao_nome WHERE N.NOME = v_lider.nacao;
            COMMIT;
    
        EXCEPTION
            WHEN e_not_comandante THEN
                RAISE_APPLICATION_ERROR(-20111, 'Usuario nao e comandante');
            WHEN e_atrib_notnull THEN
                RAISE_APPLICATION_ERROR(-20112, 'Valor obrigatorio nao fornecido');
            WHEN VALUE_ERROR THEN
                RAISE_APPLICATION_ERROR(-20113, 'Erro de atribuicao. Verifique os dados fornecidos');
            WHEN DUP_VAL_ON_INDEX THEN
                RAISE_APPLICATION_ERROR(-20114, 'Federacao ja existente');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20110, 'Erro em create_federacao' || CHR(10) || SQLERRM);
    END create_federacao;
    
    PROCEDURE insert_dominancia (
        p_user USERS.ID_User%TYPE,
        p_dominancia_planeta Dominancia.Planeta%TYPE,
        p_dominancia_data_ini Dominancia.Data_ini%TYPE DEFAULT TO_DATE(SYSDATE, 'dd/mm/yyyy'),
        p_dominancia_data_fim Dominancia.Data_fim%TYPE DEFAULT NULL
    ) IS
        v_lider Lider%ROWTYPE;
        v_count NUMBER;
        BEGIN
            v_lider := PG_Users.get_user_info(p_user);
            IF v_lider.cargo != 'COMANDANTE' THEN RAISE e_not_comandante; END IF;
            PG_Users.set_user_id(p_user);

            SELECT COUNT(*)
                INTO v_count
                FROM DOMINANCIA D
                WHERE D.PLANETA = p_dominancia_planeta
                    AND D.DATA_FIM IS NULL;
            IF v_count != 0
                THEN RAISE e_not_valid_planeta;
            ELSE
                INSERT INTO DOMINANCIA (PLANETA, NACAO, DATA_INI, DATA_FIM)
                    VALUES (p_dominancia_planeta, v_lider.nacao, p_dominancia_data_ini, p_dominancia_data_fim);
                COMMIT;
            END IF;
    
        EXCEPTION
            WHEN e_not_comandante THEN
                RAISE_APPLICATION_ERROR(-20111, 'Usuario nao e comandante');
            WHEN e_atrib_notnull THEN
                RAISE_APPLICATION_ERROR(-20112, 'Valor obrigatorio nao fornecido');
            WHEN VALUE_ERROR THEN
                RAISE_APPLICATION_ERROR(-20113, 'Erro de atribuicao. Verifique os dados fornecidos');
            WHEN e_not_valid_planeta THEN
                RAISE_APPLICATION_ERROR(-20114, 'Planeta já é dominado');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20110, 'Erro em insert_dominancia' || CHR(10) || SQLERRM);
    END insert_dominancia;
    
    FUNCTION relatorio_dominancia_planetas (
        p_user USERS.ID_User%TYPE
    ) RETURN SYS_REFCURSOR
    AS
        v_lider Lider%ROWTYPE;
        v_cursor SYS_REFCURSOR;
            
        BEGIN
            v_lider := PG_Users.get_user_info(p_user);
            IF v_lider.cargo != 'COMANDANTE' THEN RAISE e_not_comandante; END IF;
            
            OPEN v_cursor FOR
                SELECT
                    nome_planeta,
                    nacao_dominante,
                    data_inicio_dominancia,
                    data_fim_dominancia,
                    quantidade_comunidades,
                    especies_presentes,
                    total_habitantes,
                    faccoes_presentes,
                    faccao_majoritaria
                FROM V_DOMINANCIA_PLANETAS;
            
            RETURN v_cursor;
            
        EXCEPTION
            WHEN e_not_comandante THEN
                RAISE_APPLICATION_ERROR(-20111, 'Usuario nao e comandante');
            WHEN e_atrib_notnull THEN
                RAISE_APPLICATION_ERROR(-20112, 'Valor obrigatorio nao fornecido');
            WHEN VALUE_ERROR THEN
                RAISE_APPLICATION_ERROR(-20113, 'Erro de atribuicao. Verifique os dados fornecidos');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20110, 'Erro em relatorio_dominancia_planetas' || CHR(10) || SQLERRM);
    END relatorio_dominancia_planetas;

    FUNCTION relatorio_planetas_dominados (
        p_user USERS.ID_User%TYPE
    ) RETURN SYS_REFCURSOR
    AS
        v_lider Lider%ROWTYPE;
        v_cursor SYS_REFCURSOR;
        
        BEGIN
            v_lider := PG_Users.get_user_info(p_user);
            IF v_lider.cargo != 'COMANDANTE' THEN RAISE e_not_comandante; END IF;
            
            OPEN v_cursor FOR
                SELECT
                    nome_planeta,
                    nacao_dominante,
                    data_inicio_dominancia,
                    data_fim_dominancia,
                    quantidade_comunidades,
                    especies_presentes,
                    total_habitantes,
                    faccoes_presentes,
                    faccao_majoritaria
                FROM V_DOMINANCIA_PLANETAS
                WHERE NACAO_DOMINANTE IS NOT NULL
                    AND DATA_FIM_DOMINANCIA > SYSDATE;
            RETURN v_cursor;
            
        EXCEPTION
            WHEN e_not_comandante THEN
                RAISE_APPLICATION_ERROR(-20111, 'Usuario nao e comandante');
            WHEN e_atrib_notnull THEN
                RAISE_APPLICATION_ERROR(-20112, 'Valor obrigatorio nao fornecido');
            WHEN VALUE_ERROR THEN
                RAISE_APPLICATION_ERROR(-20113, 'Erro de atribuicao. Verifique os dados fornecidos');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20110, 'Erro em relatorio_planetas_dominados' || CHR(10) || SQLERRM);
    END relatorio_planetas_dominados;
    
    FUNCTION relatorio_planetas_nao_dominados (
        p_user USERS.ID_User%TYPE
    ) RETURN SYS_REFCURSOR
    AS
        v_lider Lider%ROWTYPE;
        v_cursor SYS_REFCURSOR;

        BEGIN
            v_lider := PG_Users.get_user_info(p_user);
            IF v_lider.cargo != 'COMANDANTE' THEN RAISE e_not_comandante; END IF;
            
            OPEN v_cursor FOR
                SELECT
                    nome_planeta,
                    nacao_dominante,
                    data_inicio_dominancia,
                    data_fim_dominancia,
                    quantidade_comunidades,
                    especies_presentes,
                    total_habitantes,
                    faccoes_presentes,
                    faccao_majoritaria
                FROM V_DOMINANCIA_PLANETAS
                WHERE NACAO_DOMINANTE IS NULL
                    OR DATA_FIM_DOMINANCIA <= SYSDATE;
            RETURN v_cursor;
            
        EXCEPTION
            WHEN e_not_comandante THEN
                RAISE_APPLICATION_ERROR(-20111, 'Usuario nao e comandante');
            WHEN e_atrib_notnull THEN
                RAISE_APPLICATION_ERROR(-20112, 'Valor obrigatorio nao fornecido');
            WHEN VALUE_ERROR THEN
                RAISE_APPLICATION_ERROR(-20113, 'Erro de atribuicao. Verifique os dados fornecidos');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20110, 'Erro em relatorio_planetas_nao_dominados' || CHR(10) || SQLERRM);
    END relatorio_planetas_nao_dominados;
END PG_Comandante;