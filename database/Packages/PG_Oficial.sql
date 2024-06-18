DROP PACKAGE PG_Oficial;

/* Package Oficial */
CREATE OR REPLACE PACKAGE PG_Oficial AS

    PROCEDURE verificar_oficial (
        p_user USERS.ID_User%TYPE
    );

    PROCEDURE relatorio_habitantes_fac (
        p_user USERS.ID_User%TYPE,
        p_cursor OUT SYS_REFCURSOR
    );

    PROCEDURE relatorio_habitantes_especie (
        p_user USERS.ID_User%TYPE,
        p_cursor OUT SYS_REFCURSOR
    );

    PROCEDURE relatorio_habitantes_planeta (
        p_user USERS.ID_User%TYPE,
        p_cursor OUT SYS_REFCURSOR
    );

    PROCEDURE relatorio_habitantes_sistema (
        p_user USERS.ID_User%TYPE,
        p_cursor OUT SYS_REFCURSOR
    );

    FUNCTION relatorioOficial (
        p_faccao FACCAO.NOME%TYPE,
        p_grouping char
    ) RETURN sys_refcursor;


END PG_Oficial;
/

CREATE OR REPLACE PACKAGE BODY PG_Oficial AS

    PROCEDURE verificar_oficial (
        p_user USERS.ID_User%TYPE
    ) IS
        v_user LIDER%ROWTYPE;
    BEGIN
        v_user := PG_Users.get_user_info(p_user);
        -- Verifica se o usuário é um oficial
        IF v_user.CARGO != 'OFICIAL' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Usuário não é um oficial.');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nenhum usuário encontrado com o CPI fornecido.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20003, 'Erro ao verificar oficial: ' || SQLERRM);
    END verificar_oficial;

    PROCEDURE relatorio_habitantes_fac (
        p_user USERS.ID_User%TYPE,
        p_cursor OUT SYS_REFCURSOR
    ) IS
        v_nacao LIDER.NACAO%TYPE;
    BEGIN
        -- Verifica se o usuário é um oficial
        verificar_oficial(p_user);

        -- Obtém a nação do oficial
        SELECT NACAO INTO v_nacao FROM LIDER WHERE CPI = p_user;

        -- Chama o procedimento para gerar o relatório
        BEGIN
            RL_Oficial.RELATORIO_HABITANTES_POR_FACCAO(v_nacao, p_cursor);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20004, 'Nenhuma informação encontrada para gerar relatório por facção.');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20005, 'Erro ao gerar relatório por facção: ' || SQLERRM);
        END;
    END relatorio_habitantes_fac;

    PROCEDURE relatorio_habitantes_especie (
        p_user USERS.ID_User%TYPE,
        p_cursor OUT SYS_REFCURSOR
    ) IS
        v_nacao LIDER.NACAO%TYPE;
    BEGIN
        -- Verifica se o usuário é um oficial
        verificar_oficial(p_user);

        -- Obtém a nação do oficial
        SELECT NACAO INTO v_nacao FROM LIDER WHERE CPI = p_user;

        -- Chama o procedimento para gerar o relatório
        BEGIN
            RL_Oficial.RELATORIO_HABITANTES_POR_ESPECIE(v_nacao, p_cursor);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20006, 'Nenhuma informação encontrada para gerar relatório por espécie.');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20007, 'Erro ao gerar relatório por espécie: ' || SQLERRM);
        END;
    END relatorio_habitantes_especie;

    PROCEDURE relatorio_habitantes_planeta (
        p_user USERS.ID_User%TYPE,
        p_cursor OUT SYS_REFCURSOR
    ) IS
        v_nacao LIDER.NACAO%TYPE;
    BEGIN
        -- Verifica se o usuário é um oficial
        verificar_oficial(p_user);

        -- Obtém a nação do oficial
        SELECT NACAO INTO v_nacao FROM LIDER WHERE CPI = p_user;

        -- Chama o procedimento para gerar o relatório
        BEGIN
            RL_Oficial.RELATORIO_HABITANTES_POR_PLANETA(v_nacao, p_cursor);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20008, 'Nenhuma informação encontrada para gerar relatório por planeta.');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20009, 'Erro ao gerar relatório por planeta: ' || SQLERRM);
        END;
    END relatorio_habitantes_planeta;

    PROCEDURE relatorio_habitantes_sistema (
        p_user USERS.ID_User%TYPE,
        p_cursor OUT SYS_REFCURSOR
    ) IS
        v_nacao LIDER.NACAO%TYPE;
    BEGIN
        -- Verifica se o usuário é um oficial
        verificar_oficial(p_user);

        -- Obtém a nação do oficial
        SELECT NACAO INTO v_nacao FROM LIDER WHERE CPI = p_user;

        -- Chama o procedimento para gerar o relatório
        BEGIN
            RL_Oficial.RELATORIO_HABITANTES_POR_SISTEMA(v_nacao, p_cursor);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20010, 'Nenhuma informação encontrada para gerar relatório por sistema.');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20011, 'Erro ao gerar relatório por sistema: ' || SQLERRM);
        END;
    END relatorio_habitantes_sistema;


    FUNCTION relatorioOficial ( p_faccao FACCAO.NOME%TYPE, p_grouping char ) RETURN sys_refcursor IS
        c_report sys_refcursor;
    BEGIN 
        IF p_grouping = 'F' THEN	
            OPEN c_report FOR 	
                SELECT * FROM V_RL_OFICIAL order BY faccao;
            
        ELSIF p_grouping = 'E' THEN	
            OPEN c_report FOR 
                SELECT * FROM V_RL_OFICIAL order BY especie;
            
        ELSIF p_grouping = 'P' THEN	
            OPEN c_report FOR 
                SELECT * FROM V_RL_OFICIAL order BY planeta;

        ELSIF p_grouping = 'S' THEN	
            OPEN c_report FOR 
                SELECT * FROM V_RL_OFICIAL order BY estrela;

        ELSE
            OPEN c_report FOR 
                    
        END IF;
        RETURN c_report;

    END relatorioOficial;
END PG_Oficial;
/


