package main

import rl "vendor:raylib"
import "core:math/rand"
import "core:time"

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


main :: proc() {
	estado := EstadoDeJogo.Menu
	rand.set_global_seed(u64(time.to_unix_nanoseconds(time.now())))
	estrelas := inicializar_estrelas()
	opcoes_menu := make(map[OpcoesMenu]cstring)
	opcoes_menu[.Jogar] = "Jogar"
	opcoes_menu[.Sair] = "Sair"
	opcao_selecionada := OpcoesMenu.Jogar
	defer delete(opcoes_menu)
	continuar := true
	
	rl.InitWindow(LARGURA, ALTURA, "Invasores do espaco")	
	defer rl.CloseWindow()
	for (!rl.WindowShouldClose() && continuar == true){
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		desenhar_estrelas(estrelas)
		switch estado {
			case .Menu:
				tamanho_fonte : i32 = FONTE_BASE * 2
				titulo: cstring = "O Invasor"
				x_titulo: i32 = LARGURA / 2 - (rl.MeasureText(titulo, tamanho_fonte) / 2)
				y_titulo: i32 = ALTURA /2 - (tamanho_fonte)
				rl.DrawText(titulo, x_titulo, y_titulo, tamanho_fonte, VERDE)

				tamanho_fonte_opcao:i32 = FONTE_BASE + 10 if opcao_selecionada == .Jogar else FONTE_BASE
				cor_opcao: rl.Color = VERDE_CLARO if opcao_selecionada == .Jogar else VERDE
				x_opcao: i32 = LARGURA / 2 - (rl.MeasureText(opcoes_menu[.Jogar], tamanho_fonte_opcao) / 2) 
				y_opcao: i32 = y_titulo + tamanho_fonte 
				rl.DrawText(opcoes_menu[.Jogar], x_opcao, y_opcao, tamanho_fonte_opcao, cor_opcao)

				tamanho_fonte_opcao = FONTE_BASE + 10 if opcao_selecionada == .Sair else FONTE_BASE
				cor_opcao = VERDE_CLARO if opcao_selecionada == .Sair else VERDE
				x_opcao = LARGURA / 2 - (rl.MeasureText(opcoes_menu[.Sair], tamanho_fonte_opcao) / 2) 
				y_opcao += tamanho_fonte
				rl.DrawText(opcoes_menu[.Sair], x_opcao, y_opcao, tamanho_fonte_opcao, cor_opcao)

				if rl.IsKeyPressed(.DOWN) {
					opcao_selecionada = .Sair if opcao_selecionada == .Jogar else .Jogar	
				} else if rl.IsKeyPressed(.UP) {

					opcao_selecionada = .Jogar if opcao_selecionada == .Sair else .Sair	
				}	

				if rl.IsKeyPressed(.ENTER) {
					#partial switch opcao_selecionada {
						case .Sair:
							continuar = false
						case .Jogar:
							estado = .Jogando
					}	
				}
				 
			case .Jogando:
				rl.DrawText("Pressione <ESC> para sair!", 1,100,FONTE_BASE,VERDE_CLARO)
			case .Pausado:
		}
		rl.EndDrawing()
	}
}
