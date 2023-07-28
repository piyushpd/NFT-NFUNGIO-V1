// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Enum {
    // Enum representing shipping status
    enum Status {
        Pending,
        Shipped,
        Accepted,
        Rejected,
        Canceled
    }

    // Default value is the first element listed in
    // definition of the type, in this case "Pending"
    Status public status;
    string p;
    // Returns uint
    // Pending  - 0
    // Shipped  - 1
    // Accepted - 2
    // Rejected - 3
    // Canceled - 4
    //function get() public returns (string memory) {
    function get() public returns (string memory) {   
        if (status== Status.Pending) {
            p= "PENDING";
        }

         if (status== Status.Shipped) {
            p= "Shipped";
        }

         if (status== Status.Accepted) {
            p= "Accepted";
        }

         if (status== Status.Rejected) {
            p= "Rejected";
        }

         if (status== Status.Canceled) {
            p= "Canceled";
        }

    return p;
      
    }

    // Update status by passing uint into input
    function set(Status _status) public {
        status = _status;
    }

    // You can update to a specific enum like this
    function cancel() public {
        status = Status.Canceled;
    }

    // delete resets the enum to its first value, 0
    function reset() public {
        delete status;
    }
}
