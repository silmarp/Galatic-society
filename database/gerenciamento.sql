-- OBS: precisa adicionar as restricoes de usuarios

-- Líder de facção

-- a)
-- alterar nome faccao
CREATE OR REPLACE PROCEDURE ALTERAR_NOME_FACCAO(
    p_lider_cpi IN LIDER.CPI%TYPE,
    p_nome_faccao_atual IN FACCAO.NOME%TYPE,
    p_novo_nome IN FACCAO.NOME%TYPE
) AS
    v_count INTEGER;
BEGIN
    -- Verifica se o líder está autorizado para a facção específica
    SELECT COUNT(*)
    INTO v_count
    FROM FACCAO
    WHERE LIDER = p_lider_cpi AND NOME = p_nome_faccao_atual;
    
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Acesso não autorizado ou facção não encontrada');
    END IF;

    BEGIN
        -- Desativar constraints para evitar erros de integridade referencial
        EXECUTE IMMEDIATE 'ALTER TABLE NACAO_FACCAO DISABLE CONSTRAINT FK_NF_FACCAO';
        EXECUTE IMMEDIATE 'ALTER TABLE PARTICIPA DISABLE CONSTRAINT FK_PARTICIPA_FACCAO';
        
        -- Atualizar o nome da facção na tabela FACCAO
        UPDATE FACCAO
        SET NOME = p_novo_nome
        WHERE LIDER = p_lider_cpi AND NOME = p_nome_faccao_atual;

        -- Atualizar referências na tabela NACAO_FACCAO
        UPDATE NACAO_FACCAO
        SET FACCAO = p_novo_nome
        WHERE FACCAO = p_nome_faccao_atual;

        -- Atualizar referências na tabela PARTICIPA
        UPDATE PARTICIPA
        SET FACCAO = p_novo_nome
        WHERE FACCAO = p_nome_faccao_atual;
        
        -- Reativar constraints
        EXECUTE IMMEDIATE 'ALTER TABLE NACAO_FACCAO ENABLE CONSTRAINT FK_NF_FACCAO';
        EXECUTE IMMEDIATE 'ALTER TABLE PARTICIPA ENABLE CONSTRAINT FK_PARTICIPA_FACCAO';
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            -- Reativar constraints mesmo em caso de erro
            EXECUTE IMMEDIATE 'ALTER TABLE NACAO_FACCAO ENABLE CONSTRAINT FK_NF_FACCAO';
            EXECUTE IMMEDIATE 'ALTER TABLE PARTICIPA ENABLE CONSTRAINT FK_PARTICIPA_FACCAO';
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20002, 'Erro ao atualizar nome da facção');
    END;
END;
/

BEGIN
    ALTERAR_NOME_FACCAO('123.456.789-00', 'FAC1', 'NOVO_NOME');
END;
/

-- indicar novo lider
CREATE OR REPLACE PROCEDURE INDICAR_NOVO_LIDER(
    p_lider_atual_cpi IN LIDER.CPI%TYPE,
    p_nome_faccao IN FACCAO.NOME%TYPE,
    p_novo_lider_cpi IN LIDER.CPI%TYPE
) AS
    v_count INTEGER;
BEGIN
    -- Verifica se o líder atual está autorizado para a facção específica
    SELECT COUNT(*)
    INTO v_count
    FROM FACCAO
    WHERE LIDER = p_lider_atual_cpi AND NOME = p_nome_faccao;
    
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Acesso não autorizado ou facção não encontrada');
    END IF;
    
    -- Verifica se o novo líder existe na tabela LIDER
    SELECT COUNT(*)
    INTO v_count
    FROM LIDER
    WHERE CPI = p_novo_lider_cpi;
    
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Novo líder não encontrado');
    END IF;

    -- Início da atualização
    BEGIN
        -- Atualizar a facção com o novo líder
        UPDATE FACCAO
        SET LIDER = p_novo_lider_cpi
        WHERE NOME = p_nome_faccao;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20003, 'Erro ao atualizar líder da facção');
    END;
END;
/


BEGIN
    INDICAR_NOVO_LIDER('123.456.789-00', 'NOVO_NOME', '482.272.703-39');
END;
/

-- Credenciar comunidades novas (Participa), que habitem planetas
-- dominados por nações onde a facção está presente/credenciada
CREATE OR REPLACE PROCEDURE CREDENCIAR_COMUNIDADE(
    p_lider_cpi IN LIDER.CPI%TYPE,
    p_nome_faccao IN FACCAO.NOME%TYPE,
    p_especie IN COMUNIDADE.ESPECIE%TYPE,
    p_nome_comunidade IN COMUNIDADE.NOME%TYPE
) AS
    v_count INTEGER;
    v_planeta VARCHAR2(15);
    v_nacao VARCHAR2(15);
