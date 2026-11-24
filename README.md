# WordSeekers

Jogo 2D de inglês para o 6º e 7º ano do Ensino Fundamental, desenvolvido em Godot 4.7. Abra `project.godot`, aguarde a importação dos recursos e execute a cena principal com **F6 apenas para testar uma cena isolada** ou **F5 para iniciar o jogo**. O PC é a plataforma prioritária.

Este README reúne o estado da versão de trabalho e as instruções atuais. Nas listas de estado, **[x]** significa implementado ou conferido conforme a descrição da linha. **[ ]** significa trabalho ou validação pendente. A lista de entrega deve ser reaplicada a cada nova versão.

## Progresso do jogo

| Faixa | Cidades | Identificação no mapa |
|---|---|---|
| Tutorial | Colchester | Fácil, fundo verde |
| Nível 1 | Cambridge, Canterbury, Birmingham, Nottingham, Winchester | Fácil, fundo verde |
| Nível 2 | York, Stratford, Bath, Londres, Manchester | Médio, fundo amarelo |
| Nível 3 | Newcastle, Liverpool, Oxford, Salisbury, Plymouth | Difícil, fundo vermelho |

- [x] Mapa-múndi com nome da cidade e dificuldade. O próximo nível abre após concluir ao menos um diálogo em cada uma das cinco cidades do nível anterior. O aviso de cidade bloqueada fecha com **E**.
- [x] Seleção com quatro opções, de **Aparência 1** a **Aparência 4**, usando os sprites do jogador da base oficial.
- [x] Birmingham, Nottingham, Oxford, Londres com interiores, Plymouth e Bath com as piscinas integrados. O capitão e Francis em Plymouth mantêm diálogos sem quiz ou aula de passado simples. A cidade não tem caça-palavras.
- [x] Entradas e saídas por área automática, com setas vermelhas animadas em escala reduzida e seta azul com ícone de mapa nas saídas externas. A mensagem **Saída para o mapa** aparece por proximidade.
- [x] Seis templos padrão em Colchester, York, Newcastle, Liverpool, Stratford e Londres, com cálice compartilhado para recuperação de HP. A King's College Chapel de Cambridge tem cena própria. Canterbury e Winchester ficam fora do conjunto de templos padrão.
- [x] Mina de Newcastle com baú, retorno à cidade e dois NPCs que ensinam leitura de instruções e placas.
- [x] Trilha `cities_theme.ogg` nas cidades externas e coral de entrada dos templos.

## NPCs, currículo e ferramentas

- [x] Interação **[E] Falar**, indicador de exclamação azul-claro aumentado e persistência do registro de conversa. As aulas usam português para ensinar inglês, sem áudio nas aulas e diálogos.
- [x] Colchester apresenta a missão em português. Charles Abbott incentiva conversas e entrega o Dicionário, Irmã Agnes explica HP e templos, e o guia das ruínas apresenta **H** (Ajuda) e **I** (Mochila). A orientação histórica sobre o nome romano aponta para Cambridge.
- [x] Mathematical Bridge com três NPCs para cardinais, ordinais e multiplicativos. Cardinais e ordinais cobrem 0–10, as dezenas, 100 e 1000.
- [x] Dicionário com três usos por **T** ou botão. A Lupa, entregue pelo Guardião de York, tem três usos e destaca a primeira letra de uma palavra pendente. Ícones e rótulos seguem a mesma disposição, com texto abaixo do ícone.
- [x] Oito caça-palavras de exploração, além do desafio do chefe.

| Local | Dificuldade |
|---|---|
| Colchester, Roman Walls | Fácil, grade 8 × 8, com CASTLE, CITY, WALLS e LEARN |
| Winchester, Grande Salão | Fácil |
| Oxford, Biblioteca Bodleian | Fácil |
| York | Médio |
| Bath | Médio |
| Londres, Museu | Médio |
| Londres, interior da Academia | Difícil |
| Liverpool, escritório do Royal Albert | Difícil |

## Batalhas e encerramento

- [x] Cem conjuntos de encontro, com três perguntas e cinco alternativas nos quizzes comuns. Um conjunto conta ao ser encontrado e não volta ao sorteio, mesmo em caso de derrota. O progresso fica em `user://`.
- [x] Jogador à esquerda, monstro à direita, quiz no topo com até 650 px, feedback verde ou vermelho e explicação destacada. Barra de HP do monstro comum azul em 3 HP, amarela em 2 HP e vermelha em 1 HP, com sons de dano.
- [x] NPC de Londres entrega o **Pergaminho do Conhecimento**, que registra o percentual de diálogos acompanhados pelo item e os encontros. A batalha final exige o Pergaminho, 100% desses diálogos e 100 encontros, independentemente das vitórias.
- [x] A cutscene inicia a luta contra o **Vocabullary Eater**, com 10 HP. Sequência de quatro perguntas médias, um caça-palavras difícil que não tira HP do jogador, quatro perguntas difíceis e três frases embaralhadas no **Feitiço das Palavras**.
- [x] O chefe encerra com discurso em português. Os créditos rolam e dão lugar aos cinco retratos da equipe com a trilha **Última Luz do Reino** durante os 30 segundos da tela de agradecimento. O retorno automático ao mapa permite conversar com os NPCs com os encontros desativados.
- [x] Testes automatizados no Godot 4 cobriram os três blocos do feitiço, o fluxo de discurso e créditos, a reprodução da faixa e o retorno ao mapa com interação de NPC.

