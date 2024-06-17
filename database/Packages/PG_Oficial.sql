CREATE OR REPLACE PACKAGE PG_Oficial AS
    -- Exceções
    e_not_oficial EXCEPTION;

    -- Procedimentos
    PROCEDURE verificar_oficial (
        p_user IN LIDER.CPI%TYPE
    );

    PROCEDURE relatorio_habitantes_fac (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    );

    PROCEDURE relatorio_habitantes_especie (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    );

    PROCEDURE relatorio_habitantes_planeta (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    );

    PROCEDURE relatorio_habitantes_sistema (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    );

END PG_Oficial;
/

CREATE OR REPLACE PACKAGE BODY PG_Oficial AS

    PROCEDURE verificar_oficial (
        p_user IN LIDER.CPI%TYPE
    ) IS
        v_user LIDER%ROWTYPE;
    BEGIN
        -- Obtém as informações do usuário
        SELECT * INTO v_user FROM LIDER WHERE CPI = p_user;

        -- Verifica se o usuário é um oficial
        IF v_user.CARGO != 'OFICIAL' THEN
            RAISE e_not_oficial;
        END IF;
    END verificar_oficial;

    PROCEDURE relatorio_habitantes_fac (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    ) IS
        v_nacao LIDER.NACAO%TYPE;
    BEGIN
        -- Verifica se o usuário é um oficial
        verificar_oficial(p_user);

        -- Obtém a nação do oficial
        SELECT NACAO INTO v_nacao FROM LIDER WHERE CPI = p_user;

        -- Chama o procedimento para gerar o relatório
        OPEN p_cursor FOR
            SELECT FACCAO, TOTAL_PLANETAS, TOTAL_HABITANTES
            FROM V_HABITANTES_POR_FACCAO;

    END relatorio_habitantes_fac;

    PROCEDURE relatorio_habitantes_especie (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    ) IS
        v_nacao LIDER.NACAO%TYPE;
    BEGIN
        -- Verifica se o usuário é um oficial
        verificar_oficial(p_user);

        -- Obtém a nação do oficial
        SELECT NACAO INTO v_nacao FROM LIDER WHERE CPI = p_user;

        -- Chama o procedimento para gerar o relatório
        OPEN p_cursor FOR
            SELECT ESPECIE, TOTAL_PLANETAS, TOTAL_HABITANTES
            FROM V_HABITANTES_POR_ESPECIE;

    END relatorio_habitantes_especie;

    PROCEDURE relatorio_habitantes_planeta (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    ) IS
        v_nacao LIDER.NACAO%TYPE;
    BEGIN
        -- Verifica se o usuário é um oficial
        verificar_oficial(p_user);

        -- Obtém a nação do oficial
        SELECT NACAO INTO v_nacao FROM LIDER WHERE CPI = p_user;

        -- Chama o procedimento para gerar o relatório
        OPEN p_cursor FOR
            SELECT PLANETA, TOTAL_HABITANTES
            FROM V_HABITANTES_POR_PLANETA;

    END relatorio_habitantes_planeta;

    PROCEDURE relatorio_habitantes_sistema (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    ) IS
        v_nacao LIDER.NACAO%TYPE;
    BEGIN
        -- Verifica se o usuário é um oficial
        verificar_oficial(p_user);

        -- Obtém a nação do oficial
        SELECT NACAO INTO v_nacao FROM LIDER WHERE CPI = p_user;

        -- Chama o procedimento para gerar o relatório
        OPEN p_cursor FOR
            SELECT SISTEMA, TOTAL_PLANETAS, TOTAL_HABITANTES
            FROM V_HABITANTES_POR_SISTEMA;

    END relatorio_habitantes_sistema;

END PG_Oficial;
/
