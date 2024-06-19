DROP PACKAGE PG_Oficial;

/* Package Oficial */
CREATE OR REPLACE PACKAGE PG_Oficial AS
    e_not_oficial EXCEPTION;
    e_atrib_notnull EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_atrib_notnull, -01400);
    
    FUNCTION relatorio_oficial (
        p_user USERS.ID_User%TYPE,
        p_nacao NACAO.NOME%TYPE,
        p_grouping char
    ) RETURN sys_refcursor;
END PG_Oficial;
/

CREATE OR REPLACE PACKAGE BODY PG_Oficial AS
    FUNCTION relatorio_oficial (
        p_user USERS.ID_User%TYPE,
        p_nacao NACAO.NOME%TYPE,
        p_grouping char
    ) RETURN sys_refcursor
    IS
        c_report sys_refcursor;
        v_lider Lider%ROWTYPE;
        BEGIN 
            v_lider := PG_Users.get_user_info(p_user);
            IF v_lider.cargo != 'OFICIAL' THEN RAISE e_not_oficial; END IF;
    
            IF p_grouping = 'F' THEN	
                OPEN c_report FOR 	
                    SELECT * FROM V_RL_OFICIAL where NACAO = p_nacao order BY faccao;                
            ELSIF p_grouping = 'E' THEN	
                OPEN c_report FOR 
                    SELECT * FROM V_RL_OFICIAL where NACAO = p_nacao order BY especie;                
            ELSIF p_grouping = 'P' THEN	
                OPEN c_report FOR 
                    SELECT * FROM V_RL_OFICIAL where NACAO = p_nacao order BY planeta;    
            ELSIF p_grouping = 'S' THEN	
                OPEN c_report FOR 
                    SELECT * FROM V_RL_OFICIAL where NACAO = p_nacao order BY estrela;    
            ELSE
                OPEN c_report FOR
                    SELECT * FROM V_RL_OFICIAL where NACAO = p_nacao;
            END IF;
            RETURN c_report;
            
        EXCEPTION
            WHEN e_not_oficial THEN
                RAISE_APPLICATION_ERROR(-20131, 'Usuario nao e oficial');
            WHEN e_atrib_notnull THEN
                RAISE_APPLICATION_ERROR(-20132, 'Valor obrigatorio nao fornecido');
            WHEN VALUE_ERROR THEN
                RAISE_APPLICATION_ERROR(-20133, 'Erro de atribuicao. Verifique os dados fornecidos');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20130, 'Erro em relatorio_oficial ' || CHR(10) || SQLERRM);
    END relatorio_oficial;
END PG_Oficial;
/