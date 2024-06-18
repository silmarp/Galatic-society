/* Script to run all addictional insertions */

SET ECHO ON
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

@inserts_orbita_estrela.sql
SAVEPOINT last_success;

@inserts_orbita_planeta.sql
SAVEPOINT last_success;

@inserts_sistema.sql
SAVEPOINT last_success;

@inserts_comunidade.sql
SAVEPOINT last_success;

@inserts_habitacao.sql
SAVEPOINT last_success;

@inserts_dominancia.sql
SAVEPOINT last_success;

@inserts_lider.sql
SAVEPOINT last_success;

@inserts_faccao.sql
SAVEPOINT last_success;

@inserts_nacao_faccao.sql
SAVEPOINT last_success;

@inserts_participa.sql
SAVEPOINT last_success;

COMMIT;
