// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ArtMarketplace {
    struct Restauration {
        string description;
        address payable restaurer;
        bool isCompleted;
        uint256 date;
    }

    struct Art {
        string name;
        string description;
        uint256 price;
        address payable owner;
        bool isSold;
        uint256 date;
    }

    struct Restaurer {
        string name;
        address payable account;
    }

    Art[] public arts;
    Restaurer[] public restaurers;

    function addRestaurer(string memory _name) public {
        Restaurer memory newRestaurer = Restaurer({
            name: _name,
            account: payable(msg.sender)
        });
        restaurers.push(newRestaurer);
    }

    function addArt(string memory _name, string memory _description, uint256 _price, uint256 _date) public {
        Art memory newArt = Art({
            name: _name,
            description: _description,
            price: _price,
            owner: payable(msg.sender),
            isSold: false,
            date: _date
        });
        arts.push(newArt);
    }
    
    function buyArt(uint256 _artId) public payable {
        Art storage _art = arts[_artId];

        require(msg.value >= _art.price, "Not enough Ether provided.");
        require(!_art.isSold, "Art piece already sold.");

        _art.owner.transfer(msg.value);
        _art.owner = payable(msg.sender);
        _art.isSold = true;
    }

    function sellArt(uint256 _artId, uint256 _price) public {
        Art storage _art = arts[_artId];

        require(msg.sender == _art.owner, "Only the owner can sell the art.");

        _art.price = _price;
        _art.isSold = false;
    }

    function getAvailableArts() public view returns (uint[] memory) {
        uint[] memory availableArts = new uint[](arts.length);

        uint counter = 0;
        for (uint i = 0; i < arts.length; i++) {
            if (!arts[i].isSold) {
                availableArts[counter] = i;
                counter++;
            }
        }

        // Create a new array with the correct length
        uint[] memory result = new uint[](counter);
        for (uint i = 0; i < counter; i++) {
            result[i] = availableArts[i];
        }

        return result;
    }

    mapping(uint => Restauration[]) public restaurations;

    function addRestauration(uint _artId, uint256 _restaurerId, string memory _description) public {
        Art storage _art = arts[_artId];
        Restaurer memory _restaurer = restaurers[_restaurerId];

        require(msg.sender == _art.owner, "Only the owner can add a restauration."); 

        Restauration memory newRestauration = Restauration({
            description: _description,
            restaurer: _restaurer.account,
            isCompleted: false,
            date: block.timestamp
        });
        restaurations[_artId].push(newRestauration);
    }


    function completeRestauration(uint256 _artId, uint256 _restaurerId, uint256 _restaurationId) public {
        Restaurer memory _restaurer = restaurers[_restaurerId];

        require(msg.sender == _restaurer.account, "Only the assigned restaurer can complete the restauration.");

        Restauration storage _restauration = restaurations[_artId][_restaurationId];
        _restauration.isCompleted = true;
    }

    function getRestaurationHistory(uint256 _artId) public view returns (Restauration[] memory) {
        return restaurations[_artId];
    }
}