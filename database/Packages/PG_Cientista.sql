DROP PACKAGE PG_Cientista;

/* Package Cientista */
CREATE OR REPLACE PACKAGE PG_Cientista AS

    PROCEDURE verificar_cientista (
        p_user IN LIDER.CPI%TYPE
    );

    PROCEDURE relatorio_estrelas (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    );

    PROCEDURE relatorio_planetas (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    );

    PROCEDURE relatorio_sistemas (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    );

END PG_Cientista;
/

CREATE OR REPLACE PACKAGE BODY PG_Cientista AS

    PROCEDURE verificar_cientista (
        p_user IN LIDER.CPI%TYPE
    ) IS
        v_user LIDER%ROWTYPE;
    BEGIN
        -- Obtém as informações do usuário
        SELECT * INTO v_user FROM LIDER WHERE CPI = p_user;

        -- Verifica se o usuário é um cientista
        IF v_user.CARGO != 'CIENTISTA' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Usuário não é um cientista.');
        END IF;
    END verificar_cientista;

    PROCEDURE relatorio_estrelas (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        -- Verifica se o usuário é um cientista
        verificar_cientista(p_user);

        -- Chama o procedimento do pacote RL_Cientista para gerar o relatório de estrelas
        p_cursor := RL_Cientista.CURSOR_RELATORIO_ESTRELAS;
    END relatorio_estrelas;

    PROCEDURE relatorio_planetas (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        -- Verifica se o usuário é um cientista
        verificar_cientista(p_user);

        -- Chama o procedimento do pacote RL_Cientista para gerar o relatório de planetas
        p_cursor := RL_Cientista.CURSOR_RELATORIO_PLANETAS;
    END relatorio_planetas;

    PROCEDURE relatorio_sistemas (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        -- Verifica se o usuário é um cientista
        verificar_cientista(p_user);

        -- Chama o procedimento do pacote RL_Cientista para gerar o relatório de sistemas
        p_cursor := RL_Cientista.CURSOR_RELATORIO_SISTEMAS;
    END relatorio_sistemas;

END PG_Cientista;
/
