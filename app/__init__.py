from flask import Flask, flash
from flask import request, redirect, url_for
from flask import render_template
from dotenv import load_dotenv

from app.forms.updateFactionName import UpdateFactionName
from app.forms.updateLeaderFromFaction import UpdateLeaderFromFaction
from app.forms.login import Login
from app.forms.addCommunityToFaction import AddCommunityToFaction
from app.forms.removeNationFromFaction import RemoveNationFromFaction
from app.forms.addFederationToNation import AddFederationToNation
from app.forms.addDominationToNation import AddDominationToNation
from app.forms.removeNationFromFederation import RemoveNationFromFederation
from app.forms.createStar import CreateStar
from app.forms.updateStar import UpdateStar
from app.forms.deleteStar import DeleteStar

from app.migrations.database import *
from app.migrations.controllers.login import verifyLogin
from app.migrations.controllers.changeFactionName import changeFactionName
from app.migrations.controllers.changeFacLeader import changeFacLeader
from app.migrations.controllers.addStar import addStar
from app.migrations.controllers.updateStar import updateStar
from app.migrations.controllers.deleteStar import deleteStar


from app.migrations.controllers.deleteNationFromFederation import deleteNationFromFederation

# falta testar
from app.migrations.controllers.addCommunityToFaction import addCommunityToFaction
from app.migrations.controllers.removeNationFromFaction import removeNationFromFaction

# deu pau, consertar
from app.migrations.controllers.addDomination import addDomination

load_dotenv()

app = Flask(__name__)
app.config['SECRET_KEY'] = "mysecretkey"

userSession = {
  'logged': False,
  'user': None,
  'cpi': None, # cpi é o id tirando U_ do começo
  'name': None,
  'position': None,
  'nation': None,
  'faction': None,
  'species': None
}

