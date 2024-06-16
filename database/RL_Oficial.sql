--Procedimento para relatório detalhado de habitantes por facção:
CREATE OR REPLACE PROCEDURE RELATORIO_HABITANTES_POR_FACCAO (
    p_nacao IN VARCHAR2
) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Relatório de Habitantes por Facção para a Nação: ' || p_nacao);
    FOR rec IN (
        SELECT FACCAO, TOTAL_PLANETAS, TOTAL_HABITANTES
        FROM V_HABITANTES_POR_FACCAO
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Facção: ' || rec.FACCAO || ', Total de Planetas: ' || rec.TOTAL_PLANETAS || ', Total de Habitantes: ' || rec.TOTAL_HABITANTES);
    END LOOP;
END;
/

--Procedimento para relatório detalhado de habitantes por espécie:
CREATE OR REPLACE PROCEDURE RELATORIO_HABITANTES_POR_ESPECIE (
    p_nacao IN VARCHAR2
) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Relatório de Habitantes por Espécie para a Nação: ' || p_nacao);
    FOR rec IN (
        SELECT ESPECIE, TOTAL_PLANETAS, TOTAL_HABITANTES
        FROM V_HABITANTES_POR_ESPECIE
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Espécie: ' || rec.ESPECIE || ', Total de Planetas: ' || rec.TOTAL_PLANETAS || ', Total de Habitantes: ' || rec.TOTAL_HABITANTES);
    END LOOP;
END;
/

--Procedimento para relatório detalhado de habitantes por planeta:
CREATE OR REPLACE PROCEDURE RELATORIO_HABITANTES_POR_PLANETA (
    p_nacao IN VARCHAR2
) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Relatório de Habitantes por Planeta para a Nação: ' || p_nacao);
    FOR rec IN (
        SELECT PLANETA, TOTAL_HABITANTES
        FROM V_HABITANTES_POR_PLANETA
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Planeta: ' || rec.PLANETA || ', Total de Habitantes: ' || rec.TOTAL_HABITANTES);
    END LOOP;
END;
/

--Procedimento para relatório detalhado de habitantes por sistema:
CREATE OR REPLACE PROCEDURE RELATORIO_HABITANTES_POR_SISTEMA (
    p_nacao IN VARCHAR2
) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Relatório de Habitantes por Sistema para a Nação: ' || p_nacao);
    FOR rec IN (
        SELECT SISTEMA, TOTAL_PLANETAS, TOTAL_HABITANTES
        FROM V_HABITANTES_POR_SISTEMA
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Sistema: ' || rec.SISTEMA || ', Total de Planetas: ' || rec.TOTAL_PLANETAS || ', Total de Habitantes: ' || rec.TOTAL_HABITANTES);
    END LOOP;
END;
/

-- Gerar relatório de habitantes por facção para uma nação específica
SET SERVEROUTPUT ON;
EXEC RELATORIO_HABITANTES_POR_FACCAO('NacaoExemplo');

-- Gerar relatório de habitantes por espécie para uma nação específica
EXEC RELATORIO_HABITANTES_POR_ESPECIE('NacaoExemplo');

-- Gerar relatório de habitantes por planeta para uma nação específica
EXEC RELATORIO_HABITANTES_POR_PLANETA('NacaoExemplo');

-- Gerar relatório de habitantes por sistema para uma nação específica
EXEC RELATORIO_HABITANTES_POR_SISTEMA('NacaoExemplo');