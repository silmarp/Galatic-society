from flask import Flask, flash
from flask import request, redirect, url_for
from flask import render_template
from cx_Oracle import connect

from app.forms.updateFactionName import UpdateFactionName
from app.forms.updateLeaderFromFaction import UpdateLeaderFromFaction
from app.forms.loginForm import LoginForm
from app.forms.addCommunityToFaction import AddCommunityToFaction

app = Flask(__name__)

app.config['SECRET_KEY'] = "mysecretkey"
app.config['ORACLE_DB_URI'] = 'oracle+cx_oracle://system:oracle@localhost:1521/xe'

userSession = {
    'logged': False,
    'cpi': None, # cpi é o id tirando U_ do começo
    'name': None,
    'position': None,
    'nation': None,
    'faction': None,
    'species': None
}

def verify_login(id, password):
    conn = connect(app.config['ORACLE_DB_URI'])
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM users WHERE id_user = :id AND password = :password", id=id, password=password)
    user = cursor.fetchone()

    cursor.close()
    conn.close()

    return user is not None

@app.route('/')
def index():
    return render_template("index.html")

@app.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    error = None

    if form.validate_on_submit():
        id = form.id.data
        password = form.password.data

        # if verify_login(username, password):
        #     return redirect(url_for('index'))
        # else:
        #     error = "Usuário ou senha inválidos"
        #     # imprimir erro
        #     flash(error)

        if id == 'admin' and password == 'admin':
            error = None

            userSession['logged'] = True
            userSession['cpi'] = '00001'
            userSession['name'] = 'NOME_DO_LIDER'
            userSession['position'] = 'Cargo do Lider'
            userSession['nation'] = 'Nacao do Lider'
            userSession['species'] = 'Especie do Lider'

            return redirect(url_for('index'))
        else:
            form.id.data = ''
            form.password.data = ''
            error = 'ID ou senha inválidos'

    return render_template('login.html', form=form, error=error)

@app.route('/overview', methods=['GET', 'POST'])
def overview():
    updateFactionNameForm = UpdateFactionName()
    updateLeaderFromFactionForm = UpdateLeaderFromFaction()
    addCommunityToFactionForm = AddCommunityToFaction()

    error = None # TODO: disparar um toast com o erro

    if not userSession['logged']:
        return redirect(url_for('login'))
    
    # todo: fazer com try catch, verificando o erro
    if updateFactionNameForm.validate_on_submit():
        flash('Nome da facção alterado com sucesso!')
        userSession['faction'] = updateFactionNameForm.faction.data
        return redirect(url_for('overview'))

    if updateLeaderFromFactionForm.validate_on_submit():
        # userSession['faction'] = updateFactionNameForm.faction.data
        flash('Lider alterado com sucesso!')

        return redirect(url_for('overview'))
    
    if addCommunityToFactionForm.validate_on_submit():
        flash('Comunidade credenciada com sucesso!')
        return redirect(url_for('overview'))
    


    return render_template('overview.html',
                          user=userSession,
                          updateFactionNameForm=updateFactionNameForm,
                          updateLeaderFromFactionForm=updateLeaderFromFactionForm,
                          addCommunityToFactionForm=addCommunityToFactionForm)

# Invalid URL
@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404

if __name__ == '__main__':
    app.run(debug=True, port=5000)
