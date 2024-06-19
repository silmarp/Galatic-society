from app.migrations.database import *

def deleteStar(user, star_id):
  db = DbConnection()

  try:
    db.getCursor().callproc('PG_Cientista.deletar_estrela',
                            [user,
                             star_id
                             ])

    db.closeConnection()

    return True

  except oracledb.DatabaseError as e:
    flash(f"Erro ao deletar estrela: {e.args[0].message}")
    print(f"Erro ao deletar estrela: {e.args[0].message}")

    return False

