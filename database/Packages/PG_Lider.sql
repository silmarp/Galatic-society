DROP PACKAGE PG_Lider;

/* Package Lider de Faccao */
CREATE OR REPLACE PACKAGE PG_Lider AS
    -- Exceções
    e_not_lider EXCEPTION;
    e_atrib_notnull EXCEPTION;
    e_not_valid_comunidade EXCEPTION;
    e_not_valid_planeta EXCEPTION;
    e_faccao_not_found EXCEPTION;
    e_faccao_not_present EXCEPTION;
    
    PRAGMA EXCEPTION_INIT(e_atrib_notnull, -01400);
    PRAGMA EXCEPTION_INIT(e_not_valid_comunidade, -20122);
    PRAGMA EXCEPTION_INIT(e_not_valid_planeta, -20123);
    PRAGMA EXCEPTION_INIT(e_faccao_not_found, -20124);
    PRAGMA EXCEPTION_INIT(e_faccao_not_present, -20125);
    
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
    
    PROCEDURE insert_comunidade (
        p_user IN USERS.ID_User%TYPE,
        p_faccao IN Faccao.Nome%TYPE, 
        p_com_especie IN Comunidade.Especie%TYPE,
        p_com_nome IN Comunidade.Nome%TYPE
    );
  
    PROCEDURE delete_comunidade (
        p_user IN USERS.ID_User%TYPE,
        p_faccao IN Faccao.Nome%TYPE, 
        p_com_especie IN Comunidade.Especie%TYPE,
        p_com_nome IN Comunidade.Nome%TYPE
    );
    
    PROCEDURE remover_faccao_da_nacao (
        p_user USERS.ID_User%TYPE,
        p_nome_faccao IN NACAO_FACCAO.FACCAO%TYPE
    );

    FUNCTION relatorio_lider_faccao (
        p_user USERS.ID_User%TYPE,
        p_faccao FACCAO.NOME%TYPE
    ) RETURN sys_refcursor;
    
    FUNCTION is_lider (
        p_user USERS.ID_User%TYPE
    ) RETURN Faccao%ROWTYPE;
END PG_Lider;
/

