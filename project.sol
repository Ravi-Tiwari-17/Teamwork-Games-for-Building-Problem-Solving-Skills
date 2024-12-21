// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TeamworkGames {
    struct Game {
        uint id;
        string name;
        string description;
        uint maxPlayers;
        address creator;
        bool isActive;
    }

    struct Player {
        address playerAddress;
        bool hasJoined;
    }

    mapping(uint => Game) public games;
    mapping(uint => Player[]) public gamePlayers;
    uint public gameCount;

    event GameCreated(uint gameId, string name, uint maxPlayers);
    event PlayerJoined(uint gameId, address player);
    event GameStatusChanged(uint gameId, bool isActive);

    modifier onlyCreator(uint _gameId) {
        require(games[_gameId].creator == msg.sender, "Not the creator");
        _;
    }

    function createGame(string memory _name, string memory _description, uint _maxPlayers) public {
        require(_maxPlayers > 1, "Minimum 2 players required");
        gameCount++;
        games[gameCount] = Game(gameCount, _name, _description, _maxPlayers, msg.sender, true);
        emit GameCreated(gameCount, _name, _maxPlayers);
    }

    function joinGame(uint _gameId) public {
        require(_gameId > 0 && _gameId <= gameCount, "Invalid game ID");
        require(games[_gameId].isActive, "Game is not active");
        require(gamePlayers[_gameId].length < games[_gameId].maxPlayers, "Game is full");

        for (uint i = 0; i < gamePlayers[_gameId].length; i++) {
            require(gamePlayers[_gameId][i].playerAddress != msg.sender, "Already joined");
        }

        gamePlayers[_gameId].push(Player(msg.sender, true));
        emit PlayerJoined(_gameId, msg.sender);
    }

    function toggleGameStatus(uint _gameId) public onlyCreator(_gameId) {
        games[_gameId].isActive = !games[_gameId].isActive;
        emit GameStatusChanged(_gameId, games[_gameId].isActive);
    }

    function getPlayers(uint _gameId) public view returns (address[] memory) {
        require(_gameId > 0 && _gameId <= gameCount, "Invalid game ID");
        uint playerCount = gamePlayers[_gameId].length;
        address[] memory players = new address[](playerCount);
        for (uint i = 0; i < playerCount; i++) {
            players[i] = gamePlayers[_gameId][i].playerAddress;
        }
        return players;
    }
}
