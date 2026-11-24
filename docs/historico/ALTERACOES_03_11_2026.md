# WordSeekers — mudanças de 03/11/2026

- 100 quizzes reformulados, 3 perguntas e 5 alternativas em inglês, explicações em português.
- O monstro inicia automaticamente a batalha aleatória, elogia o jogador ao completar 3 acertos e foge; vitória retorna ao MapPoint de chegada.
- Um quiz é reservado ao iniciar a batalha e não volta a ser sorteado, mesmo em caso de derrota. Histórico salvo em `user://wordseekers_progress.json`.
- Nível 1: Cambridge, Canterbury, Birmingham, Nottingham, Winchester.
- Nível 2: York, Stratford, Bath, London, Manchester.
- Nível 3: Newcastle, Liverpool, Oxford, Salisbury, Plymouth.
- O nível seguinte abre após finalizar diálogo com ao menos um NPC nas 5 cidades do anterior. Colchester é livre.
- Os MapPoints sem destino foram conectados TEMPORARIAMENTE à cena genérica `cidade_fantasia.tscn`; cidades sem NPC receberam um guia temporário. Esses mapas/NPCs precisam ser substituídos pelos definitivos.
- Mantida chance progressiva de batalha 5%, 10%, 15% ... a cada viagem sem batalha.

## Validação pendente
O editor/executável Godot não está instalado neste ambiente. O projeto foi modificado e empacotado, mas **não foi executado nem testado em jogo**. Verifique importação e fluxo de batalhas no Godot 4 antes de usar como versão final.
