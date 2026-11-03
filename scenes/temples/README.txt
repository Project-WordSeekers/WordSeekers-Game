Templos padrão com cálice de recuperação de HP — WordSeekers

Cidades autorizadas (6): Colchester, York, Newcastle, Liverpool, Stratford e London (Londres).

Cenas: temple_colchester.tscn, temple_york.tscn, temple_newcastle.tscn,
temple_liverpool.tscn, temple_stratford.tscn, temple_london.tscn.

Cena compartilhada: temple.tscn (cálice, jogador, efeitos e saída).
Cena compartilhada de NPC: temple_npc.tscn (também usada fora de templos).

Cenas antigas temple_canterbury.tscn e temple_winchester.tscn foram removidas.
Canterbury, Winchester e demais cidades fora da lista não devem receber templo padrão.

Colchester já possui portal de entrada e retorno. As novas cenas dos outros cinco
locais estão disponíveis, mas NÃO foram ligados portais sem determinar a posição
correta das entradas nos mapas. York, Newcastle e London ainda não possuem cenas
próprias de cidade nesta versão (utilizam placeholders). É necessário integrar
essas cidades e conectar entradas com scene_portal.gd e spawn de retorno.

Não confundir o NPC reutilizável temple_npc.tscn com uma cena de templo.
