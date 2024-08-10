// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract EventTicket is ERC721, Ownable {
    uint256 public nextEventId;
    uint256 public nextTicketId;

    struct Event {
        string name;
        string date;
        string location;
        uint256 ticketPrice;
        uint256 totalTickets;
        uint256 ticketsSold;
        address creator;
    }

    mapping(uint256 => Event) public events;

    // Constructor with parameters for the name and symbol of the NFT
    constructor() ERC721("EventTicket", "ETK") Ownable(msg.sender) {}

    // Function to define the admin role
    modifier onlyAdmin() {
        require(msg.sender == owner(), "Only admin can execute this");
        _;
    }

    // Admin creates a new event
    function createEvent(
        string memory _name,
        string memory _date,
        string memory _location,
        uint256 _ticketPrice,
        uint256 _totalTickets
    ) public onlyAdmin {
        require(_totalTickets > 0, "Total tickets must be greater than zero");

        events[nextEventId] = Event({
            name: _name,
            date: _date,
            location: _location,
            ticketPrice: _ticketPrice,
            totalTickets: _totalTickets,
            ticketsSold: 0,
            creator: msg.sender
        });

        nextEventId++;
    }

    // Mint NFT tickets for a specific event
    function buyTicket(uint256 _eventId) public payable {
        Event storage _event = events[_eventId];

        require(_event.ticketsSold < _event.totalTickets, "Tickets sold out");
        require(msg.value >= _event.ticketPrice, "Insufficient payment");

        _event.ticketsSold++;
        _mint(msg.sender, nextTicketId);
        nextTicketId++;
    }
}
