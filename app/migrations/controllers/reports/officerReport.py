from app.migrations.database import *

def officerReport(user, nation, grouping=''):
  db = DbConnection()
  
  try:
    ref_cursor = db.getCursor().callfunc("PG_OFICIAL.relatorio_oficial",
                                         oracledb.DB_TYPE_CURSOR,
                                         [user, nation, grouping])
    
    result = ref_cursor.fetchall()

    db.closeConnection()

    return result

  except oracledb.DatabaseError as e:
    flash("Erro ao gerar relatório: " + e.args[0].message)
    print("Erro ao gerar relatório: " + e.args[0].message)

    return None

