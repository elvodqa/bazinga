import raylib;
version = RAYGUI_IMPLEMENTATION;
import raygui;

import std.stdio;
import core.stdc.string : strlen;
import std.conv : to;
import std.string;
import bazinga.game;
import std.path;
import std.file;

const string VERSION = "0.0.1";

string window_title;
string game_location;
Game game;
Font ui_font;

int main(string[] args)
{
    if (args.length > 1) {
        if (args[1] == "repl") {
            import bazinga.parser;
            while (true) {
                write(">>> ");
                auto test_string = readln();
                CommandParser parser = new CommandParser(test_string);

                foreach (command; parser.commands) {
                    writeln(command);
                }
            }
        }
        else if (args[1] == "parser") {
            import bazinga.parser;
            auto test = `
            talk Emir "Hello world!"
            set_actor_sprite Emir happy
            add_actor Emir sad
            remove_actor Emir
            set_scene School
            set_window_title "AAA"
            `;

            CommandParser parser = new CommandParser(test);
            foreach (command; parser.commands) {
                writeln(command);
            }
        }
        else {
            game_location = args[1];
            
            try {
                game_location = absolutePath(game_location);
                game = load_game(game_location);
            }
            catch (std.file.FileException e) {
                writeln("Invalid path: " ~ game_location);
                writeln(e.msg);
                return 1;
            }

            // Load scripts without parsing them.
            import bazinga.game;
            foreach (string name; dirEntries(game_location, SpanMode.breadth)) {
                if (endsWith(name, ".baz")) {
                    writeln("Found script: " ~ name);
                    auto parts = name.split("/");
                    auto file = parts[parts.length - 1];
                    auto scene_name = file[0 .. $ - 4];
                    writeln("Script name: " ~ scene_name);
                    Script script;
                    auto splitScript = scene_name.split("_");
                    script.value = to!int(splitScript[1]);
                    script.location = name;
                    game.scripts ~= script;
                }
            }
            
            window_title = game.title;
            run_game();
        }
    }
    else {
        no_game();
    }
    
    return 0;
}

enum GameState {
    MainMenu,
    Pause,
    Playing,
}

GameState game_state;
bool is_settings_open = false;
float volume = 50.0f;
float text_speed = 5.0f;

void run_game() {
    validateRaylibBinding();
    SetConfigFlags(ConfigFlags.FLAG_VSYNC_HINT | ConfigFlags.FLAG_WINDOW_RESIZABLE);
    InitWindow(1280, 720, "Bazinga");
    SetWindowTitle(toStringz(game.title));
    SetTargetFPS(60);

    ui_font = LoadFontEx("resources/fonts/Aller_Rg.ttf", 20, cast(int*)0, 0);
    GuiSetFont(ui_font);
    

    game_state = GameState.MainMenu;
    
    while (!WindowShouldClose())
    {
        switch (game_state) {
            case GameState.MainMenu:
                BeginDrawing();
                    ClearBackground(Colors.BLACK);
                    //DrawTextEx(ui_font, toStringz(game.title), Vector2(10, 10), 20, 0, Colors.WHITE);

                    // Draw Play, Load, Options, Quit buttons at the bottom left of the screen. Use window size to calculate.
                    if (GuiButton(Rectangle(50, GetScreenHeight() - 150, 200, 40), "Quit")) {
                        CloseWindow();
                        static import core.stdc.stdlib;
                        core.stdc.stdlib.exit(0);
                    }
                    if (GuiButton(Rectangle(50, GetScreenHeight() - 200, 200, 40), "Settings")) {
                        is_settings_open = !is_settings_open;
                    }
                    GuiButton(Rectangle(50, GetScreenHeight() - 250, 200, 40), "Load");
                    GuiButton(Rectangle(50, GetScreenHeight() - 300, 200, 40), "Play");
                    

                    if (is_settings_open) {
                        // Gui WindowBox at the center 600x400
                        if (GuiWindowBox(Rectangle(GetScreenWidth() / 2 - 250, GetScreenHeight() / 2 - 300, 500, 600), "Settings")) {
                            is_settings_open = false;
                        }
                        // Gui Slider for volume
                        GuiLabel(Rectangle(GetScreenWidth() / 2 - 150, GetScreenHeight() / 2 - 265, 100, 10), "Volume");
                        volume = GuiSlider(Rectangle(GetScreenWidth() / 2 - 220, GetScreenHeight() / 2 - 250, 200, 40), "", toStringz(to!string(volume)), volume, 0, 100);

                        // Gui Slider for Text speed
                        GuiLabel(Rectangle(GetScreenWidth() / 2 - 160, GetScreenHeight() / 2 - 165, 100, 10), "Text Speed");
                        text_speed = GuiSlider(Rectangle(GetScreenWidth() / 2 - 220, GetScreenHeight() / 2 - 150, 200, 40), "", toStringz(to!string(text_speed)), text_speed, 1, 10);
                    }
                    
                EndDrawing();
                break;
            case GameState.Playing:
                
                break;
            case GameState.Pause:
                
                break;
            default:
            break;
        }
    }
    CloseWindow();
}

void no_game() {
    validateRaylibBinding();
    
    SetConfigFlags(ConfigFlags.FLAG_VSYNC_HINT | ConfigFlags.FLAG_WINDOW_RESIZABLE);
    InitWindow(1280, 720, "Bazinga - No Game :/");

    ui_font = LoadFontEx("resources/fonts/Aller_Rg.ttf", 20, cast(int*)0, 0);

    SetTargetFPS(60);
    while (!WindowShouldClose())
    {
        BeginDrawing();
        ClearBackground(Colors.BLACK);
        DrawTextEx(ui_font, "No game specified!", Vector2(10, 10), 20, 0, Colors.WHITE);
        DrawTextEx(ui_font, "Please specify a game to run.", Vector2(10, 50), 20, 0, Colors.WHITE);
        DrawTextEx(ui_font, "Usage: bazinga <game>", Vector2(10, 90), 20, 0, Colors.WHITE);
        EndDrawing();
    }
    CloseWindow();
}