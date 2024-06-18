from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField
from wtforms.validators import DataRequired

class UpdateLeaderFromFaction(FlaskForm):
    leader = StringField('lider:', validators=[DataRequired()])
    submit = SubmitField('Alterar')