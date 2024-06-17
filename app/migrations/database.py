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


def dbObj_to_dict(db_object):
  """
  Converte um oracledb.DbObject em um dicionário.
  """
  result = {}
  for attr in db_object.type.attributes:
    value = getattr(db_object, attr.name)
    if isinstance(value, oracledb.DbObject):
      result[attr.name] = dbObj_to_dict(value)  # Conversão recursiva para objetos aninhados
    else:
      result[attr.name] = value
  return result

def verifyLogin(id, password):
  db = DbConnection()

  tipo_retorno = db.getType("LIDER%ROWTYPE")

  try:
    response = db.getCursor().callfunc('PG_Users.get_user_info', tipo_retorno, [id, password])
    objResponse = dbObj_to_dict(response)

    db.closeConnection()

    print(objResponse)

    return objResponse

  except oracledb.DatabaseError as e:
    if e.args[0].code == -20101:
      flash("ID ou senha inválidos")
      print("ID ou senha inválidos")
    else:
      flash(f"Erro ao buscar dados no banco de dados Oracle: {e}")
      print(f"Erro ao buscar dados no banco de dados Oracle: {e}")

    return None

    