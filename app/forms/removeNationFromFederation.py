from flask_wtf import FlaskForm
from wtforms import SubmitField, HiddenField

class RemoveNationFromFederation(FlaskForm):
    RemoveNationFromFederation_submit = SubmitField('Remover')
