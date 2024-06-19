from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField
from wtforms.validators import DataRequired

class RemoveCommunityFromFaction(FlaskForm):
    RemoveCommunityFromFaction_species = StringField('Espécie:', validators=[DataRequired()])
    RemoveCommunityFromFaction_community = StringField('Comunidade:', validators=[DataRequired()])
    RemoveCommunityFromFaction_submit = SubmitField('Remover')
