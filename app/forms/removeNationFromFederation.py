from flask_wtf import FlaskForm
from wtforms import SubmitField, HiddenField

class RemoveNationFromFederation(FlaskForm):
    hiddenfield = HiddenField('RNFF')
    submitRMFF = SubmitField('Remover')
