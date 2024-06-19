from app.migrations.database import *
from app.migrations.utils import dbObj_to_dict

def getStar(user, star_id):
  db = DbConnection()

  tipo_retorno = db.getType("ESTRELA%ROWTYPE")

  try:
    response = db.getCursor().callfunc('PG_Cientista.ler_estrela', tipo_retorno, [user, star_id])
    objResponse = dbObj_to_dict(response)
    
    db.closeConnection()

    return objResponse

  except oracledb.DatabaseError as e:
    flash(f"Estrela não encontrada: {e.args[0].message}")
    print(f"Estrela não encontrada: {e.args[0].message}")

    return None

