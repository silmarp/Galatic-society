from app.migrations.database import *

def leaderReport(user, faction, grouping=''):
  db = DbConnection()
  
  try:
    ref_cursor = db.getCursor().callfunc("PG_LIDER.relatorio_lider_faccao",
                                         oracledb.DB_TYPE_CURSOR,
                                         [user, faction, grouping])
    
    result = ref_cursor.fetchall()

    db.closeConnection()

    return result

  except oracledb.DatabaseError as e:
    flash("Erro ao gerar relatório: " + e.args[0].message)
    print("Erro ao gerar relatório: " + e.args[0].message)

    return None

