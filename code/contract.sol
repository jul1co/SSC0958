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
        Restauration[] restaurations;
    }

    struct Restaurer {
        string name;
        address payable account;
    }

    Art[] public arts;
    Restaurer[] public restaurers;

    function mintArt(string memory _name, string memory _description, uint256 _price, uint256 _date) public {
        Art memory newArt = Art({
            name: _name,
            description: _description,
            price: _price,
            owner: payable(msg.sender),
            isSold: false,
            date: _date,
            restaurations: new Restauration[](0)
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

    function startRestauration(uint256 _artId, uint256 _restaurerId, string memory _description, uint256 _date) public {
        Art storage _art = arts[_artId];
        Restaurer memory _restaurer = restaurers[_restaurerId];

        require(msg.sender == _art.owner, "Only the owner can start the restauration.");

        _art.restaurations.push(Restauration(_description, _restaurer.account, false, _date));
    }

    function completeRestauration(uint256 _artId, uint256 _restaurationId) public {
        Art storage _art = arts[_artId];
        Restauration storage _restauration = _art.restaurations[_restaurationId];

        require(msg.sender == _restauration.restaurer, "Only the assigned restaurer can complete the restauration.");

        _restauration.isCompleted = true;
    }

    function getRestaurationHistory(uint256 _artId) public view returns (Restauration[] memory) {
        return arts[_artId].restaurations;
    }
}