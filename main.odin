package main

import rl "vendor:raylib"
import "core:math/rand"
import "core:time"

LARGURA :: 480
ALTURA :: 640
VERDE :: rl.Color{3,111,61,255}
VERDE_ESCURO :: rl.Color{3 * 2, 111 * 2, 61 * 2,255}


EstadoDeJogo :: enum {
	Menu,
	Jogando,
	Pausado,
}

OpcoesMenu :: enum {
	Jogar,
	Sair,
	Nenhuma // Quando o usuário abre o jogo
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
	opcao_selecionada := OpcoesMenu.Nenhuma
	defer delete(opcoes_menu)
	
	rl.InitWindow(LARGURA, ALTURA, "Invasores do espaco")	
	defer rl.CloseWindow()
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		desenhar_estrelas(estrelas)
		switch estado {
			case .Menu:
				tamanho_fonte : i32 = 60
				titulo: cstring = "O Invasor"
				x_titulo: i32 = LARGURA / 2 - (rl.MeasureText(titulo, tamanho_fonte) / 2)
				y_titulo: i32 = ALTURA /2 - (tamanho_fonte)
				rl.DrawText(titulo, x_titulo, y_titulo, tamanho_fonte, VERDE)
				tamanho_fonte_opcao:i32 = 30
				x_opcao: i32 = LARGURA / 2 - (rl.MeasureText(opcoes_menu[.Jogar], tamanho_fonte_opcao) / 2) 
				y_opcao: i32 = y_titulo + tamanho_fonte 
				cor_opcao: rl.Color = VERDE_ESCURO
				rl.DrawText(opcoes_menu[.Jogar], x_opcao, y_opcao, tamanho_fonte_opcao, cor_opcao)
				 
			case .Jogando:
			case .Pausado:
		}
		rl.EndDrawing()
	}
}
