from flask_wtf import FlaskForm
from wtforms import SubmitField

class RemoveNationFromFederation(FlaskForm):
    submit = SubmitField('Remover')
