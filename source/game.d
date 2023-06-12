module bazinga.game;


import std.stdio;
import toml;
import std.file : read;

struct Game {
    // Metadata
    string title;
    string author;
    string description;
    string game_version;
    string game_location;

    // Game state

}

Game load_game(string directory) {
    TOMLDocument game_toml;
    game_toml = parseTOML(cast(string)read(directory ~ "/metadata.toml"));
    Game game;
    game.title = cast(string)game_toml["metadata"]["title"].str();
    game.author = cast(string)game_toml["metadata"]["author"].str();
    game.description = cast(string)game_toml["metadata"]["description"].str();
    game.game_version = cast(string)game_toml["metadata"]["version"].str();

    return game;
}

