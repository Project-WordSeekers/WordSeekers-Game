# WordSeekers — Guia do projeto

Jogo 2D desenvolvido em **Godot 4.7.1**. Este repositório organiza os recursos para que a equipe encontre rapidamente os arquivos e evite quebrar referências entre cenas.

## Primeiros passos

1. Abra a pasta `WordSeekers` no **Godot 4.7.1** usando o arquivo `project.godot`.
2. Aguarde a importação dos recursos (imagens, áudio e vídeos). Após a reorganização, o Godot recriará os metadados `.import` necessários.
3. Execute a cena principal configurada no projeto.
4. Antes de enviar alterações ao grupo, teste a cidade e as transições que você modificou.

## Organização de pastas

```text
assets/
  audio/
    music/               trilhas
    ambience/            áudio ambiente
    sfx/                 efeitos sonoros novos
  characters/
    player/              sprites do jogador
    npcs/
      colchester/        NPCs exclusivos da cidade
      cambridge/
      stratford/
      temples/           freiras e NPCs dos templos
      shared/            NPCs genéricos
    shared/              sprite sheets compartilhadas
  environments/
    world_map/           mapa-múndi e elementos de cenário do mapa
    colchester/          cenário da cidade
    canterbury/
    cambridge/
    winchester/
    stratford/
    salisbury/
    shared/              cenários genéricos e protótipos ainda utilizados
  ui/
    icons/               ícones gerais
    inventory/           itens de inventário
  videos/                vídeos de introdução
scenes/
  locations/             cenas de cidades e interiores
  temples/               base e variações dos templos
  minigames/             cenas de minijogos
  player/                cenas do jogador
  ui/                    HUD, diálogo, introdução
  world/                 mapa-múndi e MapPoints
scripts/
  player/                movimento e mapa-múndi
  npcs/                  comportamento dos personagens
  systems/               estado, transições, portais, salvamento
  minigames/             caça-palavras e outros minijogos
  ui/                    controladores de interface
data/
  dialogues/             dados de diálogo futuros
  word_search/           desafios futuros
  quests/                missões futuras
```

Pastas como `data/` e `assets/audio/sfx/` podem ainda não conter arquivos: são destinos previstos para conteúdo novo.

## Convenções

- **Arquivos e pastas novos:** letras minúsculas, `snake_case`, sem acentos e sem espaços.
- **Uma cidade, uma pasta:** recursos exclusivos ficam na pasta da cidade correspondente.
- **Compartilhados:** use `shared/` apenas quando o recurso for reutilizado.
- **Scripts:** em `scripts/`, não misturar código com imagens.
- **Cenas:** em `scenes/`, separadas por função ou cidade.
- **PNG ou WebP:** preferir WebP para cenários grandes; manter PNG quando transparência/pixel art exigir precisão.
- **Nomes de nós no Godot:** não precisam ser renomeados apenas para acompanhar a pasta.

## Colisões e portais

- Obstáculos de cenário: `StaticBody2D` com `CollisionPolygon2D`, editável pelos vértices no editor.
- Portais, NPCs e interações: `Area2D` com área de detecção; não bloquear fisicamente o jogador.
- O retorno de um templo deve levar à cidade de origem, fora do gatilho de entrada.

## Caça-palavras

- Lógica em `scripts/minigames/`.
- Protótipo: **Roman Walls (Colchester)**, grade 8×8, palavras `CASTLE`, `CITY`, `WALLS`, `LEARN`.
- A **Lupa** é entregue pelo Guardião de York e tem três usos. Cada uso destaca a primeira letra de uma palavra pendente no caça-palavras.
- O progresso usa `user://` e não deve ser colocado dentro de `assets/`.

## Como adicionar uma cidade

1. Crie `assets/environments/nome_da_cidade/`.
2. Crie `scenes/locations/nome_da_cidade/`.
3. Coloque NPCs exclusivos em `assets/characters/npcs/nome_da_cidade/`.
4. Configure MapPoint, entrada e retorno; confira o nome exibido no mapa-múndi.
5. Teste colisões, portais, NPCs e carregamento das texturas.

