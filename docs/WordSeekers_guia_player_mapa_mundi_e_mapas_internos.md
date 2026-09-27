# WordSeekers --- Implementação do Player no Mapa-Múndi e Mapas Internos

> Guia de implementação para Godot 4.7.1\
> Objetivos deste documento: 1. Mostrar, ao redor do player no
> mapa-múndi, setas indicando as direções disponíveis. 2. Separar o
> player do mapa-múndi do player utilizado nos mapas internos, mantendo
> uma padronização de escala e estado.

------------------------------------------------------------------------

## 1. Arquitetura que será utilizada

O WordSeekers terá duas representações do mesmo personagem:

``` text
GameState / dados do jogador
        |
        +--------------------+
        |                    |
        v                    v
WorldMapPlayer           Player
mapa-múndi              mapas internos
ponto a ponto           movimento livre
```

### `WorldMapPlayer`

Responsável somente pela navegação no mapa-múndi.

-   Move-se entre `Point01`, `Point02`, etc.
-   Consulta as conexões `up`, `down`, `left` e `right` de cada ponto.
-   Exibe setas correspondentes às direções disponíveis.
-   Permite entrar em uma cena interna quando o ponto atual possuir um
    destino.

### `Player`

Responsável pela movimentação dentro de cidades, vilas, casas, escolas e
demais mapas internos.

-   Deve ser um `CharacterBody2D`.
-   Possui animação em quatro direções.
-   Possui colisão.
-   Interage com NPCs, objetos e portas.
-   Não precisa conhecer a estrutura de `PointXX` do mapa-múndi.

Essa separação evita colocar dois sistemas de movimentação diferentes
dentro do mesmo script.

------------------------------------------------------------------------

# PARTE 1 --- Setas de direção no mapa-múndi

## 2. Manter as conexões nos MapPoints

A cena atual já possui pontos como:

``` text
Point01
Point02
Point03
...
Point10
```

Cada ponto utiliza `map_point.gd` e possui no Inspector:

``` text
Up
Down
Left
Right
```

A ideia é usar essas próprias propriedades para descobrir quais setas
devem aparecer.

Um `map_point.gd` pode seguir esta estrutura:

``` gdscript
extends Area2D

@export var up: Area2D
@export var down: Area2D
@export var left: Area2D
@export var right: Area2D
```

> Se o seu `map_point.gd` atual já possui essas propriedades, não crie
> outro script. Mantenha o existente.

Exemplo de configuração do `Point03`:

``` text
Up    = vazio
Down  = Point04
Left  = Point02
Right = vazio
```

Nesse caso, quando o jogador estiver em `Point03`, devem aparecer
somente:

``` text
      PLAYER
    ←       

       ↓
```

------------------------------------------------------------------------

## 3. Criar os indicadores no WorldMapPlayer

Abra a cena do `WorldMapPlayer`.

Crie a seguinte hierarquia:

``` text
WorldMapPlayer
├── AnimatedSprite2D
└── DirectionIndicators (Node2D)
    ├── ArrowUp (Sprite2D)
    ├── ArrowDown (Sprite2D)
    ├── ArrowLeft (Sprite2D)
    └── ArrowRight (Sprite2D)
```

Se o seu sprite atual for um `Sprite2D` em vez de `AnimatedSprite2D`,
pode mantê-lo.

O importante é que `DirectionIndicators` seja filho do `WorldMapPlayer`.

Assim, as setas acompanham automaticamente o personagem.

------------------------------------------------------------------------

## 4. Criar o asset da seta

Crie uma pequena seta em pixel art, preferencialmente apontando para
cima.

Exemplo de organização:

``` text
assets/
└── ui/
    └── world_map/
        └── direction_arrow.png
```

Você pode usar a mesma textura nas quatro direções e rotacioná-la no
Godot.

Sugestão:

``` text
ArrowUp     rotation_degrees = 0
ArrowRight  rotation_degrees = 90
ArrowDown   rotation_degrees = 180
ArrowLeft   rotation_degrees = 270
```

Se a orientação original da imagem for diferente, ajuste os valores.

------------------------------------------------------------------------

## 5. Posicionar as setas

Dentro do `WorldMapPlayer`, posicione aproximadamente:

``` text
             ArrowUp
                ↑

ArrowLeft  ←  PLAYER  →  ArrowRight

                ↓
            ArrowDown
```

