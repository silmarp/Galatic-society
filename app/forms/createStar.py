from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField, DecimalField
from wtforms.validators import DataRequired, NumberRange

class CreateStar(FlaskForm):
    id_star = StringField('ID da Estrela*', validators=[DataRequired()])
    name = StringField('Nome da estrela')
    classification = StringField('Classificação')
    weight = DecimalField('Peso*', validators=[NumberRange(min=0)])
    X = DecimalField('Coordenada X*', validators=[DataRequired()])
    Y = DecimalField('Coordenada Y*', validators=[DataRequired()])
    Z = DecimalField('Coordenada Z*', validators=[DataRequired()])
    submit = SubmitField('Adicionar')