BEGIN
    -- Verifica se o líder está autorizado para a facção específica
    SELECT COUNT(*)
    INTO v_count
    FROM FACCAO f
    WHERE f.LIDER = p_lider_cpi AND f.NOME = p_nome_faccao;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Acesso não autorizado ou facção não encontrada');
    END IF;

    -- Verifica se a comunidade existe e obtém o planeta onde ela habita
    BEGIN
        SELECT PLANETA
        INTO v_planeta
        FROM (
            SELECT h.PLANETA, ROW_NUMBER() OVER (ORDER BY h.PLANETA) AS rn
            FROM HABITACAO h
            JOIN COMUNIDADE c ON h.ESPECIE = c.ESPECIE AND h.COMUNIDADE = c.NOME
            WHERE c.ESPECIE = p_especie AND c.NOME = p_nome_comunidade
        )
        WHERE rn = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Comunidade não encontrada');
    END;

    -- Verifica se o planeta é dominado por uma nação onde a facção está presente
    BEGIN
        SELECT d.NACAO
        INTO v_nacao
        FROM DOMINANCIA d
        JOIN NACAO_FACCAO nf ON d.NACAO = nf.NACAO
        WHERE d.PLANETA = v_planeta AND nf.FACCAO = p_nome_faccao
          AND (d.DATA_FIM IS NULL OR d.DATA_FIM > SYSDATE);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20003, 'Planeta não dominado pela facção');
    END;

    -- Início da atualização
    BEGIN
        -- Inserir a nova comunidade na tabela PARTICIPA
        INSERT INTO PARTICIPA (FACCAO, ESPECIE, COMUNIDADE)
        VALUES (p_nome_faccao, p_especie, p_nome_comunidade);

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20004, 'Erro ao credenciar nova comunidade');
    END;
END;
/


-- Testando a procedure CREDENCIAR_COMUNIDADE
BEGIN
    CREDENCIAR_COMUNIDADE('123.456.789-11', 'aaaa', 'Especie1', 'Comunidade1');

END;
/

-- b)
set serveroutput on;

CREATE OR REPLACE PROCEDURE removerFacaoDaNacao(
    nome_faccao IN NACAO_FACCAO.FACCAO%type
) as
begin
    -- Remove a facção da tabela NacaoFacao
    begin
        delete from nacao_faccao where faccao = nome_faccao;
        if SQL%ROWCOUNT = 0 then
            RAISE_APPLICATION_ERROR(-20004, 'Facção ' || nome_faccao || ' não encontrada na tabela NacaoFacao.');
        end if;
    EXCEPTION
        when OTHERS then
            RAISE_APPLICATION_ERROR(-20005, 'Erro ao remover facção ' || nome_faccao || ' da tabela NacaoFacao.');
    end;

    -- Remove a chave primária composta da tabela NacaoFacao
    begin
        EXECUTE IMMEDIATE 'ALTER TABLE NACAO_FACCAO DROP PRIMARY KEY';
    EXCEPTION
        when OTHERS then
            RAISE_APPLICATION_ERROR(-20006, 'Erro ao remover chave primária da tabela NacaoFacao.');
    end;

    DBMS_OUTPUT.PUT_LINE('Facção ' ||  nome_faccao || ' removida da tabela NacaoFacao com sucesso.');
EXCEPTION
    when OTHERS then
        DBMS_OUTPUT.PUT_LINE('Erro ao executar a procedure: ' || SQLERRM);
end removerFacaoDaNacao;
/

-- Testes
begin
    begin
        DBMS_OUTPUT.PUT_LINE('Teste 1:');
        removerFacaoDaNacao('nome_da_faccao');
    EXCEPTION
        when OTHERS then
            DBMS_OUTPUT.PUT_LINE('Erro no teste 1: ' || SQLERRM);
    end;
    
    begin
        DBMS_OUTPUT.PUT_LINE('Teste 2:');
        removerFacaoDaNacao('Faccao 1');
    EXCEPTION
        when OTHERS then
            DBMS_OUTPUT.PUT_LINE('Erro no teste 2: ' || SQLERRM);
    end;
end;

-- ****** Precisa depois ajustar certinho as permissoes para oficiais
-- Oficial
-- Conceder permissão de seleção (visualização) para todas as visualizações aos oficiais
-- criar papel
CREATE ROLE OFICIAL_ROLE;

GRANT SELECT ON V_FEDERACOES_NACOES TO OFICIAL;
GRANT SELECT ON V_NACOES_FACCOES TO OFICIAL;
GRANT SELECT ON V_LIDERES TO OFICIAL;
GRANT SELECT ON V_ESPECIES_PLANETAS TO OFICIAL;
GRANT SELECT ON V_PLANETAS TO OFICIAL;
GRANT SELECT ON V_ESTRELAS_SISTEMAS TO OFICIAL;
GRANT SELECT ON V_COMUNIDADES TO OFICIAL;
GRANT SELECT ON V_HABITACOES TO OFICIAL;
GRANT SELECT ON V_DOMINANCIAS TO OFICIAL;

-- Associar ao papel
GRANT OFICIAL_ROLE TO OFICIAL;


--  Comandante

-- a)
-- b)

-- Cientista
-- *** Precisa Adicionar certinho depois os centistas 
-- Criação de um papel (role) para os cientistas
CREATE ROLE CIENTISTA_ROLE;

-- Conceder permissões de execução das procedures aos cientistas
GRANT EXECUTE ON CREATE_ESTRELA TO CIENTISTA_ROLE;
GRANT EXECUTE ON READ_ESTRELA TO CIENTISTA_ROLE;
GRANT EXECUTE ON UPDATE_ESTRELA TO CIENTISTA_ROLE;
GRANT EXECUTE ON DELETE_ESTRELA TO CIENTISTA_ROLE;

-- Associar cientistas ao papel criado
GRANT CIENTISTA_ROLE TO CIENTISTA;

