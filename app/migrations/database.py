import os
import oracledb
import hashlib

def verifyLogin(id, password):
    md5_password = hashlib.md5(password.encode()).hexdigest()
    

    try:
        conn = oracledb.connect(
            user=os.environ.get('ORACLE_USER'),
            password=os.environ.get('ORACLE_PASSWORD'),
            dsn=f"{os.environ.get('ORACLE_HOST')}:{os.environ.get('ORACLE_PORT')}/{os.environ.get('ORACLE_SERVICE')}"
        )

        # obj_type = conn.gettype('PG_User.UserType')
        cursor = conn.cursor()

        response = cursor.callfunc('PG_User.get_user_info', oracledb.DB_TYPE_UNKNOWN, [id, md5_password])

        # response = cursor.fetchone()
        print("RESPONSE ", response)

        cursor.close()
        conn.close()

        return response is not None
    except oracledb.DatabaseError as e:
        print(f"Erro ao conectar ao banco de dados Oracle: {e}")
        return None

