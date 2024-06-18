DROP PACKAGE PG_Cientista;

/* Package Cientista */
CREATE OR REPLACE PACKAGE PG_Cientista AS

    -- Exceções
    e_not_cientista EXCEPTION;

    -- Procedimentos de CRUD de estrelas
    PROCEDURE criar_estrela (
        p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE,
        p_nome IN ESTRELA.NOME%TYPE,
        p_classificacao IN ESTRELA.CLASSIFICACAO%TYPE,
        p_massa IN ESTRELA.MASSA%TYPE,
        p_x IN ESTRELA.X%TYPE,
        p_y IN ESTRELA.Y%TYPE,
        p_z IN ESTRELA.Z%TYPE
    );

    PROCEDURE atualizar_estrela (
        p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE,
        p_nome IN ESTRELA.NOME%TYPE,
        p_classificacao IN ESTRELA.CLASSIFICACAO%TYPE,
        p_massa IN ESTRELA.MASSA%TYPE,
        p_x IN ESTRELA.X%TYPE,
        p_y IN ESTRELA.Y%TYPE,
        p_z IN ESTRELA.Z%TYPE
    );

    FUNCTION ler_estrela (
        p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE
    ) RETURN ESTRELA%ROWTYPE;

    PROCEDURE deletar_estrela (
        p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE
    );

    -- Procedimentos para relatórios
    PROCEDURE relatorio_estrelas (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    );

    PROCEDURE relatorio_planetas (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    );

    PROCEDURE relatorio_sistemas (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    );

END PG_Cientista;
/

