from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField
from wtforms.validators import DataRequired

class DeleteStar(FlaskForm):
    star_id = StringField('ID da Estrela*', validators=[DataRequired()])
    submit = SubmitField('Remover')
