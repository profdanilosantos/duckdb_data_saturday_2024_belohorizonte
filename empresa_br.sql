--
DROP TABLE IF EXISTS silver_estabelecimento

--
CREATE TABLE silver_estabelecimento
AS
SELECT row_number() OVER() AS id,a.* FROM (
	SELECT * EXCLUDE (cidade_exterior,codigo_pais) FROM bronze_estabelecimento_0 WHERE uf = 'ES'
	UNION
	SELECT * EXCLUDE (cidade_exterior,codigo_pais) FROM bronze_estabelecimento_1 WHERE uf = 'ES'
	UNION
	SELECT * EXCLUDE (cidade_exterior,codigo_pais) FROM bronze_estabelecimento_2 WHERE uf = 'ES'
	UNION
	SELECT * EXCLUDE (cidade_exterior,codigo_pais) FROM bronze_estabelecimento_3 WHERE uf = 'ES'
	UNION
	SELECT * EXCLUDE (cidade_exterior,codigo_pais) FROM bronze_estabelecimento_4 WHERE uf = 'ES'
	UNION
	SELECT * EXCLUDE (cidade_exterior,codigo_pais) FROM bronze_estabelecimento_5 WHERE uf = 'ES'
	UNION
	SELECT * EXCLUDE (cidade_exterior,codigo_pais) FROM bronze_estabelecimento_6 WHERE uf = 'ES'
	UNION
	SELECT * EXCLUDE (cidade_exterior,codigo_pais) FROM bronze_estabelecimento_7 WHERE uf = 'ES'
	UNION
	SELECT * EXCLUDE (cidade_exterior,codigo_pais) FROM bronze_estabelecimento_8 WHERE uf = 'ES'
	UNION
	SELECT * EXCLUDE (cidade_exterior,codigo_pais) FROM bronze_estabelecimento_9 WHERE uf = 'ES'
) a

--
FROM silver_estabelecimento

--
DROP TABLE IF EXISTS silver_cnae_empresa

--
CREATE TABLE silver_cnae_empresa AS
SELECT cnpj_basico,cnae_principal as cnae, 'principal' as tipo
FROM silver_estabelecimento
WHERE cnae_principal IS NOT NULL

--
INSERT INTO silver_cnae_empresa
SELECT
    cnpj_basico,
    UNNEST(STRING_SPLIT(cnae_secundario, ',')) AS cnae,
     'secundario' as tipo
FROM
    silver_estabelecimento
WHERE
    cnae_secundario IS NOT NULL

--
FROM silver_estabelecimento

--

SELECT bc.*,bm.descricao, count(*)
FROM silver_estabelecimento se
INNER JOIN silver_cnae_empresa sc ON se.cnpj_basico = sc.cnpj_basico
INNER JOIN bronze_cnae bc ON sc.cnae = bc.codigo
INNER JOIN bronze_municipio bm ON se.municipio = bm.codigo
WHERE bc.descricao LIKE '% dados%' OR
	bc.descricao LIKE '%informá%' OR
	bc.descricao LIKE '%softw%' OR
	bc.descricao LIKE '%programa%' OR
	bc.descricao LIKE '%comput%' OR
	bc.descricao LIKE '%telecom%' OR
	bc.descricao LIKE '%proved%'
GROUP BY all



--
FROM bronze_empresa_0


--
CREATE OR REPLACE TABLE silver_empresa
AS
SELECT row_number() OVER() AS id,a.* FROM (
	SELECT * EXCLUDE (ente_federativo) FROM bronze_empresa_0
	UNION
	SELECT * EXCLUDE (ente_federativo) FROM bronze_empresa_1
	UNION
	SELECT * EXCLUDE (ente_federativo) FROM bronze_empresa_2
	UNION
	SELECT * EXCLUDE (ente_federativo) FROM bronze_empresa_3
	UNION
	SELECT * EXCLUDE (ente_federativo) FROM bronze_empresa_4
	UNION
	SELECT * EXCLUDE (ente_federativo) FROM bronze_empresa_5
	UNION
	SELECT * EXCLUDE (ente_federativo) FROM bronze_empresa_6
	UNION
	SELECT * EXCLUDE (ente_federativo) FROM bronze_empresa_7
	UNION
	SELECT * EXCLUDE (ente_federativo) FROM bronze_empresa_8
	UNION
	SELECT * EXCLUDE (ente_federativo) FROM bronze_empresa_9
) a
WHERE a.cnpj_basico IN (
	SELECT cnpj_basico FROM silver_estabelecimento
)

--
FROM silver_empresa

FROM silver_estabelecimento

--


--
DROP TABLE IF EXISTS gold_empresa

