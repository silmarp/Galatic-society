from app.migrations.database import *

def addDomination(user, planet, start_date, end_date=None):
  db = DbConnection()
  
  try:
    if end_date is None:
      db.getCursor().callproc('PG_COMANDANTE.insert_dominancia', [user, planet, start_date])
    else:
      db.getCursor().callproc('PG_COMANDANTE.insert_dominancia', [user, planet, start_date, end_date])

    db.closeConnection()

    return True

  except oracledb.DatabaseError as e:
    flash("Erro ao adicionar dominação: " + e.args[0].message)
    print("Erro ao adicionar dominação: " + e.args[0].message)

    return False

