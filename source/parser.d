module bazinga.parser;
import std.ascii;

class Command {
}

class TalkCommand : Command {
    string text;
    string speaker;
    override
    string toString() {
        return "TalkCommand(" ~ this.text ~ ", " ~ this.speaker ~ ")";
    }
}

class MoveCommand : Command {
    string target;
    string destination;
    override
    string toString() {
        return "MoveCommand(" ~ this.target ~ ", " ~ this.destination ~ ")";
    }
}

class SetActorSpriteCommand : Command {
    string actor;
    string sprite;
    override
    string toString() {
        return "SetActorSpriteCommand(" ~ this.actor ~ ", " ~ this.sprite ~ ")";
    }
}

class AddActorCommand : Command {
    string actor;
    string sprite;
    override
    string toString() {
        return "AddActorCommand(" ~ this.actor ~ ", " ~ this.sprite ~ ")";
    }
}

class RemoveActorCommand : Command {
    string actor;
    override
    string toString() {
        return "RemoveActorCommand(" ~ this.actor ~ ")";
    }
}

class SetSceneCommand : Command {
    string scene;
    override
    string toString() {
        return "SetSceneCommand(" ~ this.scene ~ ")";
    }
}

class SetWindowTitle : Command {
    string title;
    override
    string toString() {
        return "SetWindowTitle(" ~ this.title ~ ")";
    }
}

enum TokenType {
    StringLiteral,
    NumberLiteral,
    Identifier,
    WhiteSpace,
    NewLine,
    Tab,
    Variable,
    Equal,
    Assign,
}

string[] command_types = [
    "talk",
    "move",
    "set_actor_sprite",
    "add_actor",
    "remove_actor",
    "set_scene",
    "set_window_title",
];

struct Token {
    string value;
    TokenType type;
    int line;
    int column;
}


class CommandParser {
    Command[] commands;
    Token[] tokens;
    string source;
    int line;
    int column;

    this(string source) {
        this.source = source;
        this.line = 1;
        this.column = 1;
        this.tokens = this.getTokens(source);
        this.commands = this.ParseCommands();
    }

    Command[] ParseCommands() {
        Command[] commands_list;
        import std.algorithm: canFind;
        import std.array: split;
        import std.string: strip;
        Token[][] lines = this.tokens.split!(a => a.type == TokenType.NewLine);
        foreach (Token[] line; lines) {
            if (line.length == 0) {
                continue;
            }
            if (line[0].type == TokenType.Identifier) {
                string command = line[0].value;
                if (command_types.canFind(command)) {
                    if (command == "talk") {
                        import std.stdio;
                        TalkCommand talk_command = new TalkCommand();
                        talk_command.speaker = line[1].value;
                        talk_command.text = line[2].value;
                        writeln(talk_command.toString());
                        commands_list ~= talk_command;
                    } else if (command == "move") {
                        MoveCommand move_command = new MoveCommand();
                        move_command.target = line[1].value;
                        move_command.destination = line[2].value;
                        commands_list ~= move_command;
                    } else if (command == "set_actor_sprite") {
                        SetActorSpriteCommand set_actor_sprite_command = new SetActorSpriteCommand();
                        set_actor_sprite_command.actor = line[1].value;
                        set_actor_sprite_command.sprite = line[2].value;
                        commands_list ~= set_actor_sprite_command;
                    } else if (command == "add_actor") {
                        AddActorCommand add_actor_command = new AddActorCommand();
                        add_actor_command.actor = line[1].value;
                        add_actor_command.sprite = line[2].value;
                        commands_list ~= add_actor_command;
                    } else if (command == "remove_actor") {
                        RemoveActorCommand remove_actor_command = new RemoveActorCommand();
                        remove_actor_command.actor = line[1].value;
                        commands_list ~= remove_actor_command;
                    } else if (command == "set_scene") {
                        SetSceneCommand set_scene_command = new SetSceneCommand();
                        set_scene_command.scene = line[1].value;
                        commands_list ~= set_scene_command;
                    } else if (command == "set_window_title") {
                        SetWindowTitle set_window_title_command = new SetWindowTitle();
                        set_window_title_command.title = line[1].value;
                        commands_list ~= set_window_title_command;
                    }
                }
                else {
                    // Order: 'Indetifier StringLiteral' is talk command
                    if (line.length == 2 && line[1].type == TokenType.StringLiteral) {
                        TalkCommand talk_command = new TalkCommand();
                        talk_command.speaker = line[0].value;
                        talk_command.text = line[1].value;
                        commands_list ~= talk_command;
                    } else {
                        throw new Exception("Unknown command: " ~ command);
                    }

                    throw new Exception("Unknown command: " ~ command);
                }
            }
        }

        

        return commands;
    }

    