@app.route('/', methods=['GET', 'POST'])
def login():
  form = Login()
  error = None

  if userSession['logged']:
    return redirect(url_for('overview'))

  if form.validate_on_submit():
    id = form.id.data
    password = form.password.data

    response = verifyLogin(id, password)

    if response is not None:
      error = None

      userSession['logged'] = True
      userSession['user'] = id
      userSession['cpi'] = response['CPI']
      userSession['name'] = response['NOME']
      userSession['position'] = response['CARGO']
      userSession['nation'] = response['NACAO']
      userSession['species'] = response['ESPECIE']
      userSession['faction'] = response['FACCAO']

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
    userSession['user'] = None
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
    removeNationFromFactionForm = RemoveNationFromFaction()
    addFederationToNationForm = AddFederationToNation()
    addDominationToNationForm = AddDominationToNation()
    removeNationFromFederationForm = RemoveNationFromFederation()
    createStarForm = CreateStar()
    updateStarForm = UpdateStar()
    deleteStarForm = DeleteStar()

    error = None # TODO: disparar um toast com o erro

    if not userSession['logged']:
        return redirect(url_for('login'))
    
    # todo: fazer com try catch, verificando o erro
    if updateFactionNameForm.validate_on_submit():
        print("UPDATE FACTION NAME FORM")

        ok = changeFactionName(
          userSession['user'],
          userSession['faction'],
          updateFactionNameForm.faction.data
        )

        if ok:
          flash('Nome da facção alterado com sucesso!')
          userSession['faction'] = updateFactionNameForm.faction.data
        else:
          flash('Erro ao alterar nome da facção!')

        return redirect(url_for('overview'))

    if updateLeaderFromFactionForm.validate_on_submit():
        print("UPDATE LEADER FROM FACTION FORM")

        ok = changeFacLeader(
          userSession['user'],
          userSession['faction'],
          updateLeaderFromFactionForm.leader.data
        )

        if ok:
          flash('Lider alterado com sucesso')
          userSession['faction'] = "Você não é líder de facção"
        else:
          flash('Erro ao alterar lider da facção!')
        return redirect(url_for('overview'))
    
    if addCommunityToFactionForm.validate_on_submit():
        print("ADD COMMUNITY TO FACTION FORM")
        ok = addCommunityToFaction(
          userSession['user'],
          userSession['faction'],
          addCommunityToFactionForm.species.data,
          addCommunityToFactionForm.community.data
        )

        if ok:
          flash('Comunidade adicionada com sucesso!')
        else:
          flash('Erro ao adicionar comunidade!')

        return redirect(url_for('overview'))
    
    if removeNationFromFactionForm.validate_on_submit():
        print("REMOVE NATION FROM FACTION FORM")
        ok = removeNationFromFaction(
          userSession['user'],
          removeNationFromFactionForm.nation.data
        )

        if ok:
          flash('Nação removida com sucesso!')
        else:
          flash('Erro ao remover nação!')

        return redirect(url_for('overview'))

    if addFederationToNationForm.validate_on_submit():
        print("ADD FEDERATION TO NATION FORM")
        flash('Federação credenciada com sucesso!')
        return redirect(url_for('overview'))
    
    if addDominationToNationForm.validate_on_submit():
        print("ADD DOMINATION TO NATION FORM")
        response = addDomination(
          userSession['nation'],
          addDominationToNationForm.planet.data,
          addDominationToNationForm.start_date.data,
          addDominationToNationForm.
          end_date.data
        )

        print(response)

        return redirect(url_for('overview'))
    
    # if removeNationFromFederationForm.validate_on_submit():
    #     print("REMOVE NATION FROM FEDERATION FORM")

    #     ok = deleteNationFromFederation(
    #        userSession['user']
    #     )
        
    #     return redirect(url_for('overview'))
    
    if createStarForm.validate_on_submit():
        print("CREATE STAR FORM")

        ok = addStar(
            userSession['user'],
            createStarForm.id_star.data,
            createStarForm.name.data,
            createStarForm.classification.data,
            createStarForm.weight.data,
            createStarForm.X.data,
            createStarForm.Y.data,
            createStarForm.Z.data
        )

        if ok:
          flash('Estrela adicionada com sucesso!')
        else:
          flash('Erro ao adicionar estrela!')
        
        return redirect(url_for('overview'))
    
    if updateStarForm.validate_on_submit():
        print("UPDATE STAR FORM")

        ok = updateStar(
            userSession['user'],
            updateStarForm.star_id.data,
            updateStarForm.name.data,
            updateStarForm.classification.data,
            updateStarForm.weight.data,
            updateStarForm.X.data,
            updateStarForm.Y.data,
            updateStarForm.Z.data
        )

        if ok:
          flash('Estrela atualizada com sucesso!')
        else:
          flash('Erro ao atualizar estrela!')

        return redirect(url_for('overview'))
    
    if deleteStarForm.validate_on_submit():
        print("DELETE STAR FORM")
        
        ok = deleteStar(
            userSession['user'],
            deleteStarForm.star_id.data
        )

        if ok:
          flash('Estrela removida com sucesso!')
        else:
          flash('Erro ao remover estrela!')

        return redirect(url_for('overview'))

    return render_template('overview.html',
                          userSession=userSession,
                          updateFactionNameForm=updateFactionNameForm,
                          updateLeaderFromFactionForm=updateLeaderFromFactionForm,
                          addCommunityToFactionForm=addCommunityToFactionForm,
                          removeNationFromFactionForm=removeNationFromFactionForm,
                          addFederationToNationForm=addFederationToNationForm,
                          addDominationToNationForm=addDominationToNationForm,
                          removeNationFromFederationForm=removeNationFromFederationForm,
                          createStarForm=createStarForm,
                          updateStarForm=updateStarForm,
                          deleteStarForm=deleteStarForm)

# Invalid URL
@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html', userSession=userSession), 404

if __name__ == '__main__':
    app.run(debug=True, port=5000)
