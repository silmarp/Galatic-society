from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField, DateField
from wtforms.validators import DataRequired

class AddDominationToNation(FlaskForm):
    planet = StringField('Planeta', validators=[DataRequired()])
    start_date = DateField('Data início', validators=[DataRequired()])
    end_date = DateField('Data fim')
    submit = SubmitField('Dominar')
