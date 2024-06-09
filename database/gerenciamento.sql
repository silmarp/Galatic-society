-- Líder de facção

-- a)
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

--- Dado a nossa interpretação do item 1.b, implementamos para que todas as tuplas com a faccao escolhida seja removida

--- Teste 1:
--- Erro ao executar a procedure: ORA-20005: Erro ao remover facção nome_da_faccao da tabela NacaoFacao.
--- Teste 2:
--- Facção Faccao 1 removida da tabela NacaoFacao com sucesso.

-- Oficial

--  Comandante

-- a)
-- b)

-- Cientista
