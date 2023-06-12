import raylib;
import std.stdio;

string game_location;

int main(string[] args)
{
    if (args[1] == "repl") {
        import bazinga.parser;
        CommandParser parser = new CommandParser(`emir "Hello"\n` );
        while (true) {
            auto test_string = readln();
            auto tokens = parser.getTokens(test_string);
            foreach (token; tokens) {
                writeln(token);
            }
        }
        
    }

    if (args.length < 2) {
        writeln("No game found.");
        no_game();
        return 0;
    } else {
        game_location = args[1];
        writeln("Game location: ", game_location);
    }

    return 0;
}

void run_game() {
    validateRaylibBinding();

    SetConfigFlags(ConfigFlags.FLAG_VSYNC_HINT | ConfigFlags.FLAG_WINDOW_RESIZABLE);
    InitWindow(1280, 720, "Bazinga - Game");

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