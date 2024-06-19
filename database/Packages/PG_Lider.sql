DROP PACKAGE PG_Lider;

/* Package Lider de Faccao */
CREATE OR REPLACE PACKAGE PG_Lider AS
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
        p_com_especie IN Comunidade.Especie%TYPE,
        p_com_nome IN Comunidade.Nome%TYPE
    );
  
    PROCEDURE delete_comunidade (
        p_user IN USERS.ID_User%TYPE,
        p_com_especie IN Comunidade.Especie%TYPE,
        p_com_nome IN Comunidade.Nome%TYPE
    );
    
    PROCEDURE remover_faccao_da_nacao (
        p_user IN USERS.ID_User%TYPE,
        p_nacao IN NACAO_FACCAO.NACAO%TYPE
    );

    FUNCTION relatorio_lider_faccao (
        p_user USERS.ID_User%TYPE,
        p_faccao FACCAO.NOME%TYPE,
        p_grouping char
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
    
            SELECT COUNT(*) INTO v_count FROM FACCAO WHERE LIDER = v_lider_faccao.lider AND NOME = p_nome_faccao_atual;  
            IF v_count = 0 THEN RAISE e_not_lider; END IF;
    
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
                    RAISE_APPLICATION_ERROR(-20129, 'Erro ao atualizar nome da faccao');
            END;
        EXCEPTION
            WHEN e_not_lider THEN
                RAISE_APPLICATION_ERROR(-20121, 'Usuario nao e lider de faccao');
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
    
            SELECT COUNT(*) INTO v_count FROM FACCAO WHERE LIDER = v_lider_faccao.lider AND NOME = p_nome_faccao;
            IF v_count = 0 THEN RAISE e_not_lider; END IF;
    
            SELECT COUNT(*) INTO v_count FROM LIDER WHERE CPI = p_novo_lider_cpi;
            IF v_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20122, 'Novo lider nao encontrado');
            END IF;
    
            BEGIN
                UPDATE FACCAO SET LIDER = p_novo_lider_cpi WHERE NOME = p_nome_faccao;
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    ROLLBACK;
                    RAISE_APPLICATION_ERROR(-20123, 'Erro ao atualizar lider da faccao');
            END;
        EXCEPTION
            WHEN e_not_lider THEN
                RAISE_APPLICATION_ERROR(-20121, 'Usuario nao e lider de faccao');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20120, 'Erro em indicar_novo_lider ' || CHR(10) || SQLERRM);
    END indicar_novo_lider;
    
    PROCEDURE insert_comunidade (
        p_user IN USERS.ID_User%TYPE,
        p_com_especie IN Comunidade.Especie%TYPE,
        p_com_nome IN Comunidade.Nome%TYPE
    ) AS
        v_lider_faccao Faccao%ROWTYPE;
        v_count INTEGER;
        v_valida NUMBER;
        BEGIN
            v_lider_faccao := is_lider(p_user);
            IF v_lider_faccao.lider IS NULL THEN RAISE e_not_lider; END IF;
    
            SELECT COUNT(*) INTO v_count FROM FACCAO WHERE LIDER = v_lider_faccao.lider AND NOME = v_lider_faccao.nome;
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
                RAISE_APPLICATION_ERROR(-20121, 'Usuario nao e lider de faccao');
            WHEN e_not_valid_comunidade THEN
                RAISE_APPLICATION_ERROR(-20122, 'Comunidade nao encontrada');
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20125, 'A comunidade [' || p_com_nome || '] da especie [' || p_com_especie 
                    || '] nao habita planetas dominados por nacoes onde a faccao [' || v_lider_faccao.nome || ']' || ' esta presente/credenciada' || CHR(10));
            WHEN DUP_VAL_ON_INDEX THEN
                RAISE_APPLICATION_ERROR(-20126, 'A comunidade [' || p_com_nome || '] da especie [' || p_com_especie
                    || '] ja participa da faccao [' || v_lider_faccao.nome || ']' || CHR(10));
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20120, 'Erro em insert_comunidade' || CHR(10) || SQLERRM);
    END insert_comunidade;
    
    PROCEDURE delete_comunidade (
        p_user IN USERS.ID_User%TYPE,
        p_com_especie IN Comunidade.Especie%TYPE,
        p_com_nome IN Comunidade.Nome%TYPE
    ) AS
        v_lider_faccao Faccao%ROWTYPE;
        v_count INTEGER;
        v_valida NUMBER;
    BEGIN
        v_lider_faccao := is_lider(p_user);
        IF v_lider_faccao.lider IS NULL THEN RAISE e_not_lider; END IF;

        SELECT COUNT(*) INTO v_count FROM FACCAO WHERE LIDER = v_lider_faccao.lider AND NOME = v_lider_faccao.nome;
        IF v_count = 0 THEN RAISE e_not_lider; END IF;
        
        SELECT 1 INTO v_valida 
            FROM V_LIDER_FACCAO
            WHERE PARTICIPA = v_lider_faccao.nome
            FETCH FIRST 1 ROWS ONLY;
        DELETE FROM V_LIDER_FACCAO WHERE
            FACCAO = v_lider_faccao.nome AND
            COM_ESPECIE = p_com_especie AND
            COM_NOME = p_com_nome;      
        COMMIT;
    EXCEPTION 
        WHEN e_not_lider THEN
            RAISE_APPLICATION_ERROR(-20121, 'Usuario nao e lider de faccao');
        WHEN e_not_valid_comunidade THEN
            RAISE_APPLICATION_ERROR(-20122, 'Comunidade nao encontrada');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20125, 'A comunidade [' || p_com_nome || '] da especie [' || p_com_especie
                || '] nao participa da faccao [' || v_lider_faccao.nome || ']' || CHR(10));
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Erro em delete_comunidade' || CHR(10) || SQLERRM);
    END delete_comunidade;
    
    PROCEDURE remover_faccao_da_nacao (
        p_user IN USERS.ID_User%TYPE,
        p_nacao IN NACAO_FACCAO.NACAO%TYPE
    ) IS
        v_lider_faccao Faccao%ROWTYPE;
        BEGIN
            v_lider_faccao := is_lider(p_user);
            IF v_lider_faccao.lider IS NULL THEN RAISE e_not_lider; END IF;
            
            BEGIN
                DELETE FROM NACAO_FACCAO WHERE FACCAO = v_lider_faccao.nome AND NACAO = p_nacao;
                IF SQL%ROWCOUNT = 0 THEN
                    RAISE e_faccao_not_found;
                END IF;
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    ROLLBACK;
                    RAISE_APPLICATION_ERROR(-20127, 'Erro ao remover facao da nacao');
            END;
        EXCEPTION
            WHEN e_not_lider THEN
                RAISE_APPLICATION_ERROR(-20121, 'Usuario nao e lider de faccao');
            WHEN e_faccao_not_found THEN
                RAISE_APPLICATION_ERROR(-20128, 'Faccao nao encontrada na tabela Nacao_Faccao');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20120, 'Erro em remover_faccao_da_nacao ' || CHR(10) || SQLERRM);
    END remover_faccao_da_nacao;

    FUNCTION relatorio_lider_faccao (
        p_user USERS.ID_User%TYPE,
        p_faccao FACCAO.NOME%TYPE,
        p_grouping char
    ) RETURN sys_refcursor IS
        v_lider_faccao Faccao%ROWTYPE;
        c_report sys_refcursor;
        BEGIN 
            v_lider_faccao := is_lider(p_user);
            IF v_lider_faccao.lider IS NULL THEN RAISE e_not_lider; END IF;

            IF p_grouping = 'N' THEN	
                OPEN c_report FOR 
                    SELECT * FROM V_RL_LIDER WHERE faccao = p_faccao ORDER BY nacao;	

            ELSIF p_grouping = 'E' THEN	
                OPEN c_report FOR 
                    SELECT * FROM V_RL_LIDER WHERE faccao = p_faccao ORDER BY especie;	
                
            ELSIF p_grouping = 'P' THEN	
                OPEN c_report FOR 
                    SELECT * FROM V_RL_LIDER WHERE faccao = p_faccao ORDER BY planeta;	
                
            ELSIF p_grouping = 'S' THEN	
                OPEN c_report FOR 
                    SELECT * FROM V_RL_LIDER WHERE faccao = p_faccao ORDER BY estrela;		
            
            ELSE
                OPEN c_report FOR 
                    SELECT * FROM V_RL_LIDER WHERE faccao = p_faccao;	
                
            END IF;

            RETURN c_report;
        EXCEPTION
            WHEN e_not_lider THEN
                RAISE_APPLICATION_ERROR(-20121, 'Usuario nao e lider de faccao');
            WHEN e_faccao_not_found THEN
                RAISE_APPLICATION_ERROR(-20128, 'Faccao nao encontrada na tabela Nacao_Faccao');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20120, 'Erro em remover_faccao_da_nacao ' || CHR(10) || SQLERRM);
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