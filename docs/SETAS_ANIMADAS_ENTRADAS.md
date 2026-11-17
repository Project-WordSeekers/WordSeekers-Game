# Indicadores animados de entrada (16 portais)

Sprite sheet compartilhada: `res://assets/ui/entrance_arrow_sheet.webp` (6 quadros de 112x128; sequência na horizontal, transparência RGBA, WebP lossless).
Cena reutilizável: `res://scenes/ui/entrance_arrow.tscn`.
Script: `res://scripts/ui/entrance_arrow.gd` (7 quadros/segundo, animação contínua).

A animação segue **alto → desce até a ponta amarela → sobe**. A seta fica 65 pixels acima do centro de cada Area2D; o elemento é puramente visual e não intercepta colisões. A entrada continua automática ao caminhar pela Area2D, sem pressionar E.

Entradas: Cambridge (biblioteca, capela); Colchester (templo); Liverpool (escritório); Newcastle (mina, templo); Nottingham (castelo, cavernas); Salisbury (catedral, Stonehenge); Stratford (casa de Anne Hathaway, casa natal Shakespeare, teatro); Winchester (Grande Salão, catedral); York (templo).

Não são exibidos indicadores nas saídas para o mapa-múndi nem nos retornos dentro dos interiores. Cidades sem entradas implementadas não recebem setas fictícias.

Validação: 16 instâncias, recursos e ZIP verificados estaticamente; execução Godot 4 ainda não verificada.
