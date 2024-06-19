from app.migrations.database import *

def createFederation(user, federation, startDate=None):
  db = DbConnection()

  try:
    if startDate is None:
      db.getCursor().callproc('PG_Comandante.create_federacao', [user, federation])
    else:
      db.getCursor().callproc('PG_Comandante.create_federacao', [user, federation, startDate])

    db.closeConnection()

    return True

  except oracledb.DatabaseError as e:
    flash(f"Erro ao adicionar federação: {e.args[0].message}")
    print(f"Erro ao adicionar federação: {e.args[0].message}")

    return False
