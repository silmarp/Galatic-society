CREATE OR REPLACE PACKAGE RL_Oficial AS

    FUNCTION relatorioOficial (
        p_faccao FACCAO.NOME%TYPE,
        p_grouping char
    ) RETURN sys_refcursor;

END RL_Oficial;
/

CREATE OR REPLACE PACKAGE BODY RL_Oficial AS
    FUNCTION relatorioOficial ( p_faccao FACCAO.NOME%TYPE, p_grouping char ) RETURN sys_refcursor IS
        c_report sys_refcursor;
    BEGIN 
        IF p_grouping = 'F' THEN	
            OPEN c_report FOR 	
                SELECT * FROM V_RL_OFICIAL order BY faccao;
            
        ELSIF p_grouping = 'E' THEN	
            OPEN c_report FOR 
                SELECT * FROM V_RL_OFICIAL order BY especie;
            
        ELSIF p_grouping = 'P' THEN	
            OPEN c_report FOR 
                SELECT * FROM V_RL_OFICIAL order BY planeta;

        ELSIF p_grouping = 'S' THEN	
            OPEN c_report FOR 
                SELECT * FROM V_RL_OFICIAL order BY estrela;

        ELSE
            OPEN c_report FOR 
                    
        END IF;
        RETURN c_report;

    END relatorioOficial;
END RL_Oficial;
/
