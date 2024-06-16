DROP PACKAGE PG_Faccao;

/* Package Lider de Faccao */
CREATE OR REPLACE PACKAGE PG_Faccao AS
    -- Exceções
    e_not_lider EXCEPTION;
    e_atrib_notnull EXCEPTION;
    e_not_valid_comunidade EXCEPTION;
    e_not_valid_planeta EXCEPTION;
    e_faccao_not_found EXCEPTION;
    e_faccao_not_present EXCEPTION;
    
    PRAGMA EXCEPTION_INIT(e_atrib_notnull, -01400);
    PRAGMA EXCEPTION_INIT(e_not_valid_comunidade, -20002);
    PRAGMA EXCEPTION_INIT(e_not_valid_planeta, -20003);
    PRAGMA EXCEPTION_INIT(e_faccao_not_found, -20004);
    PRAGMA EXCEPTION_INIT(e_faccao_not_present, -20005);
    
    -- Procedimentos
    PROCEDURE alterar_nome_faccao (
        p_user USERS.ID_User%TYPE,
        p_nome_faccao_atual IN FACCAO.NOME%TYPE,
        p_novo_nome IN FACCAO.NOME%TYPE
    );

    PROCEDURE indicar_novo_lider (
        p_user USERS.ID_User%TYPE,
        p_nome_faccao IN FACCAO.NOME%TYPE,
        p_novo_lider_cpi IN LIDER.CPI%TYPE
    );

    PROCEDURE credenciar_comunidade (
        p_user USERS.ID_User%TYPE,
        p_nome_faccao IN FACCAO.NOME%TYPE,
        p_especie IN COMUNIDADE.ESPECIE%TYPE,
        p_nome_comunidade IN COMUNIDADE.NOME%TYPE
    );

    PROCEDURE remover_faccao_da_nacao (
        p_user USERS.ID_User%TYPE,
        p_nome_faccao IN NACAO_FACCAO.FACCAO%TYPE
    );
END PG_Faccao;
/

