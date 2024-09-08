// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;
import "./Ordering.sol";
import "./Registration.sol";

contract Complaint{

    Ordering order = Ordering(0x358AA13c52544ECCEF6B0ADD0f801012ADAD5eE3);
    Registration register = Registration(0xd9145CCE52D386f254917e481eB44e9943F39138);

    uint [] public id;  
    mapping (uint => bytes32) complaintDetails;
    mapping (uint => uint) public confirmationTime;
    mapping (uint => address) public complainant;
    mapping (uint => address) public receiver;
    mapping (uint => bytes32) complaintResponse;
    mapping (uint => uint) public responseTime;
    mapping (uint => bool) public complaintConfirmation;
    mapping (uint => bool) public responseUsefulness;

    event NewComplaint(uint offerid, bytes32 complaintDetails);
    event NewConfirmedComplaint(address supplier, uint offerid, bytes32 complaintDetails);
    event ComplaintWasAnswered(uint offerid, bytes32 complaintResponse);

    modifier OnlyAdmin() {
        require (register.isAdmin(msg.sender), "Only admin");
        _;
    }   

    function SubmitComplaint (uint _offerid, bytes32 _complaintDetails) public{
        require(order.buyer(_offerid) == msg.sender 
        && order.shipmentAccepted(_offerid) == true);
        complainant[_offerid] = msg.sender;
        complaintDetails[_offerid] = _complaintDetails;
        receiver[_offerid] = order.supplier(_offerid);
        emit NewComplaint(_offerid, complaintDetails[_offerid]);
    }

    function ConfirmComplaint(uint _offerid, bool _confirmation) public OnlyAdmin{
        complaintConfirmation[_offerid] = _confirmation;
        if (complaintConfirmation[_offerid] == true){
            id.push(_offerid);
            confirmationTime[_offerid] = block.timestamp;
            emit NewConfirmedComplaint(complainant[_offerid], 
            _offerid, complaintDetails[_offerid]);
        }
    }

    function AnswerComplaint(uint _offerid, bytes32 _complaintResponse) public{
        require(receiver[_offerid] == msg.sender);
        if (complaintConfirmation[_offerid] == true){
            complaintResponse[_offerid] = _complaintResponse;
            responseTime[_offerid] = block.timestamp;
            emit ComplaintWasAnswered(_offerid, _complaintResponse);
        }        
    }

    function AssessResponse(uint _offerid, bool _assessment) public{
        require(complainant[_offerid] == msg.sender);
        responseUsefulness[_offerid] = _assessment;
    }

    function getLength() external view returns(uint){
        return id.length;
    }
}
