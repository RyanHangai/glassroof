/* ==========================================================
   GlassRoof - Projeto Integrador TSE (1996 e 2016 - SP)
   Scripts T-SQL: staging complementar + 1 view por KPI
   Pre-requisito: Staging_TSE (E4) ja carregada com votos.
   Ajuste o nome do banco na linha abaixo.
   ========================================================== */
-- USE NomeDoSeuBanco;
-- GO

/* ----------------------------------------------------------
   PARTE 0 - TABELAS DE STAGING COMPLEMENTARES
   Importar via SSMS: Tasks > Import Flat File (CSV)
   ---------------------------------------------------------- */

-- Fonte: dados_limpos/socio_municipios_sp.csv
CREATE TABLE Staging_Socio_Municipio (
    municipio   VARCHAR(100),
    idhm_1991   DECIMAL(5,3),
    idhm_2010   DECIMAL(5,3),
    renda_1991  DECIMAL(10,2),
    renda_2010  DECIMAL(10,2),
    pop_1991    INT,
    pop_2010    INT
);

-- Fonte: dados_limpos/populacao_faixa_genero_sp.csv
CREATE TABLE Staging_Pop_Faixa_Genero (
    ano          INT,
    municipio    VARCHAR(100),
    genero       CHAR(1),          -- 'M' ou 'F'
    faixa_ini    INT,
    faixa_fim    INT NULL,         -- NULL = 80+
    faixa_label  VARCHAR(10),
    populacao    INT
);

-- Fonte: dados_limpos/gastos_partidos_2016.csv
CREATE TABLE Staging_Gastos_2016 (
    partido             VARCHAR(20),
    qtd_desp_estadual   INT,
    valor_estadual      DECIMAL(15,2),
    qtd_desp_municipal  INT,
    valor_municipal     DECIMAL(15,2),
    qtd_desp_total      INT,
    valor_total         DECIMAL(15,2)
);

-- Fonte: consulta_cand_2016_SP.csv (e o equivalente de 1996)
-- Se o arquivo de 1996 tiver menos colunas, deixe as demais NULL.
CREATE TABLE Staging_Candidatos (
    ANO_ELEICAO              INT,
    SG_UF                    VARCHAR(2),
    SG_UE                    VARCHAR(10),
    NM_UE                    VARCHAR(100),
    DS_CARGO                 VARCHAR(50),
    SQ_CANDIDATO             VARCHAR(20),
    NR_CANDIDATO             VARCHAR(20),
    NM_CANDIDATO             VARCHAR(150),
    SG_PARTIDO               VARCHAR(15),
    DS_GENERO                VARCHAR(20),
    DS_COR_RACA              VARCHAR(30),   -- so existe a partir de 2014
    DS_SITUACAO_CANDIDATURA  VARCHAR(60),
    DS_SIT_TOT_TURNO         VARCHAR(40)
);
GO

/* ----------------------------------------------------------
   PARTE 1 - CHECAGENS ANTES DE COMECAR (rode e olhe o resultado)
   ---------------------------------------------------------- */
-- Valores reais das colunas de filtro (ajuste os filtros das views se forem diferentes)
SELECT DISTINCT DS_SIT_TOT_TURNO          FROM Staging_Candidatos;
SELECT DISTINCT DS_SITUACAO_CANDIDATURA   FROM Staging_Candidatos;
SELECT DISTINCT DS_COR_RACA               FROM Staging_Candidatos;
SELECT DISTINCT DS_GENERO                 FROM Staging_Candidatos;
SELECT DISTINCT DS_CARGO                  FROM Staging_TSE;

-- Municipios da votacao que NAO casam com a tabela socioeconomica (problema de nome/acento)
SELECT DISTINCT t.NM_MUNICIPIO
FROM Staging_TSE t
LEFT JOIN Staging_Socio_Municipio s
       ON s.municipio COLLATE Latin1_General_CI_AI = t.NM_MUNICIPIO COLLATE Latin1_General_CI_AI
WHERE s.municipio IS NULL;
GO

