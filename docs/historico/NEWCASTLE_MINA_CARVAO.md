# Mina de Carvão — Newcastle

## Implementado
- Interior `res://scenes/locations/newcastle/coal_mine.tscn` com imagem WebP (1536x1024).
- 25 polígonos de colisão nas paredes rochosas, ilhas de pedra e obstáculos.
- Os dois túneis com trilhos são inacessíveis por colisão.
- Entrada pela mina em Newcastle e retorno à cidade, com spawn de retorno `FromMine`.
- Baú interativo: tecla E perto do baú ou clique com o mouse enquanto estiver próximo.
- Pergaminho estilizado exibindo a mensagem inglesa solicitada exatamente:
  "The most valuable treasure of all is knowledge! Keep your studies."
- Tradução na caixa de diálogo padrão (estilo NPC):
  "O tesouro mais valioso de todos é o conhecimento! Continue seus estudos."
- A interface fecha ao pressionar E; o player fica imóvel enquanto o diálogo estiver aberto.

## Pendências
- NPCs da mina (2 a 3): posições e diálogos ainda não definidos.
- Teste dentro do Godot 4: ajuste fino dos polígonos, abertura do baú, clique, retorno e transições.
- O fundo contém o título e seta desenhados na arte; são elementos visuais, não texto dinâmico.
