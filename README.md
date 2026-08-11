# GlassRoof

Este repositório contém os artefatos e a documentação do Projeto de Business Intelligence voltado para a análise de dados eleitorais do Tribunal Superior Eleitoral (TSE). O projeto tem como base ensinar como funciona o BI na prática, integrando governança de dados, engenharia no banco de dados e visualização, como parte do Roteiro Integrado da Faculdade Impacta.

## Objetivo
Responder a perguntas estratégicas de negócio e acompanhar KPIs fundamentais das eleições por meio de um dashboard interativo, garantindo a qualidade e governança da extração à visualização dos dados.

## Tecnologias Utilizadas
* **Banco de Dados & Nuvem:** SQL Server, AWS (Amazon Web Services)
* **Linguagens:** T-SQL, DAX
* **Business Intelligence:** Power BI, Power Query

## Papéis da Equipe
O projeto simula uma consultoria estruturada de BI, com a equipe dividida nos seguintes papéis:
* **Scrum Master / PM:** Gestão e Governança
* **Engenheiro de Dados:** T-SQL e AWS Sandbox
* **Analista de BI:** Power Query, DAX e Dashboard
* **Analista de Dados:** Validação e Storytelling

## Fases do Projeto

### Fase 1: Governança & Escopo
* [x] **Project Charter:** Termo de abertura, justificativa, escopo e Matriz de Riscos.
* [ ] **Requisitos:** Mapeamento de 8 KPIs e 10 perguntas estratégicas de negócio.

### Fase 2: Infraestrutura & Modelagem (Engenharia T-SQL)
* [ ] **AWS & Staging Area:** Provisionamento do SQL Server na AWS e carga bruta.
* [ ] **Modelagem Star Schema:** Criação do modelo relacional dimensional.
* [ ] **Dicionário de Dados:** Documentação técnica completa (PKs, FKs, Surrogate Keys).
* [ ] **DDL & DML:** Scripts de criação e procedures de carga, tratamento de nulos e duplicados.

### Fase 3: ETL & Power BI
* [ ] **ETL Power Query:** Conexão, limpeza e transformações documentadas.
* [ ] **Modelo Tabular:** Configuração de relacionamentos (1:N) e ocultação de chaves técnicas.
* [ ] **Medidas DAX:** Criação de pelo menos 12 medidas (Time Intelligence, CALCULATE, etc.).
* [ ] **Dashboard (UX/UI):** Design visual em 4 páginas com foco na jornada do usuário (Visão Geral, Análise Regional, Perfil do Eleitorado, Detalhamento de Candidatos).

### Fase 4: Auditoria & Apresentação
* [ ] **Governança & Audit:** Validação e conciliação (batimento) entre consultas SQL (AWS) e valores do Power BI.
* [ ] **Pitch Executivo:** Apresentação final dos resultados alcançados.

## Modelagem Dimensional
O banco de dados foi estruturado no formato Star Schema, contendo:
* **Tabela Fato:** `Fato_Votacao` (com a métrica de `Qtd_Votos`).
* **Dimensões:** `Dim_Candidato`, `Dim_Municipio_Zona`, `Dim_Partido` e `dCalendario`.

---
*Projeto acadêmico - Faculdade Impacta*