## Pendências confirmadas

- [ ] Conferir o currículo de **6º ano** por tópico e atividade: inglês como língua franca, cumprimentos e apresentações, vocabulário básico, cognatos e falsos cognatos, skimming e scanning, textos funcionais, verbo to be, artigos, pronomes pessoais, possessivos, plurais, genitivo e imperativos.
- [ ] Conferir o currículo de **7º ano** por tópico e atividade: variação linguística, alimentos e quantificadores, saúde, esportes e hobbies, Simple Present e Present Continuous, can/could, demonstrativos, conectores de sequência e polissemia.
- [ ] Definir o tratamento da **compreensão oral**. Há questões escritas sobre o tema. Uma atividade de escuta continua em aberto e deve respeitar a decisão de manter aulas e diálogos sem áudio.
- [ ] Confirmar quais artes de **Bath, Londres e Plymouth** são definitivas e percorrer as três cidades para validar portais, colisões, entradas e pontos de retorno.
- [ ] Testar manualmente os dois NPCs, os obstáculos, o baú e o retorno da **mina de Newcastle**.
- [ ] Rodar uma campanha completa no Godot, da introdução ao pós-jogo, pelos caminhos normais: níveis, NPCs, 100 encontros, salvamento, cutscene, chefe, créditos e retorno ao mapa.
- [ ] Na próxima entrega solicitada, gerar e verificar o ZIP completo com as alterações mais recentes. `WordSeekers_Final_Atualizado.zip` é anterior aos créditos e à trilha de encerramento.

## Instruções de manutenção

- A referência oficial é `WordSeekers_atualizada.zip`, fornecida pela colega. Preserve os sprites do jogador e as correções dessa base. Integre contribuições seletivamente, prefira os pacotes .7z recentes de Birmingham e Nottingham e evite merges automáticos com versões históricas. Não reintroduza Cidade Fantasia, Cena1, Point02 ou templos padrão de Canterbury e Winchester.
- Use `snake_case` para arquivos novos. Cenas de cidades e interiores ficam em `scenes/locations/`, templos em `scenes/temples/`, mapa-múndi em `scenes/world/`, interfaces em `scenes/ui/` e lógica em `scripts/`. Separe recursos por cidade em `assets/environments/` e preserve `shared/` para recursos reutilizados. Mapas em PNG devem passar para WebP, com atualização dos caminhos `res://`. Preserve o pixel art dos personagens, com referência de 24 × 32 px por quadro.
- Ao adicionar uma cidade, configure cena, conexões, nome e dificuldade do MapPoint, NPCs, entradas e saídas. Use `StaticBody2D` com `CollisionPolygon2D` para obstáculos e `Area2D` para detecção. Posicione o retorno fora do gatilho de entrada. Preserve os pontos históricos e placas de Colchester, incluindo Roman Walls, Colchester Castle e St Botolph's Priory.
- Mova recursos pelo FileSystem do Godot quando possível e preserve os arquivos `.uid`. Revise caminhos `res://`, dependências e a ordem dos blocos de recursos antes dos nós em cenas editadas. Dados de progresso ficam em `user://`; não os inclua no projeto.

## Checklist de cada entrega

- [ ] Abrir e executar a cena principal no Godot. Revisar erros de scripts, indentação, conflitos de merge e dependências ausentes.
- [ ] Testar as cenas alteradas, colisões, portais nos dois sentidos, NPCs, HUD e sobreposições em diferentes tamanhos de janela.
- [ ] Testar geração dos caça-palavras, seleção de palavras, Lupa e persistência. Conferir som e volume das transições alteradas.
- [ ] Revisar tamanho e duplicatas. Excluir recursos somente após conferir referências e uso. Montar o ZIP com `project.godot`, cenas, scripts e recursos necessários, sem cache `.godot/`, histórico `.git/` ou backups.
- [ ] Verificar a integridade do ZIP. No relatório, registrar arquivos adicionados, alterados e excluídos, tamanho antes e depois, conflitos resolvidos e validações pendentes.

## Referências e histórico

- [Histórico do projeto](docs/historico/) reúne os relatórios de integração, correções, guias e instruções antigas, incluindo as notas de templo anteriormente espalhadas nas cenas. Consulte este README para o estado vigente.
- [Cenas Word See](docs/reference/Cenas%20Word%20See.pdf) é um esboço pedagógico de cinco cidades. Inclui alfabeto fonético, estações, clima e pontos cardeais. Use a lista curricular atual acima como referência para a revisão.
