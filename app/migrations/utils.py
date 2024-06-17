import oracledb

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

