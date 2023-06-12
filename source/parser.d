module bazinga.parser;

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

enum TokenType {
    StringLiteral,
    NumberLiteral,
    Identifier,
    WhiteSpace,
    NewLine,
    Tab,
}

struct Token {
    string value;
    TokenType type;
    int line;
    int column;
}

class CommandParser {
    Command[] commands;
    string source;
    int line;
    int column;

    this(string source) {
        this.source = source;
        this.line = 1;
        this.column = 1;
    }

    void ParseNextCommand() {
        
    }

    Token[] getTokens(string source) {
        Token[] tokens;
        int index = 0;

        while (index < source.length) {
            char c = source[index];
            if (c == '"') {
                Token token;
                token.type = TokenType.StringLiteral;
                token.value = getStringLiteral(source, index);
                tokens ~= token;
            } else if (c == ' ' || c == '\t') {
                Token token;
                token.type = TokenType.WhiteSpace;
                token.value = getWhiteSpace(source, index);
                tokens ~= token;
            } else if (c == '\n') {
                Token token;
                token.type = TokenType.NewLine;
                token.value = getNewLine(source, index);
                tokens ~= token;
            } else if (c == '\t') {
                Token token;
                token.type = TokenType.Tab;
                token.value = getTab(source, index);
                tokens ~= token;
            } else if (isDigit(c) || c == '-') {
                Token token;
                token.type = TokenType.NumberLiteral;
                token.value = getNumberLiteral(source, index);
                tokens ~= token;
            } else if (isLetter(c)) {
                Token token;
                token.type = TokenType.Identifier;
                token.value = getIdentifier(source, index);
                tokens ~= token;
            } else {
                throw new Exception("Unexpected character: " ~ c);
            }
            index += tokens[tokens.length - 1].value.length;

            if (index < source.length) {
                char next = source[index];
                if (next == '\n') {
                    line++;
                    column = 1;
                } else {
                    column++;
                }
            }

            index++;
        }

        return tokens;
    }

    string getStringLiteral(string source, int index) {
        int start = index;
        index++;
        while (index < source.length) {
            char c = source[index];
            if (c == '"') {
                return source[start..index+1];
            }
            index++;
        }
        throw new Exception("Unterminated string literal");
    }

    string getWhiteSpace(string source, int index) {
        int start = index;
        index++;
        while (index < source.length) {
            char c = source[index];
            if (c != ' ' && c != '\t') {
                return source[start..index];
            }
            index++;
        }
        throw new Exception("Unterminated whitespace");
    }

    string getNewLine(string source, int index) {
        int start = index;
        index++;
        while (index < source.length) {
            char c = source[index];
            if (c != '\n') {
                return source[start..index];
            }
            index++;
        }
        throw new Exception("Unterminated newline");
    }

    string getTab(string source, int index) {
        int start = index;
        index++;
        while (index < source.length) {
            char c = source[index];
            if (c != '\t') {
                return source[start..index];
            }
            index++;
        }
        throw new Exception("Unterminated tab");
    }

    string getNumberLiteral(string source, int index) {
        int start = index;
        index++;
        bool hasDecimal = false;
        while (index < source.length) {
            char c = source[index];
            if (!isDigit(c)) {
                if (c == '.' && !hasDecimal) {
                    hasDecimal = true;
                } else {
                    return source[start..index];
                }
            }
            index++;
        }
        throw new Exception("Unterminated number literal");
    }

    string getIdentifier(string source, int index) {
        int start = index;
        index++;
        while (index < source.length) {
            char c = source[index];
            if (!isLetter(c)) {
                return source[start..index];
            }
            index++;
        }
        throw new Exception("Unterminated identifier");
    }

    bool isDigit(char c) {
        return c >= '0' && c <= '9';
    }

    bool isLetter(char c) {
        return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
    }

    bool isWhiteSpace(char c) {
        return c == ' ' || c == '\t';
    }
}

