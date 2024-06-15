-- Relatórios Oficial
--Procedure para relatório detalhado de habitantes por facção
CREATE OR REPLACE PROCEDURE RELATORIO_HABITANTES_POR_FACCAO (
    p_nacao IN VARCHAR2
) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Relatório de Habitantes por Facção para a Nação: ' || p_nacao);
    FOR rec IN (
        SELECT F.NOME AS FACCAO, COUNT(DISTINCT H.PLANETA) AS TOTAL_PLANETAS, SUM(C.QTD_HABITANTES) AS TOTAL_HABITANTES
        FROM HABITACAO H
        JOIN COMUNIDADE C ON H.ESPECIE = C.ESPECIE AND H.COMUNIDADE = C.NOME
        JOIN PARTICIPA P ON C.ESPECIE = P.ESPECIE AND C.NOME = P.COMUNIDADE
        JOIN FACCAO F ON P.FACCAO = F.NOME
        JOIN DOMINANCIA D ON H.PLANETA = D.PLANETA
        WHERE D.NACAO = p_nacao
        GROUP BY F.NOME
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Facção: ' || rec.FACCAO || ', Total de Planetas: ' || rec.TOTAL_PLANETAS || ', Total de Habitantes: ' || rec.TOTAL_HABITANTES);
    END LOOP;
END;
/


--Procedure para relatório detalhado de habitantes por espécie
CREATE OR REPLACE PROCEDURE RELATORIO_HABITANTES_POR_ESPECIE (
    p_nacao IN VARCHAR2
) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Relatório de Habitantes por Espécie para a Nação: ' || p_nacao);
    FOR rec IN (
        SELECT E.NOME AS ESPECIE, COUNT(DISTINCT H.PLANETA) AS TOTAL_PLANETAS, SUM(C.QTD_HABITANTES) AS TOTAL_HABITANTES
        FROM HABITACAO H
        JOIN COMUNIDADE C ON H.ESPECIE = C.ESPECIE AND H.COMUNIDADE = C.NOME
        JOIN ESPECIE E ON C.ESPECIE = E.NOME
        JOIN DOMINANCIA D ON H.PLANETA = D.PLANETA
        WHERE D.NACAO = p_nacao
        GROUP BY E.NOME
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Espécie: ' || rec.ESPECIE || ', Total de Planetas: ' || rec.TOTAL_PLANETAS || ', Total de Habitantes: ' || rec.TOTAL_HABITANTES);
    END LOOP;
END;
/

--Procedure para relatório detalhado de habitantes por planeta
CREATE OR REPLACE PROCEDURE RELATORIO_HABITANTES_POR_PLANETA (
    p_nacao IN VARCHAR2
) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Relatório de Habitantes por Planeta para a Nação: ' || p_nacao);
    FOR rec IN (
        SELECT P.ID_ASTRO AS PLANETA, SUM(C.QTD_HABITANTES) AS TOTAL_HABITANTES
        FROM HABITACAO H
        JOIN COMUNIDADE C ON H.ESPECIE = C.ESPECIE AND H.COMUNIDADE = C.NOME
        JOIN PLANETA P ON H.PLANETA = P.ID_ASTRO
        JOIN DOMINANCIA D ON H.PLANETA = D.PLANETA
        WHERE D.NACAO = p_nacao
        GROUP BY P.ID_ASTRO
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Planeta: ' || rec.PLANETA || ', Total de Habitantes: ' || rec.TOTAL_HABITANTES);
    END LOOP;
END;
/

--Procedure para relatório detalhado de habitantes por sistema
CREATE OR REPLACE PROCEDURE RELATORIO_HABITANTES_POR_SISTEMA (
    p_nacao IN VARCHAR2
) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Relatório de Habitantes por Sistema para a Nação: ' || p_nacao);
    FOR rec IN (
        SELECT S.NOME AS SISTEMA, COUNT(DISTINCT H.PLANETA) AS TOTAL_PLANETAS, SUM(C.QTD_HABITANTES) AS TOTAL_HABITANTES
        FROM HABITACAO H
        JOIN COMUNIDADE C ON H.ESPECIE = C.ESPECIE AND H.COMUNIDADE = C.NOME
        JOIN ORBITA_PLANETA OP ON H.PLANETA = OP.PLANETA
        JOIN SISTEMA S ON OP.ESTRELA = S.ESTRELA
        JOIN DOMINANCIA D ON H.PLANETA = D.PLANETA
        WHERE D.NACAO = p_nacao
        GROUP BY S.NOME
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Sistema: ' || rec.SISTEMA || ', Total de Planetas: ' || rec.TOTAL_PLANETAS || ', Total de Habitantes: ' || rec.TOTAL_HABITANTES);
    END LOOP;
END;
/


-- Gerar relatório de habitantes por facção para uma nação específica
SET SERVEROUTPUT ON;
EXEC RELATORIO_HABITANTES_POR_FACCAO('NacaoExemplo');

-- Gerar relatório de habitantes por espécie para uma nação específica
SET SERVEROUTPUT ON;
EXEC RELATORIO_HABITANTES_POR_ESPECIE('NacaoExemplo');

-- Gerar relatório de habitantes por planeta para uma nação específica
SET SERVEROUTPUT ON;
EXEC RELATORIO_HABITANTES_POR_PLANETA('NacaoExemplo');

-- Gerar relatório de habitantes por sistema para uma nação específica
SET SERVEROUTPUT ON;
EXEC RELATORIO_HABITANTES_POR_SISTEMA('NacaoExemplo');

-- *** Precisa ajustar aqui depois
-- Atribuir permissao de gerar relatorios para oficial
GRANT EXECUTE ON RELATORIO_HABITANTES_POR_SISTEMA TO OFICIAL;
GRANT EXECUTE ON RELATORIO_HABITANTES_POR_FACCAO TO OFICIAL;
GRANT EXECUTE ON RELATORIO_HABITANTES_POR_ESPECIE TO OFICIAL;
GRANT EXECUTE ON RELATORIO_HABITANTES_POR_PLANETA TO OFICIAL;