/* ----------------------------------------------------------
   KPI 1 - Indice de voto por faixa de renda   (Pergunta 1)
   Faixa de renda = quartil de renda per capita MUNICIPAL
   (a renda do Atlas nao existe por zona eleitoral).
   1996 usa renda_1991; 2016 usa renda_2010.
   ---------------------------------------------------------- */
CREATE OR ALTER VIEW vw_KPI1_VotoPorFaixaRenda AS
WITH votos AS (
    SELECT YEAR(t.DT_ELEICAO) AS Ano,
           t.SG_PARTIDO,
           s.municipio,
           CASE WHEN YEAR(t.DT_ELEICAO) = 1996 THEN s.renda_1991 ELSE s.renda_2010 END AS renda,
           SUM(t.QT_VOTOS) AS Votos
    FROM Staging_TSE t
    JOIN Staging_Socio_Municipio s
      ON s.municipio COLLATE Latin1_General_CI_AI = t.NM_MUNICIPIO COLLATE Latin1_General_CI_AI
    WHERE t.DS_CARGO = 'Vereador'          -- ajuste conforme a checagem acima
    GROUP BY YEAR(t.DT_ELEICAO), t.SG_PARTIDO, s.municipio,
             CASE WHEN YEAR(t.DT_ELEICAO) = 1996 THEN s.renda_1991 ELSE s.renda_2010 END
),
faixas AS (
    SELECT *, NTILE(4) OVER (PARTITION BY Ano ORDER BY renda) AS Quartil_Renda
    FROM votos
),
agg AS (
    SELECT Ano, Quartil_Renda, SG_PARTIDO, SUM(Votos) AS Votos_Partido
    FROM faixas
    GROUP BY Ano, Quartil_Renda, SG_PARTIDO
)
SELECT Ano, Quartil_Renda, SG_PARTIDO, Votos_Partido,
       SUM(Votos_Partido) OVER (PARTITION BY Ano, Quartil_Renda) AS Votos_Validos_Faixa,
       CAST(100.0 * Votos_Partido
            / SUM(Votos_Partido) OVER (PARTITION BY Ano, Quartil_Renda) AS DECIMAL(6,2)) AS Indice_Voto_Pct
FROM agg;
GO

/* ----------------------------------------------------------
   KPI 2 - Custo por voto (CPV) por partido, 2016   (Pergunta 2)
   Gastos = despesas dos orgaos partidarios (estadual + municipal).
   Votos e eleitos = vereadores de 2016 no MESMO escopo dos gastos.
   ---------------------------------------------------------- */
CREATE OR ALTER VIEW vw_KPI2_CustoPorVoto AS
WITH votos AS (
    SELECT SG_PARTIDO, SUM(QT_VOTOS) AS Votos
    FROM Staging_TSE
    WHERE YEAR(DT_ELEICAO) = 2016 AND SG_UF = 'SP' AND DS_CARGO = 'Vereador'
    GROUP BY SG_PARTIDO
),
eleitos AS (
    SELECT SG_PARTIDO,
           COUNT(*) AS Candidatos,
           SUM(CASE WHEN DS_SIT_TOT_TURNO LIKE 'ELEITO%' THEN 1 ELSE 0 END) AS Eleitos
    FROM Staging_Candidatos
    WHERE ANO_ELEICAO = 2016 AND SG_UF = 'SP' AND DS_CARGO = 'Vereador'
      AND DS_SITUACAO_CANDIDATURA LIKE 'DEFERIDO%'
    GROUP BY SG_PARTIDO
)
SELECT g.partido,
       g.valor_total                                   AS Gasto_Total,
       v.Votos,
       e.Candidatos,
       e.Eleitos,
       CAST(g.valor_total / NULLIF(v.Votos, 0)  AS DECIMAL(10,2)) AS Custo_Por_Voto,
       CAST(g.valor_total / NULLIF(e.Eleitos, 0) AS DECIMAL(15,2)) AS Custo_Por_Eleito,
       CAST(1.0 * v.Votos / NULLIF(e.Candidatos, 0) AS DECIMAL(12,1)) AS Votos_Por_Candidato  -- concentrado x pulverizado
