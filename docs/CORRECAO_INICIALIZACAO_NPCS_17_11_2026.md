# Correções de abertura no Godot — 17/11/2026

- Unificada a indentação para TAB nos cinco scripts de NPC que utilizam o indicador compartilhado: baron_abbot.gd, bridge_numbers_npc.gd, cambridge_npc.gd, professor.gd e simple_dialogue_npc.gd.
- Preservado o componente centralizado `npc_dialogue_indicator.gd` e as regras de persistência e flutuação.
- Regravado `assets/ui/inventory/dictionary.png` como PNG RGBA válido, mantendo 36x36 pixels, e conferida sua referência no HUD.
- Validação estática de indentação e integridade do ZIP realizada. Teste de importação em Godot não executado neste ambiente.
- Para evitar conflitos de cache, extrair em pasta nova e abrir `project.godot` para nova importação.
