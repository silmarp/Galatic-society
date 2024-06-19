from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField
from wtforms.validators import DataRequired

class GetStar(FlaskForm):
    GetStar_star_id = StringField('ID da Estrela', validators=[DataRequired()])
    GetStar_submit = SubmitField('Buscar')