## Trabalho em equipe

- **Mova/renomeie arquivos preferencialmente pelo FileSystem do editor Godot**; ele pode atualizar dependências.
- Antes de fazer merge, compare cenas e scripts alterados por cada pessoa.
- Evite editar a mesma cena `.tscn` em paralelo.
- Não inclua `.godot/`, arquivos temporários, backups ou histórico `.git` nos ZIPs de entrega.
- Arquivos `.gd.uid` e `.ogv.uid` pertencem aos recursos e devem acompanhá-los quando movidos.
- Após mover imagens com `.import` antigo, permita que o editor regenere os imports e verifique os recursos.
- Abra a aba **Debugger → Errors** ao testar; um ZIP íntegro não garante que o projeto compile.

## Observação sobre esta reorganização

Os arquivos existentes foram realocados, com atualização textual dos caminhos `res://` e de referências explícitas. **A compilação e os testes de execução no Godot precisam ser realizados no editor** antes de integrar a versão ao trabalho principal da equipe.

## Padrões de jogabilidade e produção adotados

### Personagens e sprites
- **Jogador e NPCs em pixel art:** referência de **24 × 32 pixels** por quadro.
- Visuais planejados para o jogador: **humano masculino, humano feminino, elfo masculino e elfo feminino**. Elfos usam orelhas pontudas e traços delicados.
- Animações direcionais devem manter orientação e tamanho de quadros consistentes; verificar alternância das pernas e um quadro de repouso por direção.
- NPCs exclusivos de uma cidade ficam em sua pasta; personagens reutilizáveis ficam em `shared/` ou `temples/`.
- **Irmã Agnes** é a freira de hábito preto e branco no templo de Colchester. Os demais sprites de freiras ficam disponíveis para uso futuro.

### Mapa-múndi e cidades
- O mapa-múndi é a central de navegação. **Cada MapPoint representa uma cidade** e deve ter nome e conexões coerentes com o mapa.
- O nome mostrado no **canto superior direito** deve refletir o MapPoint atual; não deve ficar fixo em Colchester.
- As setas entre cidades precisam ser revistas quando um MapPoint mudar de posição.
- Um MapPoint pode existir **sem cena interna**; nesse caso, não inventar um destino.
- **Colchester** é a cidade inicial de referência e deve preservar **St Botolph's Priory, Roman Walls e Colchester Castle**, com suas placas de identificação.
- A cidade deve conservar a entrada/saída principal inferior do mapa e os pontos históricos previstos.
- **Charles Abbott**, Barão de Colchester, fica em frente à fonte.
- Cidades com trabalho já integrado incluem Colchester, Canterbury, Cambridge, Winchester, Stratford-upon-Avon e Salisbury. Outras cidades podem ter apenas MapPoints ou conteúdo parcial.

### Colisões e interações
- Obstáculos físicos do cenário: preferir **`StaticBody2D` + `CollisionPolygon2D`**, com vértices editáveis no editor 2D.
- **`Area2D`** é para detecção de proximidade, portais e interações; não substituir indiscriminadamente essas áreas por obstáculos físicos.
- A colisão do próprio jogador pode continuar usando `CollisionShape2D`.
- A ação de interação no PC usa **E** (`interact` no Input Map, quando configurado).
- Portais devem evitar reentrada automática e transições repetidas. O ponto de retorno deve ficar **fora** da área que aciona a entrada.

### Templos
- Os templos usam **um modelo de interior compartilhado**, com variações de NPCs e diálogos por cidade.
- Cada cidade tem seu próprio **ponto de entrada externo**; ao entrar, o jogador aparece sempre **no mesmo ponto interno** do templo.
- Ao sair, o jogador deve voltar à **cidade de origem**, próximo à respectiva porta, mas fora do gatilho.
- Cidades previstas para templos: **Colchester, York, Newcastle, Liverpool, Stratford, London, Canterbury, Winchester e Bath**.
- **Não considerar todos os portais conectados:** a vinculação deve ser feita e testada cidade por cidade. Colchester é o caso inicial de referência.
- O templo de Colchester inclui a Irmã Agnes, com três falas sobre a história do Priorado de St Botolph.

