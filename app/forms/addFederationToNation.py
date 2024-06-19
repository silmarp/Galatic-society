from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField, DateField
from wtforms.validators import DataRequired

class AddFederationToNation(FlaskForm):
    AddFederationToNation_federation = StringField('Federação', validators=[DataRequired()])
    AddFederationToNation_submit = SubmitField('Credenciar')