CREATE OR REPLACE PACKAGE BODY PG_Cientista AS

    PROCEDURE verificar_cientista (
        p_user USERS.ID_User%TYPE
    ) IS
        v_user LIDER%ROWTYPE;
    BEGIN
        v_user := PG_Users.get_user_info(p_user);
        -- Verifica se o usuário é um cientista
        IF v_user.CARGO != 'CIENTISTA' THEN
            RAISE e_not_cientista;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Usuário não encontrado.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20003, 'Erro ao verificar cientista: ' || SQLERRM);
    END verificar_cientista;

    PROCEDURE criar_estrela (
        p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE,
        p_nome IN ESTRELA.NOME%TYPE,
        p_classificacao IN ESTRELA.CLASSIFICACAO%TYPE,
        p_massa IN ESTRELA.MASSA%TYPE,
        p_x IN ESTRELA.X%TYPE,
        p_y IN ESTRELA.Y%TYPE,
        p_z IN ESTRELA.Z%TYPE
    ) IS
    BEGIN
        -- Verifica se o usuário é um cientista
        verificar_cientista(USER);

        -- Insere a nova estrela
        INSERT INTO ESTRELA (ID_ESTRELA, NOME, CLASSIFICACAO, MASSA, X, Y, Z)
        VALUES (p_id_estrela, p_nome, p_classificacao, p_massa, p_x, p_y, p_z);

        COMMIT;
    EXCEPTION
        WHEN e_not_cientista THEN
            RAISE_APPLICATION_ERROR(-20001, 'Apenas cientistas podem criar estrelas.');
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20004, 'ID de estrela já existe.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20005, 'Erro ao criar estrela: ' || SQLERRM);
    END criar_estrela;

    PROCEDURE atualizar_estrela (
        p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE,
        p_nome IN ESTRELA.NOME%TYPE,
        p_classificacao IN ESTRELA.CLASSIFICACAO%TYPE,
        p_massa IN ESTRELA.MASSA%TYPE,
        p_x IN ESTRELA.X%TYPE,
        p_y IN ESTRELA.Y%TYPE,
        p_z IN ESTRELA.Z%TYPE
    ) IS
    BEGIN
        -- Verifica se o usuário é um cientista
        verificar_cientista(USER);

        -- Atualiza os dados da estrela
        UPDATE ESTRELA
        SET NOME = p_nome,
            CLASSIFICACAO = p_classificacao,
            MASSA = p_massa,
            X = p_x,
            Y = p_y,
            Z = p_z
        WHERE ID_ESTRELA = p_id_estrela;

        COMMIT;
    EXCEPTION
        WHEN e_not_cientista THEN
            RAISE_APPLICATION_ERROR(-20001, 'Apenas cientistas podem atualizar estrelas.');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20006, 'Estrela não encontrada para atualização.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20007, 'Erro ao atualizar estrela: ' || SQLERRM);
    END atualizar_estrela;

    FUNCTION ler_estrela (
        p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE
    ) RETURN ESTRELA%ROWTYPE IS
        v_estrela ESTRELA%ROWTYPE;
    BEGIN
        -- Verifica se o usuário é um cientista
        verificar_cientista(USER);

        -- Obtém os dados da estrela
        SELECT *
        INTO v_estrela
        FROM ESTRELA
        WHERE ID_ESTRELA = p_id_estrela;

        RETURN v_estrela;
    EXCEPTION
        WHEN e_not_cientista THEN
            RAISE_APPLICATION_ERROR(-20001, 'Apenas cientistas podem ler estrelas.');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20008, 'Estrela não encontrada.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20009, 'Erro ao ler estrela: ' || SQLERRM);
    END ler_estrela;

    PROCEDURE deletar_estrela (
        p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE
    ) IS
    BEGIN
        -- Verifica se o usuário é um cientista
        verificar_cientista(USER);

        -- Deleta a estrela
        DELETE FROM ESTRELA
        WHERE ID_ESTRELA = p_id_estrela;

        COMMIT;
    EXCEPTION
        WHEN e_not_cientista THEN
            RAISE_APPLICATION_ERROR(-20001, 'Apenas cientistas podem deletar estrelas.');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20010, 'Estrela não encontrada para deleção.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20011, 'Erro ao deletar estrela: ' || SQLERRM);
    END deletar_estrela;

    PROCEDURE relatorio_estrelas (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        -- Verifica se o usuário é um cientista
        verificar_cientista(p_user);

        -- Chama o procedimento do pacote RL_Cientista para gerar o relatório de estrelas
        p_cursor := RL_Cientista.CURSOR_RELATORIO_ESTRELAS;
    EXCEPTION
        WHEN e_not_cientista THEN
            RAISE_APPLICATION_ERROR(-20001, 'Apenas cientistas podem gerar o relatório de estrelas.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20012, 'Erro ao gerar relatório de estrelas: ' || SQLERRM);
    END relatorio_estrelas;

    PROCEDURE relatorio_planetas (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        -- Verifica se o usuário é um cientista
        verificar_cientista(p_user);

        -- Chama o procedimento do pacote RL_Cientista para gerar o relatório de planetas
        p_cursor := RL_Cientista.CURSOR_RELATORIO_PLANETAS;
    EXCEPTION
        WHEN e_not_cientista THEN
            RAISE_APPLICATION_ERROR(-20001, 'Apenas cientistas podem gerar o relatório de planetas.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20013, 'Erro ao gerar relatório de planetas: ' || SQLERRM);
    END relatorio_planetas;

    PROCEDURE relatorio_sistemas (
        p_user IN LIDER.CPI%TYPE,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        -- Verifica se o usuário é um cientista
        verificar_cientista(p_user);

        -- Chama o procedimento do pacote RL_Cientista para gerar o relatório de sistemas
        p_cursor := RL_Cientista.CURSOR_RELATORIO_SISTEMAS;
    EXCEPTION
        WHEN e_not_cientista THEN
            RAISE_APPLICATION_ERROR(-20001, 'Apenas cientistas podem gerar o relatório de sistemas.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20014, 'Erro ao gerar relatório de sistemas: ' || SQLERRM);
    END relatorio_sistemas;

END PG_Cientista;
/




