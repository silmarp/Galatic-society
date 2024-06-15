from flask import Flask, flash
from flask import request, redirect, url_for
from flask import render_template
from cx_Oracle import connect
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField
from wtforms.validators import DataRequired

app = Flask(__name__)

app.config['SECRET_KEY'] = "mysecretkey"
app.config['ORACLE_DB_URI'] = 'oracle+cx_oracle://system:oracle@localhost:1521/xe'

class LoginForm(FlaskForm):
    username = StringField('Username:', validators=[DataRequired()])
    password = PasswordField('Password:', validators=[DataRequired()])
    submit = SubmitField('Submit')

def verify_login(username, password):
    conn = connect(app.config['ORACLE_DB_URI'])
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM users WHERE username = :username AND password = :password", username=username, password=password)
    user = cursor.fetchone()

    cursor.close()
    conn.close()

    return user is not None

@app.route('/')
def index():
    return render_template("index.html")

@app.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    error = None

    if form.validate_on_submit():
        username = form.username.data
        password = form.password.data

        # if verify_login(username, password):
        #     return redirect(url_for('index'))
        # else:
        #     error = "Usuário ou senha inválidos"
        #     # imprimir erro
        #     flash(error)

        if username == 'admin' and password == 'admin':
            error = None
            return redirect(url_for('index'))
        else:
            form.username.data = ''
            form.password.data = ''
            error = 'Usuário ou senha inválidos'

    return render_template('login.html', form=form, error=error)

# Invalid URL
@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404

if __name__ == '__main__':
    app.run(debug=True, port=5000)
