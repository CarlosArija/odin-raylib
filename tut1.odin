package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "vendor:raylib"

SCREEN_WIDTH : i32 : 1024
SCREEN_HEIGHT : i32 : 800

//MOVABLE
Movable :: struct{
	position: raylib.Vector2,
	direction: f32,
	advance: raylib.Vector2,
	color: raylib.Color,
}

main :: proc() {
	
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
	zombies := make([dynamic]Movable, 1000) 
	defer( delete(zombies) )
	for &z in zombies {
		z.position = raylib.Vector2{ 
			rand.float32_uniform(0, f32(SCREEN_WIDTH)), 
			rand.float32_uniform(0, f32(SCREEN_HEIGHT)) }
		z.direction = rand.float32_uniform(0.0, 2*PI)
		z.color = RED
	} 

	//HUMANS
	humans := make([dynamic]Movable, 1000)
	defer( delete(humans) )
	for &h in humans {
		h.position = raylib.Vector2{ 
			rand.float32_uniform(0, f32(SCREEN_WIDTH)), 
			rand.float32_uniform(0, f32(SCREEN_HEIGHT)) }
		h.direction = rand.float32_uniform(0.0, 2*PI)
		h.color = BLUE
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
		
		update_movables(zombies)
		update_movables(humans)
	}
}

update_movables :: proc(movables: [dynamic]Movable){
	using raylib

	for &m in movables {
		m.advance.x = math.cos(m.direction)
		m.advance.y = math.sin(m.direction)
	}

	for m in movables {
		dir := m.position + m.advance * 10.0
		DrawCircleV(m.position, 5, m.color)
		DrawLineV(m.position, dir, GREEN)
	}

	for &m in movables {
		m.position = m.position + m.advance
		m.direction += rand.float32_uniform(-PI*0.05, PI*0.05)
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

