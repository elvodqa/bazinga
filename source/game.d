module bazinga.game;


import bazinga.parser;
import std.stdio;
import toml;
import std.file : read;

struct Script {
    int value;
    string location;
    Command[] commands;
}

enum VariableType {
    Number,
    String,
    Bool,
}

struct Variable {
    string name;
    VariableType type;
    union {
        int number;
        string str;
        bool boolean;
    }
}

struct Game {
    string title;
    string author;
    string description;
    string game_version;
    string game_location;

    Script[] scripts;
    Variable[] variables;
    int current_command;
    int current_script;
}

Game load_game(string directory) {
    TOMLDocument game_toml;
    game_toml = parseTOML(cast(string)read(directory ~ "/game.toml"));
    Game game;
    game.title = cast(string)game_toml["metadata"]["title"].str();
    game.author = cast(string)game_toml["metadata"]["author"].str();
    game.description = cast(string)game_toml["metadata"]["description"].str();
    game.game_version = cast(string)game_toml["metadata"]["version"].str();

    // Print game info
    writeln("Title: ", game.title);
    writeln("Author: ", game.author);
    writeln("Description: ", game.description);
    writeln("Version: ", game.game_version);

    return game;
}

