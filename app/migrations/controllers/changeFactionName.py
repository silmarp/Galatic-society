from app.migrations.database import *

def changeFactionName(user, currentName, newName):
  db = DbConnection()

  try:
    db.getCursor().callproc('PG_Lider.alterar_nome_faccao', [user, currentName, newName])

    db.closeConnection()

    return True

  except oracledb.DatabaseError as e:
    flash(f"Erro ao atualizar nome da facção: {e.args[0].message}")
    print(f"Erro ao atualizar nome da facção: {e.args[0].message}")

    return False
