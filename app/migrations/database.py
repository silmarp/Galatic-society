import os
import oracledb
from flask import flash

class DbConnection:
  def __init__(self):
    try:
      self.conn = oracledb.connect(
        user=os.environ.get('ORACLE_USER'),
        password=os.environ.get('ORACLE_PASSWORD'),
        dsn=f"{os.environ.get('ORACLE_HOST')}:{os.environ.get('ORACLE_PORT')}/{os.environ.get('ORACLE_SERVICE')}"
      )

      self.cursor = self.conn.cursor()
    except oracledb.DatabaseError as e:
      flash(f"Erro ao conectar ao banco de dados Oracle: {e}")
      print(f"Erro ao conectar ao banco de dados Oracle: {e}")
      self.conn = None
      self.cursor = None

  def getConn(self):
    return self.conn
    
  def getCursor(self):
    return self.cursor
    
  def getType(self, type_name):
    try:
      return self.conn.gettype(type_name)
    except oracledb.DatabaseError as e:
      print(f"Erro ao buscar tipo de dados no banco de dados Oracle: {e}")
      return None

  def closeConnection(self):
    self.cursor.close()
    self.conn.close()

