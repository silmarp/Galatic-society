from app.migrations.database import *

def changeFacLeader(user, faction, cpi_newLeader):
  db = DbConnection()

  try:
    db.getCursor().callproc('PG_Lider.indicar_novo_lider', [user, faction, cpi_newLeader])

    db.closeConnection()

    return True

  except oracledb.DatabaseError as e:
    flash(f"Erro ao indicar novo lider: {e.args[0].message}")
    print(f"Erro ao indicar novo lider: {e.args[0].message}")

    return False
