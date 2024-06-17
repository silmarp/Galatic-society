from app.migrations.database import *
from app.migrations.utils import dbObj_to_dict

def verifyLogin(id, password):
  db = DbConnection()

  tipo_retorno = db.getType("LIDER%ROWTYPE")
  tipo_retornoLeaderFac = db.getType("FACCAO%ROWTYPE")

  isFacLeader = False
  objResponseLeaderFac = None

  try:
    responseLeaderFac = db.getCursor().callfunc('PG_Lider.is_lider', tipo_retornoLeaderFac, [id])
    objResponseLeaderFac = dbObj_to_dict(responseLeaderFac)

    isFacLeader = True
  except oracledb.DatabaseError as e:
    print("Usuario não é líder de facção")

  try:
    response = db.getCursor().callfunc('PG_Users.get_user_info', tipo_retorno, [id, password])

    objResponse = dbObj_to_dict(response)

    objResponse["FACCAO"] = "Você não é líder de facção"

    if isFacLeader:
      objResponse["FACCAO"] = objResponseLeaderFac["NOME"]

    db.closeConnection()

    return objResponse

  except oracledb.DatabaseError as e:
    if e.args[0].code == -20101:
      flash("ID ou senha inválidos")
      print("ID ou senha inválidos")
    else:
      flash(f"Erro ao buscar dados no banco de dados Oracle: {e}")
      print(f"Erro ao buscar dados no banco de dados Oracle: {e}")

    return None
