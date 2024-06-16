CREATE OR REPLACE FUNCTION leaderReport ( p_faccao FACCAO.NOME%TYPE, p_grouping char ) RETURN sys_refcursor IS
	c_report sys_refcursor;
BEGIN 
	IF p_grouping = 'N' THEN	
		OPEN c_report FOR 
			SELECT c.NOME, c.ESPECIE, p.FACCAO, c.QTD_HABITANTES, h.PLANETA, d.NACAO, e.ID_ESTRELA, s.NOME 
				FROM participa p JOIN COMUNIDADE c ON p.COMUNIDADE = c.NOME AND p.ESPECIE = c.ESPECIE
				JOIN HABITACAO h ON h.COMUNIDADE = c.NOME AND h.ESPECIE = c.ESPECIE 
				JOIN DOMINANCIA d ON d.PLANETA = h.PLANETA
				JOIN ORBITA_PLANETA op ON op.PLANETA = h.PLANETA 
				JOIN ESTRELA e ON e.ID_ESTRELA = op.ESTRELA
				JOIN SISTEMA s ON s.ESTRELA = e.ID_ESTRELA 
				WHERE p.FACCAO = p_faccao ORDER BY d.nacao;	

	ELSIF p_grouping = 'E' THEN	
		OPEN c_report FOR 
			SELECT c.NOME, c.ESPECIE, p.FACCAO, c.QTD_HABITANTES, h.PLANETA, d.NACAO, e.ID_ESTRELA, s.NOME 
				FROM participa p JOIN COMUNIDADE c ON p.COMUNIDADE = c.NOME AND p.ESPECIE = c.ESPECIE
				JOIN HABITACAO h ON h.COMUNIDADE = c.NOME AND h.ESPECIE = c.ESPECIE 
				JOIN DOMINANCIA d ON d.PLANETA = h.PLANETA
				JOIN ORBITA_PLANETA op ON op.PLANETA = h.PLANETA 
				JOIN ESTRELA e ON e.ID_ESTRELA = op.ESTRELA
				JOIN SISTEMA s ON s.ESTRELA = e.ID_ESTRELA 
				WHERE p.FACCAO = p_faccao ORDER BY c.especie;	

	ELSIF p_grouping = 'P' THEN	
		OPEN c_report FOR 
			SELECT c.NOME, c.ESPECIE, p.FACCAO, c.QTD_HABITANTES, h.PLANETA, d.NACAO, e.ID_ESTRELA, s.NOME 
				FROM participa p JOIN COMUNIDADE c ON p.COMUNIDADE = c.NOME AND p.ESPECIE = c.ESPECIE
				JOIN HABITACAO h ON h.COMUNIDADE = c.NOME AND h.ESPECIE = c.ESPECIE 
				JOIN DOMINANCIA d ON d.PLANETA = h.PLANETA
				JOIN ORBITA_PLANETA op ON op.PLANETA = h.PLANETA 
				JOIN ESTRELA e ON e.ID_ESTRELA = op.ESTRELA
				JOIN SISTEMA s ON s.ESTRELA = e.ID_ESTRELA 
				WHERE p.FACCAO = p_faccao ORDER BY h.planeta;
	
	ELSIF p_grouping = 'S' THEN	
		OPEN c_report FOR 
			SELECT c.NOME, c.ESPECIE, p.FACCAO, c.QTD_HABITANTES, h.PLANETA, d.NACAO, e.ID_ESTRELA, s.NOME 
				FROM participa p JOIN COMUNIDADE c ON p.COMUNIDADE = c.NOME AND p.ESPECIE = c.ESPECIE
				JOIN HABITACAO h ON h.COMUNIDADE = c.NOME AND h.ESPECIE = c.ESPECIE 
				JOIN DOMINANCIA d ON d.PLANETA = h.PLANETA
				JOIN ORBITA_PLANETA op ON op.PLANETA = h.PLANETA 
				JOIN ESTRELA e ON e.ID_ESTRELA = op.ESTRELA
				JOIN SISTEMA s ON s.ESTRELA = e.ID_ESTRELA 
				WHERE p.FACCAO = p_faccao ORDER BY e.id_estrela;	
	
	ELSE
		OPEN c_report FOR 
			SELECT c.NOME, c.ESPECIE, p.FACCAO, c.QTD_HABITANTES, h.PLANETA, d.NACAO, e.ID_ESTRELA, s.NOME 
				FROM participa p JOIN COMUNIDADE c ON p.COMUNIDADE = c.NOME AND p.ESPECIE = c.ESPECIE
				JOIN HABITACAO h ON h.COMUNIDADE = c.NOME AND h.ESPECIE = c.ESPECIE 
				JOIN DOMINANCIA d ON d.PLANETA = h.PLANETA
				JOIN ORBITA_PLANETA op ON op.PLANETA = h.PLANETA 
				JOIN ESTRELA e ON e.ID_ESTRELA = op.ESTRELA
				JOIN SISTEMA s ON s.ESTRELA = e.ID_ESTRELA 
				WHERE p.FACCAO = p_faccao;	
	END IF;
	RETURN c_report;

END leaderReport;
