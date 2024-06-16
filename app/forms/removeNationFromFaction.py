from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField
from wtforms.validators import DataRequired

class RemoveNationFromFaction(FlaskForm):
    nation = StringField('Nação:', validators=[DataRequired()])
    submit = SubmitField('Remover')