--Procedimento para Relatório de Estrelas
CREATE OR REPLACE PROCEDURE RELATORIO_ESTRELAS IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Relatório de Estrelas:');
    FOR rec IN (
        SELECT ID_ESTRELA, NOME, CLASSIFICACAO, MASSA, X, Y, Z
        FROM ESTRELA
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || rec.ID_ESTRELA || ', Nome: ' || rec.NOME || ', Classificação: ' || rec.CLASSIFICACAO || ', Massa: ' || rec.MASSA || ', Coordenadas: (' || rec.X || ', ' || rec.Y || ', ' || rec.Z || ')');
    END LOOP;
END;
/

--Procedimento para Relatório de Planetas
CREATE OR REPLACE PROCEDURE RELATORIO_PLANETAS IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Relatório de Planetas:');
    FOR rec IN (
        SELECT ID_ASTRO, MASSA, RAIO, CLASSIFICACAO
        FROM PLANETA
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || rec.ID_ASTRO || ', Massa: ' || rec.MASSA || ', Raio: ' || rec.RAIO || ', Classificação: ' || rec.CLASSIFICACAO);
    END LOOP;
END;
/

--Procedimento para Relatório de Sistemas
CREATE OR REPLACE PROCEDURE RELATORIO_SISTEMAS IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Relatório de Sistemas Estelares:');
    FOR rec IN (
        SELECT S.NOME AS SISTEMA, E.ID_ESTRELA, E.NOME AS NOME_ESTRELA, E.CLASSIFICACAO, E.MASSA, E.X, E.Y, E.Z
        FROM SISTEMA S
        JOIN ORBITA_ESTRELA OE ON S.ESTRELA = OE.ORBITADA
        JOIN ESTRELA E ON OE.ORBITANTE = E.ID_ESTRELA
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Sistema: ' || rec.SISTEMA || ', Estrela: ' || rec.NOME_ESTRELA || ' (ID: ' || rec.ID_ESTRELA || '), Classificação: ' || rec.CLASSIFICACAO || ', Massa: ' || rec.MASSA || ', Coordenadas: (' || rec.X || ', ' || rec.Y || ', ' || rec.Z || ')');
    END LOOP;
END;
/

-- Testando

SET SERVEROUTPUT ON;

BEGIN
    RELATORIO_ESTRELAS;
    RELATORIO_PLANETAS;
    RELATORIO_SISTEMAS;
END;
/
