-- Views para relatorios de oficial
CREATE OR REPLACE VIEW V_RL_OFICIAL AS
SELECT nf.NACAO, nf.FACCAO, p.COMUNIDADE, p.ESPECIE, c.QTD_HABITANTES, h.PLANETA, h.DATA_INI, h.DATA_FIM, op.ESTRELA, s.NOME  FROM NACAO_FACCAO nf 
	JOIN PARTICIPA p ON p.FACCAO = nf.FACCAO 
	JOIN COMUNIDADE c ON p.ESPECIE = c.ESPECIE AND c.NOME  = p.COMUNIDADE
	LEFT JOIN HABITACAO h ON h.COMUNIDADE  = c.NOME AND h.ESPECIE = c.ESPECIE 
	LEFT JOIN ORBITA_PLANETA op ON op.PLANETA  = h.PLANETA
	LEFT JOIN SISTEMA s ON s.ESTRELA = op.ESTRELA;
--

-- Views para relatorios lider
CREATE OR REPLACE VIEW V_RL_LIDER AS 
SELECT p.FACCAO, p.COMUNIDADE, p.ESPECIE, h.PLANETA, h.DATA_INI, h.DATA_FIM, d.NACAO, op.ESTRELA, s.NOME FROM PARTICIPA p 
	JOIN HABITACAO h ON h.COMUNIDADE = p.COMUNIDADE AND h.ESPECIE  = p.ESPECIE
	LEFT JOIN DOMINANCIA d ON d.PLANETA = h.PLANETA 
	LEFT JOIN ORBITA_PLANETA op ON op.PLANETA = h.PLANETA
	LEFT JOIN SISTEMA s ON s.ESTRELA = op.ESTRELA;
--

-- Views para relatorios de comandante

--View para contar comunidades por planeta:
CREATE OR REPLACE VIEW V_CONTAGEM_COMUNIDADES AS
SELECT h2.planeta, COUNT(DISTINCT c.especie || '-' || c.nome) AS quantidade_comunidades
    FROM HABITACAO h2
        JOIN COMUNIDADE c ON h2.especie = c.especie AND h2.comunidade = c.nome
GROUP BY h2.planeta;

--View para encontrar faccao majoritária por planeta:
CREATE OR REPLACE VIEW V_FACCAO_MAJORITARIA AS
SELECT h2.planeta, part.faccao, COUNT(*) AS faccao_count
    FROM PARTICIPA part
        JOIN HABITACAO h2 ON part.especie = h2.especie AND part.comunidade = h2.comunidade
GROUP BY h2.planeta, part.faccao;

--View para relatório detalhado de dominância de planetas:    
CREATE OR REPLACE VIEW V_DOMINANCIA_PLANETAS AS
SELECT
    p.id_astro AS nome_planeta,
    d.nacao AS nacao_dominante,
    d.data_ini AS data_inicio_dominancia,
    d.data_fim AS data_fim_dominancia,
    cc.quantidade_comunidades,
    LISTAGG(DISTINCT e.nome, ', ') WITHIN GROUP (ORDER BY e.nome) AS especies_presentes,
    SUM(c.qtd_habitantes) AS total_habitantes,
    LISTAGG(DISTINCT f.nome, ', ') WITHIN GROUP (ORDER BY f.nome) AS faccoes_presentes,
    fm.faccao AS faccao_majoritaria
    FROM PLANETA p
        LEFT JOIN DOMINANCIA d ON p.id_astro = d.planeta
        LEFT JOIN HABITACAO h ON p.id_astro = h.planeta
        LEFT JOIN COMUNIDADE c ON h.especie = c.especie AND h.comunidade = c.nome
        LEFT JOIN ESPECIE e ON c.especie = e.nome
        LEFT JOIN PARTICIPA part ON c.especie = part.especie AND c.nome = part.comunidade
        LEFT JOIN FACCAO f ON part.faccao = f.nome
        LEFT JOIN v_contagem_comunidades cc ON p.id_astro = cc.planeta
        LEFT JOIN v_faccao_majoritaria fm ON p.id_astro = fm.planeta
GROUP BY p.id_astro, d.nacao, d.data_ini, d.data_fim, cc.quantidade_comunidades, fm.faccao;


--

-- Views do líder de faccao
CREATE OR REPLACE VIEW V_LIDER_FACCAO
    (LIDER, FACCAO, NACAO, PLANETA, COM_ESPECIE, COM_NOME, PARTICIPA) AS
SELECT F.LIDER, F.NOME, NF.NACAO, D.PLANETA, H.ESPECIE, H.COMUNIDADE, P.FACCAO 
    FROM NACAO_FACCAO NF JOIN FACCAO F ON NF.FACCAO = F.NOME
        LEFT JOIN DOMINANCIA D ON D.NACAO = NF.NACAO
        LEFT JOIN HABITACAO H ON H.PLANETA = D.PLANETA
        LEFT JOIN PARTICIPA P ON P.ESPECIE = H.ESPECIE AND P.COMUNIDADE = H.COMUNIDADE
    WHERE D.DATA_FIM >= TO_DATE(SYSDATE) OR D.DATA_FIM IS NULL;
