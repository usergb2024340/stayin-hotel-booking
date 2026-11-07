 // SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract StayinBooking {

    address public immutable hotelOwner;


    uint256 public nextBookingId = 1;

     enum BookingStatus {
        Confirmed,
        Cancelled
    }

    struct Room {
        uint256 roomId;
        string roomName;
        uint256 pricePerNight;
        bool isActive;
    }

    struct Booking {
        uint256 bookingId;
        uint256 roomId;
        address guest;
        uint256 checkIn;
        uint256 checkOut;
        BookingStatus status;
    }

    mapping(uint256 => Room) private rooms;
    mapping(uint256 => Booking) private bookings;

    mapping(uint256 => uint256[]) private roomBookings;

    event RoomRegistered(
        uint256 indexed roomId,
        string roomName
    );

    event BookingCreated(
        uint256 indexed bookingId,
        uint256 indexed roomId,
        address indexed guest,
        uint256 checkIn,
        uint256 checkOut
    );

    event BookingCancelled(
        uint256 indexed bookingId,
        address cancelledBy
    );

    constructor() {
        hotelOwner = msg.sender;
    }
    
}
