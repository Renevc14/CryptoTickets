// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./MyNFT.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract EventTicket is Ownable, ReentrancyGuard {
    MyNFT public nftContract;

    struct Event {
        string name;
        string date;
        string location;
        uint256 ticketPrice;
        uint256 totalTickets;
        uint256 ticketsSold;
        bool isActive;
        bool isCancelled;
    }

    mapping(uint256 => Event) public events;
    mapping(uint256 => address) public eventTickets;
    mapping(uint256 => bool) public ticketScanned;

    uint256 public nextEventId;

    constructor(address _nftContract) Ownable(msg.sender) {
        nftContract = MyNFT(_nftContract);
    }

    function createEvent(string memory _name, string memory _date, string memory _location, uint256 _ticketPrice, uint256 _totalTickets) public onlyOwner {
        require(_totalTickets > 0, "Total tickets must be greater than 0");

        Event memory newEvent = Event({
            name: _name,
            date: _date,
            location: _location,
            ticketPrice: _ticketPrice,
            totalTickets: _totalTickets,
            ticketsSold: 0,
            isActive: true,
            isCancelled: false
        });

        events[nextEventId] = newEvent;
        nextEventId++;
    }

    function cancelEvent(uint256 _eventId) public onlyOwner {
        Event storage _event = events[_eventId];
        require(_event.isActive, "Event is not active");
        require(!_event.isCancelled, "Event is already cancelled");

        _event.isActive = false;
        _event.isCancelled = true;
    }

    function buyTicket(uint256 _eventId) public payable nonReentrant {
        Event storage _event = events[_eventId];
        require(_event.isActive, "Event is not active");
        require(!_event.isCancelled, "Event is cancelled");
        require(msg.value == _event.ticketPrice, "Incorrect ticket price");
        require(_event.ticketsSold < _event.totalTickets, "No tickets available");

        uint256 ticketId = _event.ticketsSold + 1;
        nftContract.mintNFT(msg.sender);
        eventTickets[ticketId] = msg.sender;
        _event.ticketsSold++;
    }

    function scanTicket(uint256 _eventId, uint256 _ticketId) public onlyOwner {
        require(eventTickets[_ticketId] != address(0), "Ticket does not exist");
        require(!ticketScanned[_ticketId], "Ticket already scanned");

        ticketScanned[_ticketId] = true;

        nftContract.burn(_ticketId);
    }

    function getEvent(uint256 _eventId) public view returns (Event memory) {
        return events[_eventId];
    }

    function getTicketOwner(uint256 _ticketId) public view returns (address) {
        return eventTickets[_ticketId];
    }

    function isTicketScanned(uint256 _ticketId) public view returns (bool) {
        return ticketScanned[_ticketId];
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner()).transfer(balance);
    }
}