### Caça-palavras e diário
- O caça-palavras aparece como **livro/diário**, sobre a exploração.
- O protótipo das **Roman Walls de Colchester** é de dificuldade **Fácil**, grade **8 × 8**, com quatro palavras em inglês: **CASTLE, CITY, WALLS e LEARN**.
- A seleção de palavras é feita arrastando entre a primeira e a última letra; o sistema valida a sequência e destaca acertos.
- O gerador deve aceitar dificuldade e tamanho de grade configuráveis. Referência de progressão: Fácil 8×8; Médio 12×12; Difícil 16×16.
- O progresso do desafio é salvo em **`user://`**; não colocar dados de salvamento dentro de `assets/`.
- O botão da **Lupa** fica disponível com saldo de usos e sem uma dica ativa.
- O sistema deve ser reutilizável por outros NPCs e locais, sem duplicar a lógica do gerador.

### Plataforma e interface
- **PC é a plataforma prioritária neste momento.** O suporte mobile foi adiado; não adicionar controles de toque/joystick virtual sem decisão da equipe.
- Manter elementos de HUD, diálogos e minijogos separados dos scripts de movimentação e das cenas de cidade.
- Não fixar nomes de cidades, NPCs ou destinos em elementos de interface que devem ser dinâmicos.

### Arquivos, versões e entregas
- Manter **cenários grandes preferencialmente em WebP** para reduzir o tamanho dos ZIPs; preservar a legibilidade e testar importação.
- Não reconverter sprites de pixel art automaticamente para WebP com perdas: avaliar cada recurso.
- **Não reintroduzir `Cena1`** nem referências ao seu nome; ela foi retirada do fluxo do projeto.
- Evitar recuperar arquivos antigos de `point02` e outros testes descartados sem justificar seu uso.
- Entregas completas em ZIP devem conter `project.godot`, cenas, scripts e assets necessários, **sem `.git/` e sem cache `.godot/`**.
- Ao integrar versões de colegas, **comparar primeiro** os dois projetos, preservar alterações independentes e verificar referências após o merge.
- Após alterações em `.tscn`, confirmar que declarações `[ext_resource]` e `[sub_resource]` aparecem antes dos blocos `[node]`.
- **Verificação de ZIP e caminhos não substitui teste no Godot**: abrir o projeto, aguardar importação e testar as transições, colisões e interfaces modificadas.

## Checklist antes de enviar mudanças ao grupo

- [ ] Arquivos novos seguem `snake_case` e estão na pasta correta.
- [ ] Cenas abrem sem erros de parsing ou recursos ausentes.
- [ ] MapPoints exibem o nome correto e as setas levam aos destinos esperados.
- [ ] Colisões impedem passagem somente onde necessário.
- [ ] Portais funcionam na entrada e na saída sem piscar ou reativar em loop.
- [ ] Interações por **E** não conflitam com outros NPCs ou portais próximos.
- [ ] Desafios de caça-palavras geram grade, reconhecem palavras e mantêm o progresso.
- [ ] Recursos movidos foram reimportados e seus caminhos atualizados.
- [ ] O projeto foi testado no Godot antes de ser tratado como versão estável.

## Exceção: King's College Chapel (Cambridge)

- A **King's College Chapel** de Cambridge é uma capela histórica própria da cidade, **não é um templo** do sistema compartilhado.
- Manter sua cena em `scenes/locations/cambridge/capela/capela.tscn` e sua imagem em `assets/environments/cambridge/capela/chapel_interior.webp`.
- **Não** trocar o fundo da capela pelo template de templo, nem direcionar seu portal para `scenes/temples/`.
- Os templos das demais cidades usam `scenes/temples/temple.tscn` e o cenário compartilhado `assets/environments/shared/temple_interior.webp`.
- Quando o fundo compartilhado mudar, revisar visualmente as colisões e a posição de NPCs e portais; o tamanho da imagem, sozinho, não garante alinhamento.