CREATE OR REPLACE PACKAGE BODY PG_Faccao AS

    PROCEDURE alterar_nome_faccao (
        p_user USERS.ID_User%TYPE,
        p_nome_faccao_atual IN FACCAO.NOME%TYPE,
        p_novo_nome IN FACCAO.NOME%TYPE
    ) IS
        v_lider Lider%ROWTYPE;
        v_count INTEGER;
    BEGIN
        v_lider := PG_Users.get_user_info(p_user);
        IF v_lider.cargo != 'LIDER' THEN
            RAISE e_not_lider;
        END IF;

        -- Verifica se o líder está autorizado para a facção específica
        SELECT COUNT(*)
        INTO v_count
        FROM FACCAO
        WHERE LIDER = v_lider.cpi AND NOME = p_nome_faccao_atual;

        IF v_count = 0 THEN
            RAISE e_not_lider;
        END IF;

        -- Atualiza o nome da facção e ajusta constraints
        BEGIN
            EXECUTE IMMEDIATE 'ALTER TABLE NACAO_FACCAO DISABLE CONSTRAINT FK_NF_FACCAO';
            EXECUTE IMMEDIATE 'ALTER TABLE PARTICIPA DISABLE CONSTRAINT FK_PARTICIPA_FACCAO';
            
            UPDATE FACCAO
            SET NOME = p_novo_nome
            WHERE LIDER = v_lider.cpi AND NOME = p_nome_faccao_atual;

            UPDATE NACAO_FACCAO
            SET FACCAO = p_novo_nome
            WHERE FACCAO = p_nome_faccao_atual;

            UPDATE PARTICIPA
            SET FACCAO = p_novo_nome
            WHERE FACCAO = p_nome_faccao_atual;

            EXECUTE IMMEDIATE 'ALTER TABLE NACAO_FACCAO ENABLE CONSTRAINT FK_NF_FACCAO';
            EXECUTE IMMEDIATE 'ALTER TABLE PARTICIPA ENABLE CONSTRAINT FK_PARTICIPA_FACCAO';

            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                EXECUTE IMMEDIATE 'ALTER TABLE NACAO_FACCAO ENABLE CONSTRAINT FK_NF_FACCAO';
                EXECUTE IMMEDIATE 'ALTER TABLE PARTICIPA ENABLE CONSTRAINT FK_PARTICIPA_FACCAO';
                ROLLBACK;
                RAISE_APPLICATION_ERROR(-20002, 'Erro ao atualizar nome da facção');
        END;
    EXCEPTION
        WHEN e_not_lider THEN
            RAISE_APPLICATION_ERROR(-20001, 'Acesso não autorizado ou facção não encontrada');
    END alterar_nome_faccao;

    PROCEDURE indicar_novo_lider (
        p_user USERS.ID_User%TYPE,
        p_nome_faccao IN FACCAO.NOME%TYPE,
        p_novo_lider_cpi IN LIDER.CPI%TYPE
    ) IS
        v_lider Lider%ROWTYPE;
        v_count INTEGER;
    BEGIN
        v_lider := PG_Users.get_user_info(p_user);
        IF v_lider.cargo != 'LIDER' THEN
            RAISE e_not_lider;
        END IF;

        -- Verifica se o líder atual está autorizado para a facção específica
        SELECT COUNT(*)
        INTO v_count
        FROM FACCAO
        WHERE LIDER = v_lider.cpi AND NOME = p_nome_faccao;

        IF v_count = 0 THEN
            RAISE e_not_lider;
        END IF;

        -- Verifica se o novo líder existe na tabela LIDER
        SELECT COUNT(*)
        INTO v_count
        FROM LIDER
        WHERE CPI = p_novo_lider_cpi;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Novo líder não encontrado');
        END IF;

        -- Atualiza a facção com o novo líder
        BEGIN
            UPDATE FACCAO
            SET LIDER = p_novo_lider_cpi
            WHERE NOME = p_nome_faccao;

            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE_APPLICATION_ERROR(-20003, 'Erro ao atualizar líder da facção');
        END;
    EXCEPTION
        WHEN e_not_lider THEN
            RAISE_APPLICATION_ERROR(-20001, 'Acesso não autorizado ou facção não encontrada');
    END indicar_novo_lider;

    PROCEDURE credenciar_comunidade (
        p_user USERS.ID_User%TYPE,
        p_nome_faccao IN FACCAO.NOME%TYPE,
        p_especie IN COMUNIDADE.ESPECIE%TYPE,
        p_nome_comunidade IN COMUNIDADE.NOME%TYPE
    ) IS
        v_lider Lider%ROWTYPE;
        v_count INTEGER;
        v_planeta VARCHAR2(15);
        v_nacao VARCHAR2(15);
    BEGIN
        v_lider := PG_Users.get_user_info(p_user);
        IF v_lider.cargo != 'LIDER' THEN
            RAISE e_not_lider;
        END IF;

        -- Verifica se o líder está autorizado para a facção específica
        SELECT COUNT(*)
        INTO v_count
        FROM FACCAO f
        WHERE f.LIDER = v_lider.cpi AND f.NOME = p_nome_faccao;

        IF v_count = 0 THEN
            RAISE e_not_lider;
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
                RAISE e_not_valid_comunidade;
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
                RAISE e_not_valid_planeta;
        END;

        -- Insere a nova comunidade na tabela PARTICIPA
        BEGIN
            INSERT INTO PARTICIPA (FACCAO, ESPECIE, COMUNIDADE)
            VALUES (p_nome_faccao, p_especie, p_nome_comunidade);

            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE_APPLICATION_ERROR(-20004, 'Erro ao credenciar nova comunidade');
        END;
    EXCEPTION
        WHEN e_not_lider THEN
            RAISE_APPLICATION_ERROR(-20001, 'Acesso não autorizado ou facção não encontrada');
        WHEN e_not_valid_comunidade THEN
            RAISE_APPLICATION_ERROR(-20002, 'Comunidade não encontrada');
        WHEN e_not_valid_planeta THEN
            RAISE_APPLICATION_ERROR(-20003, 'Planeta não dominado pela facção');
    END credenciar_comunidade;

    PROCEDURE remover_faccao_da_nacao (
        p_user USERS.ID_User%TYPE,
        p_nome_faccao IN NACAO_FACCAO.FACCAO%TYPE
    ) IS
        v_lider Lider%ROWTYPE;
    BEGIN
        v_lider := PG_Users.get_user_info(p_user);
        IF v_lider.cargo != 'LIDER' THEN
            RAISE e_not_lider;
        END IF;

        -- Remove a facção da tabela NacaoFacao
        BEGIN
            DELETE FROM NACAO_FACCAO WHERE FACCAO = p_nome_faccao;
            IF SQL%ROWCOUNT = 0 THEN
                RAISE e_faccao_not_found;
            END IF;
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE_APPLICATION_ERROR(-20005, 'Erro ao remover facção da nação');
        END;
    EXCEPTION
        WHEN e_not_lider THEN
            RAISE_APPLICATION_ERROR(-20001, 'Acesso não autorizado');
        WHEN e_faccao_not_found THEN
            RAISE_APPLICATION_ERROR(-20004, 'Facção não encontrada na tabela NacaoFacao');
    END remover_faccao_da_nacao;

END PG_Faccao;
/
