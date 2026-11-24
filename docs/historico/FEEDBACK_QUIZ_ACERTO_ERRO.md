# Feedback visual de respostas do quiz
- Acerto: opção correta em verde; painel próprio de confirmação com fundo verde-escuro, borda verde, ícone de confirmação e explicação ampliada, seguido do atalho `[E] Próxima pergunta`.
- Erro: opção escolhida em vermelho (permanece marcada na mesma questão, inclusive após mover a seleção). O jogador pode tentar outra resposta.
- A cor do Dicionário continua destacando a opção revelada, mas o retorno de acerto/erro prevalece.
- O feedback visual é zerado ao avançar para a próxima questão e ao concluir/fechar o quiz.
- O quiz permanece no topo, com largura máxima de 650 px, preservando o botão do Dicionário fora do HUD, o cenário e os monstros.
- Conferência estática do código e do ZIP realizada; execução no Godot 4 pendente.