    Token[] getTokens(string source) {
        Token[] tokens_list;
        int index = 0;

        while (index < source.length) {
            char c = source[index];
            if (c == ' ') {
                index++;
                continue;
            }

            if (c == '"') {
                tokens_list ~= this.getStringLiteral(source, index);
            } else if (c == '\t') {
                tokens_list ~= this.getWhiteSpace(source, index);
            } else if (c == '\n') {
                tokens_list ~= this.getNewLine(source, index);
            } else if (c == '$') {
                tokens_list ~= this.getVariable(source, index);
            } else if (isDigit(c)) {
                tokens_list ~= this.getNumberLiteral(source, index);
            } else if (isAlpha(c)) {
                tokens_list ~= this.getIdentifier(source, index);
            } else if (c == '=') { // = is assign, == is assign
                if (index + 1 < source.length && source[index + 1] == '=') {
                    tokens_list ~= Token("==", TokenType.Assign, this.line, this.column);
                    // index++;
                } else {
                    tokens_list ~= Token("=", TokenType.Equal, this.line, this.column);
                }
                // index++;
            }
            else {
                throw new Exception("Unexpected character: " ~ c);
            }
            index += tokens_list[tokens_list.length - 1].value.length;

            if (index >= source.length) {
                break;
            }
        }

        return tokens_list;
    }

    Token getStringLiteral(string source, int index) {
        int start = index;
        index++;
        while (index < source.length && source[index] != '"') {
            index++;
        }
        if (index >= source.length) {
            throw new Exception("Unterminated string literal");
        }
        index++;
        return Token(source[start..index], TokenType.StringLiteral, this.line, this.column);
    }

    Token getWhiteSpace(string source, int index) {
        int start = index;
        index++;
        while (index < source.length && source[index] == '\t') {
            index++;
        }
        return Token(source[start..index], TokenType.WhiteSpace, this.line, this.column);
    }

    Token getNewLine(string source, int index) {
        int start = index;
        index++;
        while (index < source.length && source[index] == '\n') {
            index++;
        }
        return Token(source[start..index], TokenType.NewLine, this.line, this.column);
    }

    Token getVariable(string source, int index) {
        int start = index;
        index++;
        while (index < source.length && source[index].isAlpha) {
            index++;
        }
        return Token(source[start..index], TokenType.Variable, this.line, this.column);
    }

    Token getNumberLiteral(string source, int index) {
        int start = index;
        index++;
        while (index < source.length && source[index].isDigit) {
            index++;
        }
        return Token(source[start..index], TokenType.NumberLiteral, this.line, this.column);
    }

    Token getIdentifier(string source, int index) {
        int start = index;
        index++;
        while (index < source.length && isAlpha(source[index]) || isDigit(source[index]) || source[index] == '_') {
            index++;
        }
        return Token(source[start..index], TokenType.Identifier, this.line, this.column);
    }

    void advance() {
        this.column++;
    }

    void advance(int n) {
        this.column += n;
    }

    void newLine() {
        this.line++;
        this.column = 1;
    }

    void newLine(int n) {
        this.line += n;
        this.column = 1;
    }

    void skipWhiteSpace(string source, int index) {
        while (index < source.length && (source[index] == ' ' || source[index] == '\t')) {
            index++;
        }
    }
}

