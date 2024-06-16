from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField
from wtforms.validators import DataRequired

class AddCommunityToFaction(FlaskForm):
    species = StringField('Espécie:', validators=[DataRequired()])
    community = StringField('Comunidade:', validators=[DataRequired()])
    submit = SubmitField('Credenciar')