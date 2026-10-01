CREATE TABLE #staging_governadores_eleitos(
    nome VARCHAR(50),
    incio DATE,
    fim DATE,
    observacao VARCHAR(100)
);
INSERT INTO staging_governadores_eleitos (nome, inicio, fim, observacao)
VALUES
('Roberto Costa de Abreu Sodré', '1967-01-31', '1971-03-15', 'Falecido em 14 de setembro de 1999'),
('Laudo Natel', '1971-03-15', '1975-03-15', NULL),
('Paulo Egydio Martins', '1975-03-15', '1979-03-15', NULL),
('Paulo Salim Maluf', '1979-03-15', '1982-05-14', NULL),
('José Maria Marin', '1982-05-14', '1983-03-15', NULL),
('André Franco Montoro', '1983-03-15', '1987-03-15', 'Falecido em 16 de julho de 1999'),
('Orestes Quércia', '1987-03-15', '1991-03-15', 'Falecido em 24 de dezembro de 2010'),
('Luiz Antonio Fleury Filho', '1991-03-15', '1995-01-01', NULL),
('Mário Covas Júnior', '1995-01-01', '1999-01-01', 'Falecido em 6 de março de 2001'),
('Mário Covas Júnior', '1999-01-01', '2001-03-06', 'Falecido em 6 de março de 2001'),
('Geraldo Alckmin', '2001-03-06', '2003-01-01', NULL),
('Geraldo Alckmin', '2003-01-01', '2006-03-31', NULL),
('Claudio Lembo', '2006-03-31', '2007-01-01', NULL),
('José Serra', '2007-01-01', '2010-04-02', NULL),
('Alberto Goldman', '2010-04-02', '2011-01-01', NULL),
('Geraldo Alckmin', '2011-01-01', '2015-01-01', NULL),
('Geraldo Alckmin', '2015-01-01', '2018-04-06', 'Afastado para concorrer a Presidência da República'),
('Márcio França', '2018-04-06', '2019-01-01', NULL),
('João Doria', '2019-01-01', NULL, 'Em exercício');
