from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField, DateField
from wtforms.validators import DataRequired, Optional

class AddDominationToNation(FlaskForm):
    AddDominationToNation_planet = StringField('Planeta*', validators=[DataRequired()])
    AddDominationToNation_start_date = DateField('Data início', format="%d/%m/%Y", validators=[DataRequired()])
    AddDominationToNation_end_date = DateField('Data fim', format="%d/%m/%Y", validators=[Optional()])
    AddDominationToNation_submit = SubmitField('Dominar')

    def validate(self):
        if self.AddDominationToNation_planet.data is None:
            print("A")
            return False
        
        if self.AddDominationToNation_start_date.data is None:
            print("B")
            return False

        return True

