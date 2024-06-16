from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField, DateField
from wtforms.validators import DataRequired

class AddDominationToNation(FlaskForm):
    planet = StringField('Planeta', validators=[DataRequired()])
    start_date = DateField('Data início', format='%d/%m/%Y', validators=[DataRequired()])
    end_date = DateField('Data fim', format='%d/%m/%Y')
    submit = SubmitField('Dominar')
