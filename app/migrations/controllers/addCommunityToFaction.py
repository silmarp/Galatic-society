from app.migrations.database import *

def addCommunityToFaction(user, faction, species, community):
  db = DbConnection()

  try:
    db.getCursor().callproc('PG_Lider.credenciar_comunidade', [user, faction, species, community])

    db.closeConnection()

    return True

  except oracledb.DatabaseError as e:
    flash(f"Erro ao credenciar comunidade: {e.args[0].message}")
    print(f"Erro ao credenciar comunidade: {e.args[0].message}")

    return False
