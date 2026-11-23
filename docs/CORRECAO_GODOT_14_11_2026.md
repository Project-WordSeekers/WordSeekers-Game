# Correções de importação e entrada no templo — 14/11/2026

- `scripts/npcs/irma_agnes.gd`: corrigida indentação misturada (tabs e espaços) na função `_on_dialogue_closed`.
- Reorganizadas as declarações `[ext_resource]` que estavam abaixo de `[sub_resource]` em cinco cenas: `cidade_fantasia.tscn`, `salisbury.tscn`, `stratford.tscn`, `cidade13_winchester.tscn` e `temple.tscn`.
- Mantidas todas as cidades e cenas de Newcastle, mina, York e Manchester.
- Verificado que os caminhos `res://` declarados em `ext_resource` existem dentro do ZIP.

## Como testar
1. Feche o Godot e extraia este ZIP em uma pasta nova.
2. Abra o `project.godot` da pasta extraída; aguarde a importação de imagens e scripts.
3. Execute o jogo e teste entrada e saída do templo de Colchester.
4. Se aparecerem erros, copie os primeiros erros vermelhos (não apenas os avisos amarelos de UID).

A engine Godot 4 não estava disponível neste ambiente; teste de execução pendente.
