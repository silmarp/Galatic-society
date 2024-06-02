from flask import Flask
from flask import render_template
from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField, PasswordField
from wtforms.validators import DataRequired

app = Flask(__name__)
app.config['SECRET_KEY'] = "mysecretkey"

class loginForm(FlaskForm):
    username = StringField('Username:', validators=[DataRequired()])
    password = PasswordField('Password:', validators=[DataRequired()])
    submit = SubmitField('Submit')


@app.route('/')
def index():
    return render_template("index.html")

@app.route('/login', methods=['GET', 'POST'])
def login():
    username = None
    password = None
    form = loginForm()
    if form.validate_on_submit():
        username = form.username.data
        password = form.password.data
        form.username.data = ''
        form.password.data = ''
    return render_template('login.html',
                            username = username,
                            password = password,
                            form=form)

# Invalid URL
@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404

if __name__ == '__main__':
    app.run(debug=True, port=5000)
