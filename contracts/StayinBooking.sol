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

    
modifier onlyHotelOwner() {
    require(
        msg.sender == hotelOwner,
        "Only hotel owner can perform this action"
    );
    _;
}


    constructor() {
        hotelOwner = msg.sender;
    }
    
function registerRoom(
    uint256 roomId,
    string calldata roomName,
    uint256 pricePerNight
) external onlyHotelOwner {

    require(roomId > 0, "Invalid room ID");

    require(
        rooms[roomId].roomId == 0,
        "Room already exists"
    );

    require(
        bytes(roomName).length > 0,
        "Room name required"
    );

    require(
        pricePerNight > 0,
        "Invalid room price"
    );

    rooms[roomId] = Room({
        roomId: roomId,
        roomName: roomName,
        pricePerNight: pricePerNight,
        isActive: true
    });

    emit RoomRegistered(roomId, roomName);
}

function checkAvailability(
    uint256 roomId,
    uint256 checkIn,
    uint256 checkOut
) public view returns (bool) {
    require(rooms[roomId].roomId != 0, "Room does not exist");
    require(rooms[roomId].isActive, "Room is not active");
    require(checkIn > block.timestamp, "Check-in must be in the future");
    require(checkOut > checkIn, "Invalid booking dates");

    uint256[] storage existingBookings = roomBookings[roomId];

    for (uint256 i = 0; i < existingBookings.length; i++) {
        Booking storage existingBooking = bookings[existingBookings[i]];

        if (existingBooking.status == BookingStatus.Confirmed) {
            bool overlaps =
                checkIn < existingBooking.checkOut &&
                checkOut > existingBooking.checkIn;

            if (overlaps) {
                return false;
            }
        }
    }

    return true;
}

function bookRoom(
    uint256 roomId,
    uint256 checkIn,
    uint256 checkOut
) external returns (uint256) {

    require(
        checkAvailability(roomId, checkIn, checkOut),
        "Room is not available"
    );

    uint256 bookingId = nextBookingId;

    bookings[bookingId] = Booking({
        bookingId: bookingId,
        roomId: roomId,
        guest: msg.sender,
        checkIn: checkIn,
        checkOut: checkOut,
        status: BookingStatus.Confirmed
    });

    roomBookings[roomId].push(bookingId);

    nextBookingId++;

    emit BookingCreated(
        bookingId,
        roomId,
        msg.sender,
        checkIn,
        checkOut
    );

    return bookingId;
}

function cancelBooking(uint256 bookingId) external {

    require(
        bookings[bookingId].bookingId != 0,
        "Booking does not exist"
    );

    Booking storage booking = bookings[bookingId];

    require(
        msg.sender == booking.guest || msg.sender == hotelOwner,
        "Not authorised to cancel this booking"
    );

    require(
        booking.status == BookingStatus.Confirmed,
        "Booking already cancelled"
    );

    booking.status = BookingStatus.Cancelled;

    emit BookingCancelled(bookingId, msg.sender);
}
function getBooking(uint256 bookingId)
    external
    view
    returns (
        uint256,
        uint256,
        address,
        uint256,
        uint256,
        BookingStatus
    )
{
    require(
        bookings[bookingId].bookingId != 0,
        "Booking does not exist"
    );

    Booking storage booking = bookings[bookingId];

    return (
        booking.bookingId,
        booking.roomId,
        booking.guest,
        booking.checkIn,
        booking.checkOut,
        booking.status
    );
}
function getRoom(uint256 roomId)
    external
    view
    returns (
        uint256,
        string memory,
        uint256,
        bool
    )
{
    require(
        rooms[roomId].roomId != 0,
        "Room does not exist"
    );

    Room storage room = rooms[roomId];

    return (
        room.roomId,
        room.roomName,
        room.pricePerNight,
        room.isActive
    );
}

}




