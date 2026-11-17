# Como usar os scripts T-SQL

Ordem de execução do arquivo `scripts_sql/GlassRoof_TSQL.sql`:

1. Importe os 3 CSVs da pasta `dados_limpos/` pelo SSMS (Tasks > Import Flat File) ou pelo DBeaver. Eles têm exatamente as colunas das tabelas `Staging_Socio_Municipio`, `Staging_Pop_Faixa_Genero` e `Staging_Gastos_2016`. Os sufixos "(SP)" dos nomes, os rodapés e a linha "Brasil" já foram removidos.
2. Rode a **Parte 0** do script para criar as tabelas de staging complementares.
3. Importe `consulta_cand_2016_SP.csv` (e o equivalente de 1996) em `Staging_Candidatos`. A votação (`Staging_TSE`) já deve estar carregada (roteiro E4).
4. Rode as consultas da **Parte 1** (checagens). Elas mostram os valores reais de cargo, situação e raça/cor, e os municípios que não casam com a tabela de renda/IDHM. Se algum valor for diferente de `Vereador`, `ELEITO%` ou `DEFERIDO%`, ajuste os filtros das views.
5. Crie as views dos KPIs 1 a 6 e consulte cada uma com `SELECT * FROM vw_KPI...`.

## Observações

- KPI 6: falta carregar o comparecimento por faixa etária (TSE) em `Staging_Comparecimento_Faixa`; a view atual calcula só a parte `%População(gênero, faixa)`.
- KPI 5: raça/cor só existe a partir de 2014, então não há PPI para 1996.