--
CREATE TABLE gold_empresa
AS
SELECT
	DISTINCT
	TRANSLATE (
	bm.descricao,
   'ŠŽšžŸÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÏÖÑÝåáçéíóúàèìòùâêîôûãõëüïöñýÿ',
    'SZszYACEIOUAEIOUAEIOUAOEUIONYaaceiouaeiouaeiouaoeuionyy')
    as municipio,
	CONCAT(se.cnpj_basico,se.cnpj_ordem,se.cnpj_dv) cnpj,
	sem.*,
    CONCAT(SUBSTR(CAST(se.data_situacao_cadastral as VARCHAR), 1, 4),'-',
    SUBSTR(CAST(se.data_situacao_cadastral as VARCHAR), 5, 2),'-',
    SUBSTR(CAST(se.data_situacao_cadastral as VARCHAR), 7, 2)) AS data_situacao,
    CONCAT(SUBSTR(CAST(se.data_inicio_atividade as VARCHAR), 1, 4),'-',
    SUBSTR(CAST(se.data_inicio_atividade as VARCHAR), 5, 2),'-',
    SUBSTR(CAST(se.data_inicio_atividade as VARCHAR), 7, 2)) AS data_inicio,
	TRANSLATE (
	se.bairro,
   'ŠŽšžŸÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÏÖÑÝåáçéíóúàèìòùâêîôûãõëüïöñýÿ',
    'SZszYACEIOUAEIOUAEIOUAOEUIONYaaceiouaeiouaeiouaoeuionyy')
    as bairros,
    CASE
    	WHEN sem.porte_empresa = '00' THEN 'NAO INFORMADO'
    	WHEN sem.porte_empresa = '01' THEN 'MICRO EMPRESA'
    	WHEN sem.porte_empresa = '03' THEN 'EMPRESA DE PEQUENO PORTE'
    	WHEN sem.porte_empresa = '05' THEN 'DEMAIS'
    	ELSE ''
    END as porte,
	TRANSLATE (
	bn.descricao,
   'ŠŽšžŸÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÏÖÑÝåáçéíóúàèìòùâêîôûãõëüïöñýÿ',
    'SZszYACEIOUAEIOUAEIOUAOEUIONYaaceiouaeiouaeiouaoeuionyy')
	as natureza,
    CASE
    	WHEN sem.porte_empresa = '01' THEN 'NULA'
    	WHEN sem.porte_empresa = '2' THEN 'ATIVA'
    	WHEN sem.porte_empresa = '3' THEN 'SUSPENSA'
    	WHEN sem.porte_empresa = '4' THEN 'INAPTA'
    	WHEN sem.porte_empresa = '08' THEN 'BAIXADA'
    	ELSE ''
    END as situacao,
	se.*
	EXCLUDE(
		municipio,cnpj_basico,cnpj_ordem,cnpj_dv,
		ddd1,ddd2,ddd3,telefone1,telefone2,telefone3,
		cnae_principal,cnae_secundario,
		situacao_especial,data_situacao_especial,
		tipo_logradouro,logradouro,numero,complemento,
		uf,email,data_situacao_cadastral,data_inicio_atividade,bairro
	)
FROM silver_empresa sem
INNER JOIN silver_estabelecimento se ON sem.cnpj_basico = se.cnpj_basico
INNER JOIN silver_cnae_empresa sc ON se.cnpj_basico = sc.cnpj_basico
INNER JOIN bronze_cnae bc ON sc.cnae = bc.codigo
INNER JOIN bronze_municipio bm ON se.municipio = bm.codigo
INNER JOIN bronze_natureza_juridica bn ON sem.natureza_juridica = bn.codigo
WHERE bc.descricao LIKE '% dados%' OR
	bc.descricao LIKE '%informá%' OR
	bc.descricao LIKE '%softw%' OR
	bc.descricao LIKE '%programa%' OR
	bc.descricao LIKE '%comput%' OR
	bc.descricao LIKE '%telecom%' OR
	bc.descricao LIKE '%proved%'

--
SELECT * FROM silver_estabelecimento

-- -------------------------------
DROP TABLE IF EXISTS gold_cnae

--
CREATE TABLE gold_cnae
AS
SELECT
	codigo,
	UPPER(
		TRANSLATE (
		descricao,
		'ŠŽšžŸÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÏÖÑÝåáçéíóúàèìòùâêîôûãõëüïöñýÿ',
    	'SZszYACEIOUAEIOUAEIOUAOEUIONYaaceiouaeiouaeiouaoeuionyy')
    ) as descricao
FROM
    bronze_cnae

--
COPY
	(SELECT * FROM gold_cnae)
	TO 'C:/ProfDaniloSantos/cnpj/dados/gold/cnae.csv'
	(DELIMITER ';', HEADER);

-- -------------------------------
DROP TABLE IF EXISTS gold_motivo_situacao_cadastral

--
CREATE TABLE gold_motivo_situacao_cadastral
AS
SELECT
	codigo,
	UPPER(
		TRANSLATE (
		descricao,
		'ŠŽšžŸÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÏÖÑÝåáçéíóúàèìòùâêîôûãõëüïöñýÿ',
    	'SZszYACEIOUAEIOUAEIOUAOEUIONYaaceiouaeiouaeiouaoeuionyy')
    ) as descricao
FROM
    bronze_motivo_situacao_cadastral

--
COPY
	(SELECT * FROM gold_cnae)
	TO 'C:/ProfDaniloSantos/cnpj/dados/gold/motivo_situacao_cadastral.csv'
	(DELIMITER ';', HEADER);






-- -------------------------------
DROP TABLE IF EXISTS gold_natureza_juridica

--
CREATE TABLE gold_natureza_juridica
AS
SELECT
	codigo,
	UPPER(
		TRANSLATE (
		descricao,
		'ŠŽšžŸÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÏÖÑÝåáçéíóúàèìòùâêîôûãõëüïöñýÿ',
    	'SZszYACEIOUAEIOUAEIOUAOEUIONYaaceiouaeiouaeiouaoeuionyy')
    ) as descricao
FROM
    bronze_natureza_juridica

--
COPY
	(SELECT * FROM gold_cnae)
	TO 'C:/ProfDaniloSantos/cnpj/dados/gold/natureza_juridica.csv'
	(DELIMITER ';', HEADER);

-- ------------------------------------


COPY
	(SELECT * FROM gold_empresa)
	TO 'C:/ProfDaniloSantos/cnpj/dados/gold/empresa.csv'
	(DELIMITER ';', HEADER);


-- ------------------------------------


COPY
	(SELECT * FROM silver_cnae_empresa)
	TO 'C:/ProfDaniloSantos/cnpj/dados/gold/cnae_empresa.csv'
	(DELIMITER ';', HEADER);