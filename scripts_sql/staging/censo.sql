CREATE TABLE #staging_censo(
    codigo_municipio INT,
    nome_municipio VARCHAR(100),
    total_pop_2000 INT,
    -- A coluna total_pop_2000 nao serve para nenhum tipo de conta das colunas desta tabela, mas ta na base de dados entao vou colocar aqui
    total_homens INT,
    total_mulheres INT,
    total_pop_urbana INT,
    total_pop_rural INT,
    total_pop_2010 INT
);

INSERT INTO dbo.#staging_censo(codigo_municipio, nome_municipio,
    total_pop_2000, total_homens, total_mulheres, total_pop_urbana,
    total_pop_rural, total_pop_2010
) VALUES
(),
