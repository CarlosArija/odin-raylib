package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "vendor:raylib"

main :: proc() {
	SCREEN_WIDTH : i32 : 800
	SCREEN_HEIGHT : i32 : 450
	
	using raylib

	V_ZERO := Vector2{ 0.0, 0.0}
	V_HALF_SCREEN := Vector2 { f32(SCREEN_WIDTH) * 0.5, f32(SCREEN_HEIGHT) * 0.5 }

	//WINDOW
	InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - basic window")
	defer(CloseWindow())

	//FPS
	SetTargetFPS(60)
	
	//CAMERA2D
	camera := Camera2D{ V_HALF_SCREEN, V_HALF_SCREEN, 0.0, 1.0 } //target, offset, rotation, zoom

	//ZOMBIES
	Zombie :: struct{
		position: raylib.Vector2,
		direction: f32,
		advance: raylib.Vector2,
	}
	zombies := make([dynamic]Zombie, 100) 
	defer( delete(zombies) )

	for &z in zombies {
		z.position = raylib.Vector2{ 
			rand.float32_uniform(0, f32(SCREEN_WIDTH)), 
			rand.float32_uniform(0, f32(SCREEN_HEIGHT)) }
		z.direction = rand.float32_uniform(0.0, 2*PI)	
	} 

	//PLAYER
	player := Rectangle { V_HALF_SCREEN.x, V_HALF_SCREEN.y, 10, 10 }

	//LOOP
	for !WindowShouldClose() {
		update_states(&player, &camera)

		BeginDrawing()
		defer(EndDrawing())
		BeginMode2D(camera)
		defer(EndMode2D())

		// DRAWING 
		ClearBackground(RAYWHITE)
		DrawRectangleRec(player, RED)
		
		for &z in zombies {
			z.advance.x = math.cos(z.direction)
			z.advance.y = math.sin(z.direction)
		}

		for z in zombies {
			dir := z.position + z.advance * 10.0
			DrawCircleLinesV(z.position, 5, BLACK)
			DrawLineV(z.position, dir, RED)
		}

		for &z in zombies {
			z.position = z.position + z.advance
			z.direction += rand.float32_uniform(-PI*0.05, PI*0.05)
		}
	}
}

update_states :: proc(player: ^raylib.Rectangle, camera: ^raylib.Camera2D){
	if raylib.IsKeyDown(raylib.KeyboardKey.D) { player.x += 2 }
	if raylib.IsKeyDown(raylib.KeyboardKey.A) { player.x -= 2 }
	if raylib.IsKeyDown(raylib.KeyboardKey.W) { player.y -= 2 }
	if raylib.IsKeyDown(raylib.KeyboardKey.S) { player.y += 2 }
	
	camera.target.x, camera.target.y = player.x, player.y
	camera.zoom += f32(raylib.GetMouseWheelMove()) * 0.05
}