Por exemplo:

``` text
ArrowUp.position    = Vector2(0, -28)
ArrowDown.position  = Vector2(0, 28)
ArrowLeft.position  = Vector2(-28, 0)
ArrowRight.position = Vector2(28, 0)
```

Esses valores são apenas uma base. Ajuste de acordo com o tamanho visual
do sprite do mapa-múndi.

------------------------------------------------------------------------

## 6. Esconder as setas inicialmente

Selecione cada `Sprite2D` de seta e desative:

``` text
Visibility > Visible
```

Ou faça isso pelo script quando a cena iniciar.

------------------------------------------------------------------------

## 7. Adicionar referências às setas no script do WorldMapPlayer

No script do `WorldMapPlayer`, adicione:

``` gdscript
@onready var arrow_up: Sprite2D = $DirectionIndicators/ArrowUp
@onready var arrow_down: Sprite2D = $DirectionIndicators/ArrowDown
@onready var arrow_left: Sprite2D = $DirectionIndicators/ArrowLeft
@onready var arrow_right: Sprite2D = $DirectionIndicators/ArrowRight
```

Também é recomendável que o script mantenha uma referência ao ponto
atual:

``` gdscript
var current_point: Area2D
```

------------------------------------------------------------------------

## 8. Criar a função que atualiza as setas

Adicione:

``` gdscript
func update_direction_indicators() -> void:
    if current_point == null:
        hide_direction_indicators()
        return

    arrow_up.visible = current_point.up != null
    arrow_down.visible = current_point.down != null
    arrow_left.visible = current_point.left != null
    arrow_right.visible = current_point.right != null
```

Agora as setas são determinadas automaticamente pelas conexões do ponto.

------------------------------------------------------------------------

## 9. Criar uma função para esconder todas as setas

``` gdscript
func hide_direction_indicators() -> void:
    arrow_up.visible = false
    arrow_down.visible = false
    arrow_left.visible = false
    arrow_right.visible = false
```

Essa função será usada enquanto o personagem estiver viajando de um
ponto para outro.

------------------------------------------------------------------------

## 10. Atualizar as setas quando o jogador chegar ao ponto

No momento em que o movimento terminar, faça:

``` gdscript
current_point = target_point
update_direction_indicators()
```

A sequência deve ser:

``` text
Jogador está no Point03
        ↓
setas aparecem
        ↓
jogador escolhe uma direção
        ↓
setas desaparecem
        ↓
player se move
        ↓
chega ao novo Point
        ↓
current_point é atualizado
        ↓
setas correspondentes aparecem
```

------------------------------------------------------------------------

## 11. Esconder as setas durante o movimento

Antes de iniciar o deslocamento:

``` gdscript
hide_direction_indicators()
```

Exemplo conceitual:

``` gdscript
func move_to_point(target_point: Area2D) -> void:
    hide_direction_indicators()

    # Executar aqui o Tween/movimento já utilizado no projeto.

    current_point = target_point
    update_direction_indicators()
```

> O trecho de movimentação deve ser integrado ao código atual do
> projeto. Não substitua o sistema existente apenas por esse exemplo.

------------------------------------------------------------------------

## 12. Opcional --- animar as setas

Uma pequena animação pode indicar melhor que as direções são
interativas.

Por exemplo, a seta direita pode oscilar alguns pixels:

``` text
posição inicial
     →

posição deslocada
        →

posição inicial
     →
```

Isso pode ser feito com `AnimationPlayer` ou `Tween`.

Uma opção simples usando `Tween`:

``` gdscript
func animate_arrow(
    arrow: Sprite2D,
    offset: Vector2
) -> void:
    var original_position := arrow.position
    var tween := create_tween().set_loops()

    tween.tween_property(
        arrow,
        "position",
        original_position + offset,
        0.35
    )

    tween.tween_property(
        arrow,
        "position",
        original_position,
        0.35
    )
```

Exemplos:

``` gdscript
animate_arrow(arrow_up, Vector2(0, -3))
animate_arrow(arrow_down, Vector2(0, 3))
animate_arrow(arrow_left, Vector2(-3, 0))
animate_arrow(arrow_right, Vector2(3, 0))
```

Essa etapa é opcional. Primeiro faça a lógica de visibilidade funcionar.

