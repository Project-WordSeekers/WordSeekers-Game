# Correção do aviso de cidade bloqueada

Causa: ao fechar o aviso com E, `DialogueUI` consumia o evento, mas
`world_map_player.gd` podia reconhecer o mesmo E como nova tentativa de
entrar na cidade, abrindo o aviso novamente no mesmo frame.

Correção: os avisos do mapa-múndi passam callback `_on_map_warning_closed`,
que ativa `_wait_interact_release` no jogador. Esse bloqueio é removido
somente quando E for solto. O `DialogueUI` ignora repetição automática da tecla.

Aplicado tanto a cidades bloqueadas por nível quanto a cidades sem cena.
Não altera a progressão, as batalhas, os demais diálogos, os interiores
ou as setas animadas.

Teste sugerido: chegar a uma cidade bloqueada, pressionar E, soltar,
pressionar E novamente para fechar; movimentar o player logo em seguida.
Também testar manter E pressionado e abrir/fechar o aviso de cidade indisponível.

O Godot não foi executado neste ambiente; verificação estática e do ZIP apenas.
