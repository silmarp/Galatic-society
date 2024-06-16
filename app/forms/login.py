from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField
from wtforms.validators import DataRequired

class Login(FlaskForm):
    id = StringField('ID:', validators=[DataRequired()])
    password = PasswordField('Password:', validators=[DataRequired()])
    submit = SubmitField('Submit')
