import raylib;
import std.stdio;
import core.stdc.string : strlen;
import std.conv : to;
import std.string;
import bazinga.game;
import std.path;
import std.file;

string window_title;
string game_location;
Game game;


int main(string[] args)
{
    if (args.length > 1) {
        if (args[1] == "repl") {
            import bazinga.parser;
            while (true) {
                write(">>> ");
                auto test_string = readln();
                CommandParser parser = new CommandParser(test_string);
                writeln("Tokens:");
                foreach (token; parser.tokens) {
                    writeln(token);
                }
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

void run_game() {
    validateRaylibBinding();
    SetConfigFlags(ConfigFlags.FLAG_VSYNC_HINT | ConfigFlags.FLAG_WINDOW_RESIZABLE);
    InitWindow(1280, 720, "Bazinga");
    
    SetWindowTitle(toStringz(game.title));

    SetTargetFPS(60);

    while (!WindowShouldClose())
    {
        BeginDrawing();
        ClearBackground(Colors.BLACK);
        DrawText("Game", 10, 10, 20, Colors.WHITE);
        DrawText("Bazinga - v0.0.1", 10, 100, 20, Colors.WHITE);
        EndDrawing();
    }
    CloseWindow();
}

void no_game() {
    validateRaylibBinding();
    
    SetConfigFlags(ConfigFlags.FLAG_VSYNC_HINT | ConfigFlags.FLAG_WINDOW_RESIZABLE);
    InitWindow(1280, 720, "Bazinga - No Game :/");

    SetTargetFPS(60);
    while (!WindowShouldClose())
    {
        BeginDrawing();
        ClearBackground(Colors.BLACK);
        DrawText("No game :(", 10, 10, 20, Colors.WHITE);
        DrawText("You may need to spesifiy the project folder: 'bazinga ./my_game'", 10, 38, 20, Colors.WHITE);
        DrawText("Bazinga - v0.0.1", 10, 100, 20, Colors.WHITE);
        EndDrawing();
    }
    CloseWindow();
}