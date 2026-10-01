CREATE TABLE #staging_candidatos_1996(
    data_geracao DATE,
    hh_gerecao TIME,
    ano_eleicao INT,
    cd_tipo_eleicao INT,
    nm_tipo_eleicao VARCHAR(50),
    nr_turno INT,
    cd_eleicao INT,
    ds_eleicao VARCHAR(100),
    dt_eleicao DATE,
    tp_abrangencia VARCHAR(100),
    sg_uf VARCHAR(10),
    sg_ue INT,
    nm_ue VARCHAR(100),
    cd_cargo INT,
    ds_cargo VARCHAR(100),
    sq_candidato BIGINT,
    nr_candidato INT,
    nm_candidato VARCHAR(100),
    nm_urna_candidato VARCHAR(100),
    nm_social_candidato VARCHAR(100),
    nr_cpf_candidato VARCHAR(50),
    ds_email VARCHAR(100),
    cd_situacao_candidatura INT,
    ds_situacao_candidatura VARCHAR(50),
    tp_agremiacao VARCHAR(100),
    nr_partido INT,
    sg_partido VARCHAR(50),
    nm_partido VARCHAR(100),
    nr_federacao INT,
    nm_federacao VARCHAR(100),
    sg_federacao VARCHAR(50),
    ds_composicao_federacao VARCHAR(100),
    sq_coligacao INT,
    nm_coligacao VARCHAR(100),
    ds_composicao_coligacao VARCHAR(100),
    sg_uf_nascimento VARCHAR(100),
    dt_nascimento DATE,
    nr_titulo_eleitoral_candidato VARCHAR(100),
    cd_genero INT,
    ds_genero VARCHAR(50),
    cd_grau_instrucao INT,
    ds_grau_instrucao VARCHAR(50),
    cd_estado_civil INT,
    ds_estado_civil VARCHAR(50),
    cd_cor_raca INT,
    ds_cor_raca VARCHAR(50),
    cd_ocupacao INT,
    ds_ocupacao VARCHAR(50),
    cd_sit_tot_turno INT,
    ds_sit_tot_turno VARCHAR(50)
);

-- Usei um BULK INSERT ao inves de fazer no Excel
-- Eu fiz o INSERT manualmente quando os arquivos não estavam em .csv

BULK INSERT #staging_candidatos_1996
FROM '/caminho/para/arquivo.csv'
WITH (
FIRSTROW = 2,
FIELDTERMINATOR = ';',
ROWTERMINATOR = '\n',
CODEPAGE = '65001',
TABLOCK -- Bloqueia a tabela durante a operação
);
-- o comando acima só funciona se o arquivo estiver no mesmo ambiente de execucao, nesse caso na AWS
