// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract ArtMarketplace {
    struct Art {
        string name;
        string description;
        uint256 price;
        address payable owner;
        bool isSold;
        uint restaurationId;
    }

    struct Restauration {
        string description;
        address payable restaurer;
        bool isCompleted;
    }

    struct Restaurer {
        string name;
        address payable account;
    }

    Art[] public arts;
    Restauration[] public restaurations;
    Restaurer[] public restaurers;

    function mintArt(string memory _name, string memory _description, uint256 _price) public {
        arts.push(Art(_name, _description, _price, payable(msg.sender), false, 0));
    }

    function buyArt(uint256 _artId) public payable {
        Art memory _art = arts[_artId];

        require(msg.value >= _art.price, "Not enough Ether provided.");
        require(!_art.isSold, "Art piece already sold.");

        _art.owner.transfer(msg.value);
        _art.owner = payable(msg.sender);
        _art.isSold = true;

        arts[_artId] = _art;
    }

    function startRestauration(uint256 _artId, uint256 _restaurerId, string memory _description) public {
        Art memory _art = arts[_artId];
        Restaurer memory _restaurer = restaurers[_restaurerId];

        require(msg.sender == _art.owner, "Only the owner can start the restauration.");
        require(_art.restaurationId == 0, "Art is already under restauration.");

        _art.restaurationId = restaurations.length;
        restaurations.push(Restauration(_description, _restaurer.account, false));

        arts[_artId] = _art;
    }

    function completeRestauration(uint256 _artId) public {
        Art memory _art = arts[_artId];
        Restauration memory _restauration = restaurations[_art.restaurationId];

        require(msg.sender == _restauration.restaurer, "Only the assigned restaurer can complete the restauration.");

        _restauration.isCompleted = true;

        restaurations[_art.restaurationId] = _restauration;
    }
}