CREATE OR REPLACE PACKAGE RL_Oficial AS

    PROCEDURE RELATORIO_HABITANTES_POR_FACCAO (
        p_nacao IN VARCHAR2,
        p_cursor OUT SYS_REFCURSOR
    );

    PROCEDURE RELATORIO_HABITANTES_POR_ESPECIE (
        p_nacao IN VARCHAR2,
        p_cursor OUT SYS_REFCURSOR
    );

    PROCEDURE RELATORIO_HABITANTES_POR_PLANETA (
        p_nacao IN VARCHAR2,
        p_cursor OUT SYS_REFCURSOR
    );

    PROCEDURE RELATORIO_HABITANTES_POR_SISTEMA (
        p_nacao IN VARCHAR2,
        p_cursor OUT SYS_REFCURSOR
    );

END RL_Oficial;
/

CREATE OR REPLACE PACKAGE BODY RL_Oficial AS

    PROCEDURE RELATORIO_HABITANTES_POR_FACCAO (
        p_nacao IN VARCHAR2,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT FACCAO, TOTAL_PLANETAS, TOTAL_HABITANTES
            FROM V_HABITANTES_POR_FACCAO;
    END RELATORIO_HABITANTES_POR_FACCAO;

    PROCEDURE RELATORIO_HABITANTES_POR_ESPECIE (
        p_nacao IN VARCHAR2,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT ESPECIE, TOTAL_PLANETAS, TOTAL_HABITANTES
            FROM V_HABITANTES_POR_ESPECIE;
    END RELATORIO_HABITANTES_POR_ESPECIE;

    PROCEDURE RELATORIO_HABITANTES_POR_PLANETA (
        p_nacao IN VARCHAR2,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT PLANETA, TOTAL_HABITANTES
            FROM V_HABITANTES_POR_PLANETA;
    END RELATORIO_HABITANTES_POR_PLANETA;

    PROCEDURE RELATORIO_HABITANTES_POR_SISTEMA (
        p_nacao IN VARCHAR2,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT SISTEMA, TOTAL_PLANETAS, TOTAL_HABITANTES
            FROM V_HABITANTES_POR_SISTEMA;
    END RELATORIO_HABITANTES_POR_SISTEMA;

END RL_Oficial;
/
