 -- Visualização de todas as federações e suas respectivas nações
CREATE OR REPLACE VIEW V_FEDERACOES_NACOES AS
SELECT 
    F.NOME AS FEDERACAO,
    F.DATA_FUND AS DATA_FUNDACAO,
    N.NOME AS NACAO,
    N.QTD_PLANETAS AS QUANTIDADE_PLANETAS
FROM 
    FEDERACAO F
    LEFT JOIN NACAO N ON F.NOME = N.FEDERACAO;

-- Visualização de todas as nações e suas facções associadas
CREATE OR REPLACE VIEW V_NACOES_FACCOES AS
SELECT 
    N.NOME AS NACAO,
    N.QTD_PLANETAS AS QUANTIDADE_PLANETAS,
    F.NOME AS FEDERACAO,
    NF.FACCAO AS FACCAO
FROM 
    NACAO N
    LEFT JOIN NACAO_FACCAO NF ON N.NOME = NF.NACAO
    LEFT JOIN FEDERACAO F ON N.FEDERACAO = F.NOME;

-- Visualização de todos os líderes e suas nações e espécies
CREATE OR REPLACE VIEW V_LIDERES AS
SELECT 
    L.CPI,
    L.NOME AS NOME_LIDER,
    L.CARGO,
    L.NACAO,
    N.FEDERACAO,
    L.ESPECIE
FROM 
    LIDER L
    LEFT JOIN NACAO N ON L.NACAO = N.NOME;

-- Visualização de todas as espécies e os planetas de origem
CREATE OR REPLACE VIEW V_ESPECIES_PLANETAS AS
SELECT 
    E.NOME AS ESPECIE,
    E.PLANETA_OR AS PLANETA_ORIGEM,
    E.INTELIGENTE
FROM 
    ESPECIE E;

-- Visualização de planetas, suas classificações e massas
CREATE OR REPLACE VIEW V_PLANETAS AS
SELECT 
    P.ID_ASTRO AS PLANETA,
    P.CLASSIFICACAO,
    P.MASSA,
    P.RAIO
FROM 
    PLANETA P;

-- Visualização de todas as estrelas e seus sistemas
CREATE OR REPLACE VIEW V_ESTRELAS_SISTEMAS AS
SELECT 
    E.ID_ESTRELA AS ESTRELA,
    E.NOME AS NOME_ESTRELA,
    E.CLASSIFICACAO,
    E.MASSA,
    S.NOME AS SISTEMA,
    E.X,
    E.Y,
    E.Z
FROM 
    ESTRELA E
    LEFT JOIN SISTEMA S ON E.ID_ESTRELA = S.ESTRELA;

-- Visualização das comunidades e suas espécies associadas
CREATE OR REPLACE VIEW V_COMUNIDADES AS
SELECT 
    C.ESPECIE,
    C.NOME AS COMUNIDADE,
    C.QTD_HABITANTES
FROM 
    COMUNIDADE C;

-- Visualização das habitações de espécies em planetas
CREATE OR REPLACE VIEW V_HABITACOES AS
SELECT 
    H.PLANETA,
    H.ESPECIE,
    H.COMUNIDADE,
    H.DATA_INI AS DATA_INICIO,
    H.DATA_FIM AS DATA_FIM
FROM 
    HABITACAO H;

-- Visualização das dominâncias de nações em planetas
CREATE OR REPLACE VIEW V_DOMINANCIAS AS
SELECT 
    D.PLANETA,
    D.NACAO,
    D.DATA_INI AS DATA_INICIO,
    D.DATA_FIM AS DATA_FIM
FROM 
    DOMINANCIA D;