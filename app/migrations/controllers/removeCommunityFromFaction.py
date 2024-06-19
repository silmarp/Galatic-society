from app.migrations.database import *

def removeCommunityFromFaction(user, species, community):
  db = DbConnection()

  try:
    db.getCursor().callproc('PG_Lider.delete_comunidade', [user, species, community])

    db.closeConnection()

    return True

  except oracledb.DatabaseError as e:
    flash(f"Erro ao descredenciar comunidade: {e.args[0].message}")
    print(f"Erro ao descredenciar comunidade: {e.args[0].message}")

    return False
