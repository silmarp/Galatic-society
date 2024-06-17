--Procedimento para relatório detalhado de habitantes por facção:
CREATE OR REPLACE PROCEDURE RELATORIO_HABITANTES_POR_FACCAO (
    p_nacao IN VARCHAR2,
    p_cursor OUT SYS_REFCURSOR
) IS
BEGIN
    OPEN p_cursor FOR
        SELECT FACCAO, TOTAL_PLANETAS, TOTAL_HABITANTES
        FROM V_HABITANTES_POR_FACCAO;
END;
/

--Procedimento para relatório detalhado de habitantes por espécie:
CREATE OR REPLACE PROCEDURE RELATORIO_HABITANTES_POR_ESPECIE (
    p_nacao IN VARCHAR2,
    p_cursor OUT SYS_REFCURSOR
) IS
BEGIN
    OPEN p_cursor FOR
        SELECT ESPECIE, TOTAL_PLANETAS, TOTAL_HABITANTES
        FROM V_HABITANTES_POR_ESPECIE;
END;
/

--Procedimento para relatório detalhado de habitantes por planeta:
CREATE OR REPLACE PROCEDURE RELATORIO_HABITANTES_POR_PLANETA (
    p_nacao IN VARCHAR2,
    p_cursor OUT SYS_REFCURSOR
) IS
BEGIN
    OPEN p_cursor FOR
        SELECT PLANETA, TOTAL_HABITANTES
        FROM V_HABITANTES_POR_PLANETA;
END;
/

--Procedimento para relatório detalhado de habitantes por sistema:
CREATE OR REPLACE PROCEDURE RELATORIO_HABITANTES_POR_SISTEMA (
    p_nacao IN VARCHAR2,
    p_cursor OUT SYS_REFCURSOR
) IS
BEGIN
    OPEN p_cursor FOR
        SELECT SISTEMA, TOTAL_PLANETAS, TOTAL_HABITANTES
        FROM V_HABITANTES_POR_SISTEMA;
END;
/
