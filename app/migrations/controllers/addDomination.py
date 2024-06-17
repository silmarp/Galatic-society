from app.migrations.database import *

def addDomination(nation, planet, start_date, end_date=None):
  db = DbConnection()

  print("ENTROU NO ADD DOMINATION")
  
  try:
    if (end_date == None):
      db.getCursor().callproc('PG_COMANDANTE.add_domination', [nation, planet, start_date])
    else:
      db.getCursor().callproc('PG_COMANDANTE.add_domination', [nation, planet, start_date, end_date])

    db.closeConnection()

    print("DEU CERTO")

    return True

  except oracledb.DatabaseError as e:
    flash("Erro ao adicionar dominação: " + e.args[0].message)
    print("Erro ao adicionar dominação: " + e.args[0].message)

    return False

