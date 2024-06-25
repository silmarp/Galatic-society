CREATE OR REPLACE TRIGGER TG_INSERT_PARTICIPA
INSTEAD OF INSERT OR UPDATE OR DELETE ON V_LIDER_FACCAO
FOR EACH ROW
    
BEGIN
    IF INSERTING THEN 
        INSERT INTO PARTICIPA (FACCAO, ESPECIE, COMUNIDADE) VALUES (:new.FACCAO, :new.COM_ESPECIE, :new.COM_NOME);
    ELSIF DELETING THEN
        DELETE FROM PARTICIPA P WHERE P.FACCAO = :old.FACCAO AND P.ESPECIE = :old.COM_ESPECIE AND P.COMUNIDADE = :old.COM_NOME;
    END IF;
END TG_Insert_Participa;