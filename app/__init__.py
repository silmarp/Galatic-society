from flask import Flask, flash
from flask import request, redirect, url_for
from flask import render_template
from dotenv import load_dotenv

from app.forms.updateFactionName import UpdateFactionName
from app.forms.updateLeaderFromFaction import UpdateLeaderFromFaction
from app.forms.login import Login
from app.forms.addCommunityToFaction import AddCommunityToFaction
from app.forms.addFederationToNation import AddFederationToNation
from app.forms.addDominationToNation import AddDominationToNation
from app.forms.removeNationFromFederation import RemoveNationFromFederation
from app.forms.createStar import CreateStar
from app.forms.deleteStar import DeleteStar

from app.migrations.database import *

load_dotenv()

app = Flask(__name__)

app.config['SECRET_KEY'] = "mysecretkey"

userSession = {
    'logged': False,
    'cpi': None, # cpi é o id tirando U_ do começo
    'name': None,
    'position': None,
    'nation': None,
    'faction': None,
    'species': None
}

# def verify_login(id, password):
#     conn = connect(app.config['ORACLE_DB_URI'])
#     cursor = conn.cursor()

#     cursor.execute("SELECT * FROM users WHERE id_user = :id AND password = :password", id=id, password=password)
#     user = cursor.fetchone()

#     cursor.close()
#     conn.close()

#     return user is not None

@app.route('/', methods=['GET', 'POST'])
def login():
    form = Login()
    error = None

    if userSession['logged']:
        return redirect(url_for('overview'))

    if form.validate_on_submit():
        id = form.id.data
        password = form.password.data

        verifyLogin(id, password)

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

            return redirect(url_for('login'))
        else:
            form.id.data = ''
            form.password.data = ''
            error = 'ID ou senha inválidos'

    return render_template('login.html',
                           form=form,
                           error=error,
                           userSession=userSession)

@app.route('/logout')
def logout():
    userSession['logged'] = False
    userSession['cpi'] = None
    userSession['name'] = None
    userSession['position'] = None
    userSession['nation'] = None
    userSession['faction'] = None
    userSession['species'] = None

    return redirect(url_for('login'))

@app.route('/overview', methods=['GET', 'POST'])
def overview():
    updateFactionNameForm = UpdateFactionName()
    updateLeaderFromFactionForm = UpdateLeaderFromFaction()
    addCommunityToFactionForm = AddCommunityToFaction()
    addFederationToNationForm = AddFederationToNation()
    addDominationToNationForm = AddDominationToNation()
    removeNationFromFederationForm= RemoveNationFromFederation()
    createStarForm = CreateStar()
    deleteStarForm = DeleteStar()

    error = None # TODO: disparar um toast com o erro

    if not userSession['logged']:
        return redirect(url_for('login'))
    
    # todo: fazer com try catch, verificando o erro
    if updateFactionNameForm.validate_on_submit():
        flash('Nome da facção alterado com sucesso!')
        userSession['faction'] = updateFactionNameForm.faction.data
        return redirect(url_for('overview'))

    if updateLeaderFromFactionForm.validate_on_submit():
        flash('Lider da facção alterado com sucesso!')
        return redirect(url_for('overview'))
    
    if addCommunityToFactionForm.validate_on_submit():
        flash('Comunidade credenciada com sucesso!')
        return redirect(url_for('overview'))
    
    if addFederationToNationForm.validate_on_submit():
        flash('Federação credenciada com sucesso!')
        return redirect(url_for('overview'))
    
    if addDominationToNationForm.validate_on_submit():
        flash('Dominação adicionada com sucesso!')
        return redirect(url_for('overview'))
    
    if removeNationFromFederationForm.validate_on_submit():
        flash('Nação removida da federação com sucesso!')
        return redirect(url_for('overview'))
    
    if createStarForm.validate_on_submit():
        flash('Estrela adicionada com sucesso!')
        return redirect(url_for('overview'))
    
    if deleteStarForm.validate_on_submit():
        flash('Estrela removida com sucesso!')
        return redirect(url_for('overview'))

    return render_template('overview.html',
                          userSession=userSession,
                          updateFactionNameForm=updateFactionNameForm,
                          updateLeaderFromFactionForm=updateLeaderFromFactionForm,
                          addCommunityToFactionForm=addCommunityToFactionForm,
                          addFederationToNationForm=addFederationToNationForm,
                          addDominationToNationForm=addDominationToNationForm,
                          removeNationFromFederationForm=removeNationFromFederationForm,
                          createStarForm=createStarForm,
                          deleteStarForm=deleteStarForm)

# Invalid URL
@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404

if __name__ == '__main__':
    app.run(debug=True, port=5000)
