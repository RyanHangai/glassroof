# GlassRoof

Projeto de Business Intelligence sobre dados eleitorais do TSE (eleições municipais de São Paulo, 1996 e 2016), do Projeto Integrador da Faculdade Impacta. Integra Innovation Lab Applied BI, Relational Database Programming (T-SQL) e Business Intelligence.

## Objetivo

Responder às perguntas estratégicas e acompanhar os KPIs definidos na matriz de requisitos (`requisitos.md`), com um dashboard interativo, da extração dos dados à visualização.

## Tecnologias

- **Banco de dados:** SQL Server (testes locais em Docker e restore em Windows; AWS RDS como destino do projeto)
- **Linguagens:** T-SQL, DAX
- **BI:** Power BI, Power Query

## Estrutura do repositório

| Pasta / arquivo | Conteúdo |
| --- | --- |
| `dados_brutos/` | Arquivos originais (TSE, Atlas, IBGE) |
| `dados_limpos/` | CSVs tratados que alimentam as tabelas de staging |
| `scripts_sql/` | Staging, checagens e views dos KPIs |
| `COMO_USAR.md` | Ordem de execução dos scripts |
| `requisitos.md` | Matriz de requisitos e KPIs |

## Fases do projeto

### Fase 1: Governança e escopo
- [x] Project Charter
- [x] Requisitos: 6 perguntas de negócio e 6 KPIs

### Fase 2: Infraestrutura e engenharia T-SQL
- [x] Staging Area: votação, candidatos, gastos, IDHM/renda e população carregados
- [x] Views dos KPIs 1 a 6 (KPI 6 parcial)
- [ ] Modelagem Star Schema
- [ ] Dicionário de dados
- [ ] DDL e DML (procedures de carga)

### Fase 3: ETL e Power BI
- [x] Conexão do Power BI ao SQL Server
- [x] Modelo tabular com relacionamentos 1:* (`dim_Partido`, `dim_Ano`, `Socio_Municipio`)
- [ ] Medidas DAX (em andamento: KPI 1, 2 e 4)
- [ ] Dashboard (cerca de 4 gráficos por KPI, em andamento)

### Fase 4: Auditoria e apresentação
- [ ] Conciliação entre consultas SQL e valores do Power BI
- [ ] Apresentação final

## Equipe

Ana Luiza Malumbres Botelho, Arthur Gomes Guerra, Júlio da Silva Magno, Ryan de Vasconcelos Hangai e Michel H. de Paula Domingues.

*Projeto acadêmico - Faculdade Impacta*
