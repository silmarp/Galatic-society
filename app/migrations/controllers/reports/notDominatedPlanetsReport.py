from app.migrations.database import *

def notDominatedPlanetsReport(user):
  db = DbConnection()
  
  try:
    ref_cursor = db.getCursor().callfunc("PG_COMANDANTE.relatorio_planetas_nao_dominados",
                                         oracledb.DB_TYPE_CURSOR,
                                         [user])
    
    result = ref_cursor.fetchall()

    db.closeConnection()

    return result

  except oracledb.DatabaseError as e:
    flash("Erro ao gerar relatório: " + e.args[0].message)
    print("Erro ao gerar relatório: " + e.args[0].message)

    return None