------------------------------------------------------------------------

# PARTE 2 --- Player do mapa-múndi e Player dos mapas internos

## 13. Não utilizar o mesmo controlador para os dois mapas

O personagem é o mesmo dentro da história, mas os controles são muito
diferentes.

### Mapa-múndi

``` text
WorldMapPlayer
Point → Point
```

### Mapa interno

``` text
Player
movimento livre
colisão
animações
interações
```

Por isso, utilize duas cenas.

------------------------------------------------------------------------

## 14. Organização recomendada

Estruture:

``` text
scenes/
└── player/
    ├── world_map_player.tscn
    └── player.tscn

scripts/
└── player/
    ├── world_map_player.gd
    └── player.gd

assets/
└── characters/
    └── player/
        ├── world/
        │   └── player_world.png
        └── overworld/
            └── player_walk.png
```

`world` contém a representação pequena usada no mapa-múndi.

`overworld` contém os sprites de caminhada usados nos mapas internos.

------------------------------------------------------------------------

## 15. Estrutura do WorldMapPlayer

A cena pode ficar:

``` text
WorldMapPlayer (Node2D)
├── AnimatedSprite2D
└── DirectionIndicators (Node2D)
    ├── ArrowUp
    ├── ArrowDown
    ├── ArrowLeft
    └── ArrowRight
```

Responsabilidades:

``` text
- saber em qual MapPoint está;
- verificar as conexões;
- movimentar-se entre pontos;
- exibir as setas;
- detectar quando o ponto permite entrar em um local.
```

------------------------------------------------------------------------

## 16. Estrutura do Player interno

Crie:

``` text
Player (CharacterBody2D)
├── AnimatedSprite2D
├── CollisionShape2D
└── InteractionArea (Area2D)
    └── CollisionShape2D
```

O `CharacterBody2D` será responsável pela movimentação e colisão.

O `InteractionArea` poderá ser utilizado futuramente para:

``` text
NPC
porta
placa
objeto
baú
item
```

------------------------------------------------------------------------

# PARTE 3 --- Padronização dos sprites

## 17. Não confundir tamanho do frame com tamanho visual

Um frame pode ter:

``` text
144 × 144 px
```

sem o personagem ocupar os 144 pixels.

Exemplo:

``` text
┌────────────────────┐
│                    │
│         O          │
│        /|\         │
│        / \         │
│                    │
└────────────────────┘
       144 × 144
```

O frame maior pode ser útil para manter todos os quadros alinhados.

O que deve permanecer consistente é:

-   posição dos pés;
-   centro do personagem;
-   altura visual;
-   largura visual;
-   proporção entre personagens;
-   alinhamento entre frames.

------------------------------------------------------------------------

## 18. Definir primeiro o tile size dos mapas internos

Antes de criar todos os NPCs e personagens finais, escolha o tamanho dos
tiles.

Uma opção comum é:

``` text
Tile = 32 × 32 px
```

Então você pode definir, por exemplo:

``` text
Player interno:
largura visual aproximada = 1 tile
altura visual aproximada  = 2 tiles

aproximadamente:
32 × 64 px visuais
```

Isso não significa que o arquivo/frame precisa ser `32 × 64`.

Ele pode continuar dentro de um frame maior.

------------------------------------------------------------------------

## 19. Escala do mapa-múndi

O mapa-múndi representa uma região muito maior. Portanto, o personagem
funciona como um marcador.

Uma referência inicial pode ser:

``` text
WorldMapPlayer:
aproximadamente 24 × 32 px visuais
```

Ajuste conforme a escala do mapa atual.

O importante é não tentar representar a escala física real do personagem
no continente.

------------------------------------------------------------------------

## 20. Evitar depender de Scale para corrigir assets

Sempre que possível, deixe:

``` text
Scale X = 1
Scale Y = 1
```

e prepare os sprites próximos do tamanho em que serão utilizados.

Evite depender de algo como:

``` text
Scale = 0.18
```

para transformar um sprite muito grande em um sprite de mapa-múndi.

Em pixel art, escalas fracionárias podem deixar pixels inconsistentes.

------------------------------------------------------------------------

## 21. Configuração de pixel art

Para sprites de pixel art, evite filtragem que deixe a imagem borrada.

