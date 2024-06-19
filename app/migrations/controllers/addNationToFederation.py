from app.migrations.database import *

def addNationToFederation(user, federation):
  db = DbConnection()

  try:
    db.getCursor().callproc('PG_Comandante.include_federacao', [user, federation])

    db.closeConnection()

    return True

  except oracledb.DatabaseError as e:
    flash(f"Erro ao incluir nação na federação: {e.args[0].message}")
    print(f"Erro ao incluir nação na federação: {e.args[0].message}")

    return False
