module bazinga.parser;
import std.ascii;

class Command {}

class TalkCommand : Command {
    string text;
    string speaker;
}

class MoveCommand : Command {
    string target;
    string destination;
}

class SetActorSpriteCommand : Command {
    string actor;
    string sprite;
}

class AddActorCommand : Command {
    string actor;
    string sprite;
    string location;
}

class RemoveActorCommand : Command {
    string actor;
}

class SetSceneCommand : Command {
    string scene;
}

class SetWindowTitle : Command {
    string title;
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
    }

    void ParseNextCommand() {
        
    }

    Token[] getTokens(string source) {
        Token[] tokens_list;
        int index = 0;

        while (index < source.length) {
            char c = source[index];
            if (c == '"') {
                tokens_list ~= this.getStringLiteral(source, index);
            } else if (c == ' ' || c == '\t') {
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
        while (index < source.length && (source[index] == ' ' || source[index] == '\t')) {
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
        while (index < source.length && isAlpha(source[index])) {
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