No Godot, verifique as configurações de textura/importação e utilize
filtragem adequada para pixel art (nearest/sem suavização).

Também procure trabalhar com posições e escalas que não deformem os
pixels.

------------------------------------------------------------------------

# PARTE 4 --- Entrada em mapas internos

## 22. Fazer um MapPoint possuir uma cena de destino

Nem todo ponto precisa levar para um mapa interno.

Podemos ampliar `map_point.gd`:

``` gdscript
extends Area2D

@export var up: Area2D
@export var down: Area2D
@export var left: Area2D
@export var right: Area2D

@export var destination_scene: PackedScene
```

No Inspector, um ponto que representa uma vila poderia receber:

``` text
Destination Scene:
village_01.tscn
```

Um ponto sem local acessível deixa:

``` text
Destination Scene:
<empty>
```

------------------------------------------------------------------------

## 23. Verificar se o ponto permite entrada

No `WorldMapPlayer`:

``` gdscript
func can_enter_current_point() -> bool:
    return (
        current_point != null
        and current_point.destination_scene != null
    )
```

Ao apertar o botão de ação:

``` gdscript
func try_enter_location() -> void:
    if not can_enter_current_point():
        return

    get_tree().change_scene_to_packed(
        current_point.destination_scene
    )
```

O botão pode ser associado a uma ação como:

``` text
interact
```

no `Input Map`.

------------------------------------------------------------------------

# PARTE 5 --- Guardar a posição no mapa-múndi

## 24. Problema que precisamos resolver

Imagine:

``` text
World Map
   ↓
Point03
   ↓
Village
```

Depois que o jogador sair da vila, queremos:

``` text
Village
   ↓
World Map
   ↓
Point03
```

e não:

``` text
Village
   ↓
World Map
   ↓
Point01
```

Precisamos guardar o ponto atual.

------------------------------------------------------------------------

## 25. Criar um GameState

Crie:

``` text
scripts/systems/game_state.gd
```

Exemplo inicial:

``` gdscript
extends Node

var world_map_point_name: StringName = &"Point01"
```

------------------------------------------------------------------------

## 26. Transformar GameState em Autoload

No Godot:

``` text
Projeto
→ Configurações do Projeto
→ Globais / Autoload
```

Adicione:

``` text
res://scripts/systems/game_state.gd
```

Nome:

``` text
GameState
```

Agora ele continuará existindo mesmo quando trocarmos de cena.

------------------------------------------------------------------------

## 27. Salvar o ponto antes de entrar

Antes de trocar para o mapa interno:

``` gdscript
GameState.world_map_point_name = current_point.name
```

Depois:

``` gdscript
get_tree().change_scene_to_packed(
    current_point.destination_scene
)
```

------------------------------------------------------------------------

## 28. Restaurar o ponto ao voltar ao mapa-múndi

Quando `world_map.tscn` carregar novamente, procure o ponto salvo.

Exemplo conceitual:

``` gdscript
func restore_world_position() -> void:
    var point := get_node_or_null(
        "../" + String(GameState.world_map_point_name)
    )

    if point == null:
        return

    current_point = point
    global_position = current_point.global_position
    update_direction_indicators()
```

O caminho exato dependerá da hierarquia final de `world_map.tscn`.

Uma solução ainda melhor, quando refinarmos o mapa, será colocar todos
os pontos dentro de um nó:

``` text
WorldMap
├── Map
├── Points
│   ├── Point01
│   ├── Point02
│   ├── Point03
│   └── ...
├── WorldMapPlayer
└── Camera2D
```

Assim podemos procurar explicitamente em:

``` gdscript
$Points.get_node(...)
```

------------------------------------------------------------------------

# PARTE 6 --- Fluxo final

## 29. Fluxo no mapa-múndi

``` text
Carrega world_map.tscn
        ↓
Lê GameState
        ↓
Posiciona WorldMapPlayer no ponto salvo
        ↓
Consulta:
up/down/left/right
        ↓
Mostra setas disponíveis
        ↓
Jogador escolhe direção
        ↓
Esconde setas
        ↓
Move até outro Point
        ↓
Atualiza current_point
        ↓
Mostra novas setas
```

------------------------------------------------------------------------

## 30. Fluxo para entrar em uma cidade

