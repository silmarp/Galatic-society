DROP PACKAGE PG_Cientista;

/* Package Cientista */
CREATE OR REPLACE PACKAGE PG_Cientista AS
    -- Exceções
    e_not_cientista EXCEPTION;

    -- Procedimentos de gerenciamento de estrelas
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

    PROCEDURE ler_estrela (
        p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE,
        p_nome IN OUT ESTRELA.NOME%TYPE,
        p_classificacao IN OUT ESTRELA.CLASSIFICACAO%TYPE,
        p_massa IN OUT ESTRELA.MASSA%TYPE,
        p_x IN OUT ESTRELA.X%TYPE,
        p_y IN OUT ESTRELA.Y%TYPE,
        p_z IN OUT ESTRELA.Z%TYPE
    );

    PROCEDURE deletar_estrela (
        p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE
    );

END PG_Cientista;
/

CREATE OR REPLACE PACKAGE BODY PG_Cientista AS

    PROCEDURE verificar_cientista (
        p_user IN LIDER.CPI%TYPE
    ) IS
        v_user LIDER%ROWTYPE;
    BEGIN
        -- Obtém as informações do usuário
        SELECT * INTO v_user FROM LIDER WHERE CPI = p_user;

        -- Verifica se o usuário é um cientista
        IF v_user.CARGO != 'CIENTISTA' THEN
            RAISE e_not_cientista;
        END IF;
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
    END atualizar_estrela;

    PROCEDURE ler_estrela (
        p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE,
        p_nome IN OUT ESTRELA.NOME%TYPE,
        p_classificacao IN OUT ESTRELA.CLASSIFICACAO%TYPE,
        p_massa IN OUT ESTRELA.MASSA%TYPE,
        p_x IN OUT ESTRELA.X%TYPE,
        p_y IN OUT ESTRELA.Y%TYPE,
        p_z IN OUT ESTRELA.Z%TYPE
    ) IS
    BEGIN
        -- Verifica se o usuário é um cientista
        verificar_cientista(USER);

        -- Obtém os dados da estrela
        SELECT NOME, CLASSIFICACAO, MASSA, X, Y, Z
        INTO p_nome, p_classificacao, p_massa, p_x, p_y, p_z
        FROM ESTRELA
        WHERE ID_ESTRELA = p_id_estrela;
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
    END deletar_estrela;

END PG_Cientista;
/
