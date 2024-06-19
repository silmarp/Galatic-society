from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField, DateField
from wtforms.validators import DataRequired, Optional

class CreateFederation(FlaskForm):
    CreateFederation_federation = StringField('Federação*', validators=[DataRequired()])
    CreateFederation_date = DateField('Data início', format='%d/%m/%Y', validators=[Optional()])
    CreateFederation_submit = SubmitField('Adicionar')
