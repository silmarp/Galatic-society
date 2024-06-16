from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField, DateField
from wtforms.validators import DataRequired

class AddFederationToNation(FlaskForm):
    federation = StringField('Federação', validators=[DataRequired()])
    date = DateField('Data de criação', format='%d/%m/%Y')
    submit = SubmitField('Credenciar')