FROM Staging_Gastos_2016 g
LEFT JOIN votos   v ON v.SG_PARTIDO = g.partido
LEFT JOIN eleitos e ON e.SG_PARTIDO = g.partido;
GO

/* ----------------------------------------------------------
   KPI 3 - Taxa de sucesso eleitoral feminina, por partido (Pergunta 3)
   1996 e 2016. Para so a capital, acrescente: AND SG_UE = '71072'
   ---------------------------------------------------------- */
CREATE OR ALTER VIEW vw_KPI3_SucessoFeminino AS
SELECT ANO_ELEICAO AS Ano,
       SG_PARTIDO,
       COUNT(*) AS Candidatas,
       SUM(CASE WHEN DS_SIT_TOT_TURNO LIKE 'ELEITO%' THEN 1 ELSE 0 END) AS Eleitas,
       CAST(100.0 * SUM(CASE WHEN DS_SIT_TOT_TURNO LIKE 'ELEITO%' THEN 1 ELSE 0 END)
            / COUNT(*) AS DECIMAL(5,2)) AS Taxa_Sucesso_Fem_Pct
FROM Staging_Candidatos
WHERE SG_UF = 'SP'
  AND DS_CARGO = 'VEREADOR'
  AND DS_GENERO = 'FEMININO'
  AND DS_SITUACAO_CANDIDATURA LIKE 'DEFERIDO%'
GROUP BY ANO_ELEICAO, SG_PARTIDO;
GO

/* ----------------------------------------------------------
   KPI 4 - Correlacao IDHM x % de votos do partido   (Pergunta 4)
   Correlacao de Pearson calculada em T-SQL, por partido e ano.
   Precisa de VARIOS municipios na votacao (o de SP sozinho da 1 ponto).
   1996 usa idhm_1991; 2016 usa idhm_2010.
   ---------------------------------------------------------- */
CREATE OR ALTER VIEW vw_KPI4_Base_IDHM_Voto AS
WITH v AS (
    SELECT YEAR(t.DT_ELEICAO) AS Ano, t.NM_MUNICIPIO, t.SG_PARTIDO, SUM(t.QT_VOTOS) AS Votos
    FROM Staging_TSE t
    WHERE t.DS_CARGO = 'Vereador'
    GROUP BY YEAR(t.DT_ELEICAO), t.NM_MUNICIPIO, t.SG_PARTIDO
)
SELECT v.Ano, v.NM_MUNICIPIO, v.SG_PARTIDO, v.Votos,
       CAST(100.0 * v.Votos / SUM(v.Votos) OVER (PARTITION BY v.Ano, v.NM_MUNICIPIO) AS DECIMAL(6,3)) AS Pct_Votos,
       CASE WHEN v.Ano = 1996 THEN s.idhm_1991 ELSE s.idhm_2010 END AS IDHM
FROM v
JOIN Staging_Socio_Municipio s
  ON s.municipio COLLATE Latin1_General_CI_AI = v.NM_MUNICIPIO COLLATE Latin1_General_CI_AI;
GO

CREATE OR ALTER VIEW vw_KPI4_Correlacao_IDHM_Partido AS
SELECT Ano, SG_PARTIDO,
       COUNT(*) AS N_Municipios,
       CAST(
         (COUNT(*) * SUM(IDHM * Pct_Votos) - SUM(IDHM) * SUM(Pct_Votos))
         / NULLIF(SQRT( (COUNT(*) * SUM(IDHM*IDHM)         - POWER(SUM(IDHM), 2))
                      * (COUNT(*) * SUM(Pct_Votos*Pct_Votos) - POWER(SUM(Pct_Votos), 2)) ), 0)
       AS DECIMAL(6,4)) AS Correlacao_Pearson
FROM (SELECT Ano, SG_PARTIDO, CAST(IDHM AS FLOAT) AS IDHM, CAST(Pct_Votos AS FLOAT) AS Pct_Votos
      FROM vw_KPI4_Base_IDHM_Voto) x
GROUP BY Ano, SG_PARTIDO
HAVING COUNT(*) >= 10;   -- evita correlacao com poucos pontos
GO

