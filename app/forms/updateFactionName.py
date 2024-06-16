from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField
from wtforms.validators import DataRequired

class UpdateFactionName(FlaskForm):
    faction = StringField('Facção:', validators=[DataRequired()])
    submit = SubmitField('Alterar')