``` text
WorldMapPlayer chega ao Point
        ↓
Point possui destination_scene?
        ↓
       SIM
        ↓
Jogador aperta "interact"
        ↓
Salva Point atual no GameState
        ↓
Carrega mapa interno
        ↓
Player interno aparece
```

------------------------------------------------------------------------

## 31. Fluxo para sair da cidade

``` text
Player alcança saída
        ↓
Carrega world_map.tscn
        ↓
WorldMapPlayer consulta GameState
        ↓
Encontra Point salvo
        ↓
Posiciona-se nesse Point
        ↓
Exibe as direções disponíveis
```

------------------------------------------------------------------------

# PARTE 7 --- Ordem recomendada de implementação

Implemente nesta ordem:

1.  Manter/testar as conexões `Up`, `Down`, `Left` e `Right` dos
    `MapPoints`.
2.  Criar `DirectionIndicators`.
3.  Adicionar as quatro setas.
4.  Implementar `update_direction_indicators()`.
5.  Testar as setas sem animação.
6.  Esconder as setas enquanto o player se move.
7.  Fazer as setas reaparecerem quando ele chega ao destino.
8.  Opcionalmente animar as setas.
9.  Organizar `world_map_player.tscn`.
10. Criar `player.tscn` separado para mapas internos.
11. Definir o tile size dos mapas internos.
12. Padronizar a escala visual dos personagens.
13. Criar `destination_scene` nos `MapPoints`.
14. Criar a ação `interact`.
15. Criar `GameState` como Autoload.
16. Salvar o ponto atual antes de entrar em uma cena.
17. Restaurar o ponto quando voltar ao mapa-múndi.
18. Implementar a saída dos mapas internos.

------------------------------------------------------------------------

# PARTE 8 --- Estrutura sugerida após a implementação

``` text
WordSeekers-Game/
├── assets/
│   ├── characters/
│   │   └── player/
│   │       ├── world/
│   │       │   └── player_world.png
│   │       └── overworld/
│   │           └── player_walk.png
│   └── ui/
│       └── world_map/
│           └── direction_arrow.png
│
├── maps/
│   ├── world/
│   └── village/
│
├── scenes/
│   ├── player/
│   │   ├── world_map_player.tscn
│   │   └── player.tscn
│   ├── world/
│   │   └── world_map.tscn
│   └── levels/
│
├── scripts/
│   ├── player/
│   │   ├── world_map_player.gd
│   │   └── player.gd
│   └── systems/
│       └── game_state.gd
│
├── map_point.gd
└── project.godot
```

------------------------------------------------------------------------

# Checklist

## Mapa-múndi

-   [ ] `MapPoint` possui `up`, `down`, `left`, `right`.
-   [ ] `WorldMapPlayer` conhece o `current_point`.
-   [ ] As quatro setas existem.
-   [ ] Somente direções válidas ficam visíveis.
-   [ ] Setas somem durante o movimento.
-   [ ] Setas reaparecem ao chegar ao destino.
-   [ ] Pontos podem opcionalmente possuir `destination_scene`.

## Mapas internos

-   [ ] Existe `player.tscn` separado.
-   [ ] Root é `CharacterBody2D`.
-   [ ] Existe `AnimatedSprite2D`.
-   [ ] Existe `CollisionShape2D`.
-   [ ] Movimento interno é independente do mapa-múndi.
-   [ ] Tile size foi definido antes de produzir todos os assets finais.

## Troca de cenas

-   [ ] Existe `GameState`.
-   [ ] `GameState` está configurado como Autoload.
-   [ ] O ponto atual é salvo.
-   [ ] A cena interna é carregada pelo ponto.
-   [ ] Ao retornar, o jogador volta ao ponto correto.

------------------------------------------------------------------------

## Próxima etapa recomendada

Antes de copiar os exemplos deste documento diretamente para os scripts
existentes, compare-os com o código atual de:

``` text
map_point.gd
world_map_player.gd
```

Os exemplos deste guia descrevem a arquitetura desejada. Os métodos de
movimentação e os nomes dos nós devem ser integrados ao código que já
existe no projeto, evitando duplicar sistemas.

Depois disso, a primeira implementação prática deve ser o **sistema de
setas do `WorldMapPlayer`**, pois ele aproveita diretamente a estrutura
`Up/Down/Left/Right` que o mapa já possui.
