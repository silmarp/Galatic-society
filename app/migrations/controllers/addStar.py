from app.migrations.database import *

def addStar(star_id, nome, classificacao, massa, x, y, z):
  db = DbConnection()

  try:
    db.getCursor().callproc('PG_Cientista.criar_estrela',
                            [star_id,
                             nome,
                             classificacao,
                             massa,
                             x,
                             y,
                             z
                            ])

    db.closeConnection()

    return True

  except oracledb.DatabaseError as e:
    flash(f"Erro ao adicionar estrela: {e.args[0].message}")
    print(f"Erro ao adicionar estrela: {e.args[0].message}")

    return False

