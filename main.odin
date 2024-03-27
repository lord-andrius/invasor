package main

import rl "vendor:raylib"
import "core:math/rand"
import "core:time"
import "sprites"

LARGURA :: 480
ALTURA :: 640
VERDE :: rl.Color{3,111,61,255}
VERDE_CLARO :: rl.Color{3 * 2, 111 * 2, 61 * 2,255}
FONTE_BASE :: 30


EstadoDeJogo :: enum {
	Menu,
	Jogando,
	Pausado,
}

OpcoesMenu :: enum {
	Jogar,
	Sair,
}

BufferEstrelas: [100]rl.Vector3
inicializar_estrelas :: proc() -> []rl.Vector3 {
	qtd_estrelas := rand.int31_max(len(BufferEstrelas))
	for i in 0..=qtd_estrelas {
		BufferEstrelas[i][0] = f32(rand.int31_max(LARGURA) + 1)
		BufferEstrelas[i][1] = f32(rand.int31_max(ALTURA) + 1)
		BufferEstrelas[i][2] = rand.float32() 
	}
	return BufferEstrelas[:qtd_estrelas + 1]
}

desenhar_estrelas :: proc(estrelas: []rl.Vector3) {
	for estrela in estrelas {
		rl.DrawRectangleV({estrela[0], estrela[1]}, estrela[2], rl.WHITE)
	}
}

menu :: proc(opcoes_menu: map[OpcoesMenu]cstring, opcao_selecionada: ^OpcoesMenu, estado:^EstadoDeJogo,continuar: ^bool) {
	tamanho_fonte : i32 = FONTE_BASE * 2
	titulo: cstring = "O Invasor"
	x_titulo: i32 = LARGURA / 2 - (rl.MeasureText(titulo, tamanho_fonte) / 2)
	y_titulo: i32 = ALTURA /2 - (tamanho_fonte)
	rl.DrawText(titulo, x_titulo, y_titulo, tamanho_fonte, VERDE)

	tamanho_fonte_opcao:i32 = FONTE_BASE + 10 if opcao_selecionada^ == .Jogar else FONTE_BASE
	cor_opcao: rl.Color = VERDE_CLARO if opcao_selecionada^ == .Jogar else VERDE
	x_opcao: i32 = LARGURA / 2 - (rl.MeasureText(opcoes_menu[.Jogar], tamanho_fonte_opcao) / 2) 
	y_opcao: i32 = y_titulo + tamanho_fonte 
	rl.DrawText(opcoes_menu[.Jogar], x_opcao, y_opcao, tamanho_fonte_opcao, cor_opcao)

	tamanho_fonte_opcao = FONTE_BASE + 10 if opcao_selecionada^ == .Sair else FONTE_BASE
	cor_opcao = VERDE_CLARO if opcao_selecionada^ == .Sair else VERDE
	x_opcao = LARGURA / 2 - (rl.MeasureText(opcoes_menu[.Sair], tamanho_fonte_opcao) / 2) 
	y_opcao += tamanho_fonte
	rl.DrawText(opcoes_menu[.Sair], x_opcao, y_opcao, tamanho_fonte_opcao, cor_opcao)

	if rl.IsKeyPressed(.DOWN) {
		opcao_selecionada^ = .Sair if opcao_selecionada^ == .Jogar else .Jogar	
	} else if rl.IsKeyPressed(.UP) {

		opcao_selecionada^ = .Jogar if opcao_selecionada^ == .Sair else .Sair	
	}	

	if rl.IsKeyPressed(.ENTER) {
		#partial switch opcao_selecionada^ {
			case .Sair:
				continuar^ = false
			case .Jogar:
				estado^ = .Jogando
		}	
	}
 }


 desenha_sprite :: proc(sprite: [][]rune, x:i32, y:i32,scala: i32 = 5,vazio: rune = sprites.CARACTERE_VAZIO, claro: rune = sprites.CARACTERE_CLARO, escuro: rune = sprites.CARACTERE_ESCURO) {
	y := y
	for linha in sprite {
		x_tmp := x
		for coluna in linha {
			if coluna == claro {
				rl.DrawRectangle(x_tmp,y,scala,scala,VERDE_CLARO)
			} else if coluna == escuro {
				rl.DrawRectangle(x_tmp,y,scala,scala, VERDE)
			}
			x_tmp += scala
		}
		y += scala
	}

 }


main :: proc() {
	estado := EstadoDeJogo.Menu
	rand.set_global_seed(u64(time.to_unix_nanoseconds(time.now())))
	estrelas := inicializar_estrelas()
	opcoes_menu := make(map[OpcoesMenu]cstring)
	opcoes_menu[.Jogar] = "Jogar"
	opcoes_menu[.Sair] = "Sair"
	defer delete(opcoes_menu)
	opcao_selecionada := OpcoesMenu.Jogar
	x_nave: i32 = 0
	y_nave: i32 = 0
	continuar := true
	
	rl.InitWindow(LARGURA, ALTURA, "Invasores do espaco")	
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)
	for (!rl.WindowShouldClose() && continuar == true){
		frame_time := rl.GetFrameTime()
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		desenhar_estrelas(estrelas)
		switch estado {
			case .Menu:
				menu(opcoes_menu, &opcao_selecionada, &estado, &continuar)	
			case .Jogando:
				desenha_sprite(sprites.SPRITE_JOGADOR[:][:], x_nave, y_nave)
				if rl.IsKeyDown(.LEFT) {
					x_nave -= i32((1 + frame_time) * 5)
				} else if rl.IsKeyDown(.RIGHT) {
					x_nave += i32((1 + frame_time) * 5)
				}
			case .Pausado:
		}
		rl.EndDrawing()
	}
}