CREATE OR REPLACE PACKAGE BODY PG_Lider AS
    PROCEDURE alterar_nome_faccao (
        p_user USERS.ID_User%TYPE,
        p_nome_faccao_atual IN FACCAO.NOME%TYPE,
        p_novo_nome IN FACCAO.NOME%TYPE
    ) IS
        v_lider_faccao Faccao%ROWTYPE;
        v_count INTEGER;
        BEGIN
            v_lider_faccao := is_lider(p_user);
            IF v_lider_faccao.lider IS NULL THEN RAISE e_not_lider; END IF;
    
            -- Verifica se o líder está autorizado para a facção específica
            SELECT COUNT(*) INTO v_count FROM FACCAO WHERE LIDER = v_lider_faccao.lider AND NOME = p_nome_faccao_atual;  
            IF v_count = 0 THEN RAISE e_not_lider; END IF;
    
            -- Atualiza o nome da facção e ajusta constraints
            BEGIN
                EXECUTE IMMEDIATE 'ALTER TABLE NACAO_FACCAO DISABLE CONSTRAINT FK_NF_FACCAO';
                EXECUTE IMMEDIATE 'ALTER TABLE PARTICIPA DISABLE CONSTRAINT FK_PARTICIPA_FACCAO';
                
                UPDATE FACCAO
                SET NOME = p_novo_nome
                WHERE LIDER = v_lider_faccao.lider AND NOME = p_nome_faccao_atual;
    
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
                RAISE_APPLICATION_ERROR(-20121, 'Acesso não autorizado ou facção não encontrada');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20120, 'Erro em alterar_nome_faccao ' || CHR(10) || SQLERRM);
    END alterar_nome_faccao;

    PROCEDURE indicar_novo_lider (
        p_user USERS.ID_User%TYPE,
        p_nome_faccao IN FACCAO.NOME%TYPE,
        p_novo_lider_cpi IN LIDER.CPI%TYPE
    ) IS
        v_lider_faccao Faccao%ROWTYPE;
        v_count INTEGER;
        BEGIN
            v_lider_faccao := is_lider(p_user);
            IF v_lider_faccao.lider IS NULL THEN RAISE e_not_lider; END IF;
    
            -- Verifica se o líder atual está autorizado para a facção específica
            SELECT COUNT(*) INTO v_count FROM FACCAO WHERE LIDER = v_lider_faccao.lider AND NOME = p_nome_faccao;
            IF v_count = 0 THEN RAISE e_not_lider; END IF;
    
            -- Verifica se o novo líder existe na tabela LIDER
            SELECT COUNT(*) INTO v_count FROM LIDER WHERE CPI = p_novo_lider_cpi;
    
            IF v_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20122, 'Novo líder não encontrado');
            END IF;
    
            -- Atualiza a facção com o novo líder
            BEGIN
                UPDATE FACCAO SET LIDER = p_novo_lider_cpi WHERE NOME = p_nome_faccao;
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    ROLLBACK;
                    RAISE_APPLICATION_ERROR(-20123, 'Erro ao atualizar líder da facção');
            END;
        EXCEPTION
            WHEN e_not_lider THEN
                RAISE_APPLICATION_ERROR(-20121, 'Acesso não autorizado ou facção não encontrada');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20120, 'Erro em indicar_novo_lider ' || CHR(10) || SQLERRM);
    END indicar_novo_lider;

    PROCEDURE credenciar_comunidade (
        p_user USERS.ID_User%TYPE,
        p_nome_faccao IN FACCAO.NOME%TYPE,
        p_especie IN COMUNIDADE.ESPECIE%TYPE,
        p_nome_comunidade IN COMUNIDADE.NOME%TYPE
    ) IS
        v_lider_faccao Faccao%ROWTYPE;
        v_count INTEGER;
        v_planeta VARCHAR2(15);
        v_nacao VARCHAR2(15);
        BEGIN
            v_lider_faccao := is_lider(p_user);
            IF v_lider_faccao.lider IS NULL THEN RAISE e_not_lider; END IF;
    
            -- Verifica se o líder atual está autorizado para a facção específica
            SELECT COUNT(*) INTO v_count FROM FACCAO WHERE LIDER = v_lider_faccao.lider AND NOME = p_nome_faccao;
            IF v_count = 0 THEN RAISE e_not_lider; END IF;
    
            -- Verifica se a comunidade existe e obtém o planeta onde ela habita
            BEGIN
                SELECT PLANETA INTO v_planeta
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
                SELECT d.NACAO INTO v_nacao
                FROM DOMINANCIA d JOIN NACAO_FACCAO nf ON d.NACAO = nf.NACAO
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
                    RAISE_APPLICATION_ERROR(-20124, 'Erro ao credenciar nova comunidade');
            END;
        EXCEPTION
            WHEN e_not_lider THEN
                RAISE_APPLICATION_ERROR(-20121, 'Acesso não autorizado ou facção não encontrada');
            WHEN e_not_valid_comunidade THEN
                RAISE_APPLICATION_ERROR(-20122, 'Comunidade não encontrada');
            WHEN e_not_valid_planeta THEN
                RAISE_APPLICATION_ERROR(-20123, 'Planeta não dominado pela facção');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20120, 'Erro em credenciar_comunidade ' || CHR(10) || SQLERRM);
    END credenciar_comunidade;
    
    PROCEDURE insert_comunidade (
        p_user IN USERS.ID_User%TYPE,
        p_faccao IN Faccao.Nome%TYPE, 
        p_com_especie IN Comunidade.Especie%TYPE,
        p_com_nome IN Comunidade.Nome%TYPE
    ) AS
        v_lider_faccao Faccao%ROWTYPE;
        v_count INTEGER;
        v_valida NUMBER;
        BEGIN
            v_lider_faccao := is_lider(p_user);
            IF v_lider_faccao.lider IS NULL THEN RAISE e_not_lider; END IF;
    
            -- Verifica se o líder atual está autorizado para a facção específica
            SELECT COUNT(*) INTO v_count FROM FACCAO WHERE LIDER = v_lider_faccao.lider AND NOME = p_faccao;
            IF v_count = 0 THEN RAISE e_not_lider; END IF;
            
            SELECT 1 INTO v_valida 
                FROM V_LIDER_FACCAO
                WHERE LIDER = v_lider_faccao.lider AND COM_ESPECIE = p_com_especie AND COM_NOME = p_com_nome
                FETCH FIRST 1 ROWS ONLY;
            INSERT INTO V_LIDER_FACCAO (FACCAO, COM_ESPECIE, COM_NOME)
                VALUES (v_lider_faccao.nome, p_com_especie, p_com_nome);
            COMMIT;
        EXCEPTION 
            WHEN e_not_lider THEN
                RAISE_APPLICATION_ERROR(-20121, 'Acesso não autorizado ou facção não encontrada');
            WHEN e_not_valid_comunidade THEN
                RAISE_APPLICATION_ERROR(-20122, 'Comunidade não encontrada');
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20125, 'A comunidade [' || p_com_nome || '] da especie [' || p_com_especie 
                    || '] nao habita planetas dominados por nacoes onde a faccao [' || p_faccao || ']' || ' esta presente/credenciada' || CHR(10));
            WHEN DUP_VAL_ON_INDEX THEN
                RAISE_APPLICATION_ERROR(-20126, 'A comunidade [' || p_com_nome || '] da especie [' || p_com_especie
                    || '] ja participa da faccao [' || p_faccao || ']' || CHR(10));
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20120, 'Erro em insert_comunidade' || CHR(10) || SQLERRM);
    END insert_comunidade;
    
    PROCEDURE delete_comunidade (
        p_user IN USERS.ID_User%TYPE,
        p_faccao IN Faccao.Nome%TYPE, 
        p_com_especie IN Comunidade.Especie%TYPE,
        p_com_nome IN Comunidade.Nome%TYPE
    ) AS
        v_lider_faccao Faccao%ROWTYPE;
        v_count INTEGER;
        v_valida NUMBER;
    BEGIN
        v_lider_faccao := is_lider(p_user);
        IF v_lider_faccao.lider IS NULL THEN RAISE e_not_lider; END IF;

        -- Verifica se o líder atual está autorizado para a facção específica
        SELECT COUNT(*) INTO v_count FROM FACCAO WHERE LIDER = v_lider_faccao.lider AND NOME = p_faccao;
        IF v_count = 0 THEN RAISE e_not_lider; END IF;
        
        SELECT 1 INTO v_valida 
            FROM V_LIDER_FACCAO
            WHERE PARTICIPA = p_faccao
            FETCH FIRST 1 ROWS ONLY;
        DELETE FROM V_LIDER_FACCAO WHERE
            FACCAO = p_faccao AND
            COM_ESPECIE = p_com_especie AND
            COM_NOME = p_com_nome;      
        COMMIT;
    EXCEPTION 
        WHEN e_not_lider THEN
            RAISE_APPLICATION_ERROR(-20121, 'Acesso não autorizado ou facção não encontrada');
        WHEN e_not_valid_comunidade THEN
            RAISE_APPLICATION_ERROR(-20122, 'Comunidade não encontrada');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20125, 'A comunidade [' || p_com_nome || '] da especie [' || p_com_especie
                || '] nao participa da faccao [' || p_faccao || ']' || CHR(10));
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Erro em delete_comunidade' || CHR(10) || SQLERRM);
    END delete_comunidade;
    
    PROCEDURE remover_faccao_da_nacao (
        p_user USERS.ID_User%TYPE,
        p_nome_faccao IN NACAO_FACCAO.FACCAO%TYPE
    ) IS
        v_lider_faccao Faccao%ROWTYPE;
        BEGIN
            v_lider_faccao := is_lider(p_user);
            IF v_lider_faccao.lider IS NULL THEN RAISE e_not_lider; END IF;
    
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
                    RAISE_APPLICATION_ERROR(-20127, 'Erro ao remover facção da nação');
            END;
        EXCEPTION
            WHEN e_not_lider THEN
                RAISE_APPLICATION_ERROR(-20121, 'Acesso não autorizado');
            WHEN e_faccao_not_found THEN
                RAISE_APPLICATION_ERROR(-20128, 'Facção não encontrada na tabela NacaoFacao');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20120, 'Erro em remover_faccao_da_nacao ' || CHR(10) || SQLERRM);
    END remover_faccao_da_nacao;

    FUNCTION relatorio_lider_faccao (
        p_user USERS.ID_User%TYPE,
        p_faccao FACCAO.NOME%TYPE
    ) RETURN sys_refcursor IS
        v_lider_faccao Faccao%ROWTYPE;
        c_report sys_refcursor;
        BEGIN 
            v_lider_faccao := is_lider(p_user);
            IF v_lider_faccao.lider IS NULL THEN RAISE e_not_lider; END IF;

            OPEN c_report FOR
                SELECT p.FACCAO, c.NOME, c.ESPECIE, c.QTD_HABITANTES, h.PLANETA, d.NACAO, e.ID_ESTRELA, s.NOME 
                    FROM participa p JOIN COMUNIDADE c ON p.COMUNIDADE = c.NOME AND p.ESPECIE = c.ESPECIE
                    JOIN HABITACAO h ON h.COMUNIDADE = c.NOME AND h.ESPECIE = c.ESPECIE 
                    JOIN DOMINANCIA d ON d.PLANETA = h.PLANETA
                    JOIN ORBITA_PLANETA op ON op.PLANETA = h.PLANETA 
                    JOIN ESTRELA e ON e.ID_ESTRELA = op.ESTRELA
                    JOIN SISTEMA s ON s.ESTRELA = e.ID_ESTRELA 
                    WHERE p.FACCAO = p_faccao;            
            RETURN c_report;
        
        EXCEPTION
            WHEN e_not_lider THEN
                RAISE_APPLICATION_ERROR(-20121, 'Acesso não autorizado');
            WHEN e_faccao_not_found THEN
                RAISE_APPLICATION_ERROR(-20128, 'Facção não encontrada na tabela NacaoFacao');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20120, 'Erro em relatorio_lider_faccao ' || CHR(10) || SQLERRM);
    END relatorio_lider_faccao;

    FUNCTION is_lider (
        p_user USERS.ID_User%TYPE
    ) RETURN Faccao%ROWTYPE 
    IS
        v_lider Lider.CPI%TYPE;
        v_faccao Faccao%ROWTYPE;
        BEGIN
            SELECT U.ID_LIDER INTO v_lider FROM USERS U WHERE U.ID_USER = p_user;
            SELECT * INTO v_faccao FROM FACCAO F WHERE F.LIDER = v_lider;
            RETURN v_faccao;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20125, 'Usuario nao e lider de faccao');
            WHEN e_atrib_notnull THEN
                RAISE_APPLICATION_ERROR(-20126, 'Valor obrigatorio nao fornecido');
            WHEN VALUE_ERROR THEN
                RAISE_APPLICATION_ERROR(-20127, 'Erro de atribuicao. Verifique os dados fornecidos');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20120, 'Erro em is_lider' || CHR(10) || SQLERRM);
    END is_lider;
END PG_Lider;