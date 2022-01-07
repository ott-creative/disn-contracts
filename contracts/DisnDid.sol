// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract DisnDid {
    // owner of identity map
    mapping(address => address) public owners;
    // update record (block number)
    mapping(address => uint256) public changed;

    modifier onlyOwner(address identity, address actor) {
        require(actor == identityOwner(identity));
        _;
    }

    event DIDOwnerChanged(
        address indexed identity,
        address owner,
        uint256 previousChange
    );

    event DIDAttributeChanged(
        address indexed identity,
        bytes32 name,
        bytes value,
        uint256 validTo,
        uint256 previousChange
    );

    function identityOwner(address identity) public view returns (address) {
        address owner = owners[identity];
        if (owner != 0x0000000000000000000000000000000000000000) {
            return owner;
        }
        return identity;
    }

    function changeOwner(
        address identity,
        address actor,
        address newOwner
    ) internal onlyOwner(identity, actor) {
        owners[identity] = newOwner;
        emit DIDOwnerChanged(identity, newOwner, changed[identity]);
        changed[identity] = block.number;
    }

    function changeOwner(address identity, address newOwner) public {
        changeOwner(identity, msg.sender, newOwner);
    }

    function setAttribute(
        address identity,
        address actor,
        bytes32 name,
        bytes memory value,
        uint256 validity
    ) internal onlyOwner(identity, actor) {
        emit DIDAttributeChanged(
            identity,
            name,
            value,
            block.timestamp + validity,
            changed[identity]
        );
        changed[identity] = block.number;
    }

    function setAttribute(
        address identity,
        bytes32 name,
        bytes memory value,
        uint256 validity
    ) public {
        setAttribute(identity, msg.sender, name, value, validity);
    }
}
