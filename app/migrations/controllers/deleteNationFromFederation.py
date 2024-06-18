from app.migrations.database import *

def deleteNationFromFederation(user):
  db = DbConnection()

  try:
    db.getCursor().callproc('PG_COMANDANTE.delete_federacao', [user])

    db.closeConnection()

    return True

  except oracledb.DatabaseError as e:
    flash(f"Erro ao excluir nação da federação: {e.args[0].message}")
    print(f"Erro ao excluir nação da federação: {e.args[0].message}")

    return False