/* ----------------------------------------------------------
   KPI 5 - Representatividade racial PPI, por partido, 2016 (Pergunta 5)
   Duas medidas: (a) taxa de sucesso = eleitos PPI / candidatos PPI (Pergunta 5)
                 (b) indice de representatividade = eleitos PPI / total de eleitos (KPI do E2)
   Raca/cor so existe a partir de 2014 -> nao ha PPI para 1996.
   ---------------------------------------------------------- */
CREATE OR ALTER VIEW vw_KPI5_RepresentatividadePPI AS
SELECT SG_PARTIDO,
       COUNT(*) AS Candidatos_Total,
       SUM(CASE WHEN ppi = 1 THEN 1 ELSE 0 END) AS Candidatos_PPI,
       SUM(CASE WHEN eleito = 1 THEN 1 ELSE 0 END) AS Eleitos_Total,
       SUM(CASE WHEN ppi = 1 AND eleito = 1 THEN 1 ELSE 0 END) AS Eleitos_PPI,
       CAST(100.0 * SUM(CASE WHEN ppi = 1 AND eleito = 1 THEN 1 ELSE 0 END)
            / NULLIF(SUM(CASE WHEN ppi = 1 THEN 1 ELSE 0 END), 0) AS DECIMAL(5,2)) AS Taxa_Sucesso_PPI_Pct,
       CAST(100.0 * SUM(CASE WHEN ppi = 1 AND eleito = 1 THEN 1 ELSE 0 END)
            / NULLIF(SUM(CASE WHEN eleito = 1 THEN 1 ELSE 0 END), 0) AS DECIMAL(5,2)) AS Representatividade_PPI_Pct
FROM (
    SELECT SG_PARTIDO,
           CASE WHEN DS_COR_RACA IN ('PRETA','PARDA') OR DS_COR_RACA LIKE 'IND%' THEN 1 ELSE 0 END AS ppi,
           CASE WHEN DS_SIT_TOT_TURNO LIKE 'ELEITO%' THEN 1 ELSE 0 END AS eleito
    FROM Staging_Candidatos
    WHERE ANO_ELEICAO = 2016 AND SG_UF = 'SP' AND DS_CARGO = 'VEREADOR'
      AND DS_SITUACAO_CANDIDATURA LIKE 'DEFERIDO%'
) c
GROUP BY SG_PARTIDO;
GO

/* ----------------------------------------------------------
   KPI 6 - Votos estimados por genero e faixa etaria   (Pergunta 6)
   Votos_estimados(faixa, genero) = Votos_totais(faixa) * %Populacao(genero, faixa)
   ATENCAO: Votos_totais(faixa) NAO existe na votacao do TSE; vem do
   "perfil do comparecimento e abstencao" (por faixa etaria). Carregue-o
   em Staging_Comparecimento_Faixa e ajuste os nomes de faixa.
   Enquanto isso, a view abaixo calcula a parte da formula que ja temos:
   %Populacao(genero, faixa) por ano, para o municipio de Sao Paulo.
   ---------------------------------------------------------- */
CREATE OR ALTER VIEW vw_KPI6_PctPopulacao_Genero_Faixa AS
SELECT p.ano, p.faixa_ini, p.faixa_label, p.genero, p.populacao,
       CAST(100.0 * p.populacao
            / SUM(p.populacao) OVER (PARTITION BY p.ano, p.faixa_ini) AS DECIMAL(5,2)) AS Pct_Genero_Na_Faixa
FROM Staging_Pop_Faixa_Genero p
WHERE p.municipio COLLATE Latin1_General_CI_AI = 'Sao Paulo'
  AND p.faixa_ini >= 20;    -- 15-19 mistura quem nao vota (<16); ajuste se quiser
GO

-- Depois de carregar o comparecimento por faixa, a estimativa fica:
-- SELECT c.ano, c.faixa_label, f.genero,
--        c.votos_totais * f.Pct_Genero_Na_Faixa / 100.0 AS Votos_Estimados
-- FROM Staging_Comparecimento_Faixa c
-- JOIN vw_KPI6_PctPopulacao_Genero_Faixa f
--   ON f.ano = c.ano_censo_ref AND f.faixa_label = c.faixa_label;
