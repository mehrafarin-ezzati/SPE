// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;
import "./Registration.sol";
contract Ordering{
    Registration register = Registration(0xd9145CCE52D386f254917e481eB44e9943F39138);
    address payable contractAddress;
    modifier OnlyAdmin() {
        require (register.isAdmin(msg.sender), "Only admin");
        _;
    }   
    modifier OnlySupplier{
      require(register.SupplierExistence((msg.sender)),
      "only registered suppliers."
      );
      _;
    }   

    modifier OnlyBuyer{
      require(register.BuyerExistence((msg.sender)),
      "only registered buyers."
      );
      _;
    }  

// Order Information
    mapping (uint => string) public product;
    mapping (uint => address) public requester;
    mapping (uint => uint) public quantity;
    mapping (uint => bool) public beingCustomized;
    mapping (uint => bytes32) info;
    mapping (uint => uint) public dueDate;
    mapping (uint => uint) public requestTime;
    mapping (uint => uint) public penaltyDate;
    mapping (uint => uint) public penaltyPercent;
    mapping (uint => uint) public expeditedDeliveryDate;
    mapping (uint => bool) public needFasterDelivery;
    uint[] public IDs;

// Offer Information
    mapping (uint => address) public supplier;
    mapping (uint => uint) public buyerIDs;
    mapping (uint => address) public buyer;
    mapping (uint => uint) public price;
    mapping (uint => uint) public tc; //Transportation Cost
    mapping (uint => uint) public offerTime;
    mapping (uint => bool) public offerChecked;
    mapping (uint => bool) public offerConfirmation;
    mapping (uint => uint) public offerConfirmationTime;
    uint[] public OfferIDs;

    mapping (uint => uint) public state;
    mapping (uint => address) public sender;
    mapping (uint => string) public shipmentName;
    mapping (uint => uint) public deliveryTime;
    mapping (uint => bool) public shipmentAccepted;
    mapping (uint => bool) public delayed;
    mapping (address => uint) public successfulShipments;
    mapping (uint => bool) public deliveryFlexibility;
    mapping (uint => string) location;

    event Demand(string productName, uint id);
    event AcceptedOffer(uint id, uint offerid);
    event AccelerationInDelivery(address buyer, uint id, uint newDeliveryDate);
    event ProcessingOrder(uint id , address buyer, string phase);
    event Dlivered(uint offerid, address buyer);
    event OrderVerified(address supplier, uint offerid, bool verified);

    function AddOrder(uint id, string memory _name, uint _quantity, bool _beingCustomized,
    bytes32 _info, uint _dueDate, uint _penaltyDate, uint _penaltyPercent, 
    string memory _location) public OnlyBuyer{
        for (uint i=0; i<IDs.length; i++){
            if(id == IDs[i]){
                revert("The id has been taken");
            }
        }
        IDs.push(id);
        product[id] = _name;
        requester[id] = msg.sender;
        quantity[id] = _quantity;
        beingCustomized[id] = _beingCustomized;
        info[id] = _info;
        dueDate[id] = _dueDate;
        requestTime[id] = block.timestamp;
        penaltyDate[id] = _penaltyDate;
        penaltyPercent[id] = _penaltyPercent;
        location[id] = _location;
        emit Demand(product[id], id);
    }

    function SearchOrder(uint id) public view returns(address _requester, 
    bool _beingCustomized, bytes32 _info, uint _quantity, uint _dueDate, 
    uint _requestTime, uint _penaltyDate){
        for(uint i=0; i < IDs.length; i++){
            if(IDs[i] == id){
                return(requester[IDs[i]], beingCustomized[IDs[i]],
        info[IDs[i]], quantity[IDs[i]], dueDate[IDs[i]],
        requestTime[IDs[i]], penaltyDate[IDs[i]]);
            }
        }      
    }
    function AddOffer(uint offerid, uint _id, uint _price, uint _transportationCost) 
    public payable OnlySupplier{
        require(register.info_completed(msg.sender) == true);
        for (uint i=0; i<OfferIDs.length; i++){
            if(offerid == OfferIDs[i]){
                revert("The id has been taken");
            }
        }
        buyerIDs[offerid] = _id;
        supplier[offerid] = msg.sender;
        buyer[offerid] = requester[_id];
        price[offerid] = _price;
        tc[offerid] = _transportationCost;
        offerTime[offerid] = block.timestamp;
        OfferIDs.push(offerid);
        Deposit(4430920 * 1 gwei);
    }

    function SearchOffers(uint _id) public view returns(uint [] memory){
        uint [] memory OfferID = new uint [] (OfferIDs.length);
        for (uint i=0; i<OfferIDs.length; i++){
            if (buyerIDs[OfferIDs[i]] == _id){
                OfferID [i] = OfferIDs[i];
            }
        }
        return OfferID;
    }

    function SearchOfferDetails(uint _offerid) public view returns(address _supplier,
    uint _price, uint _transportationCost, uint _offerTime){
        for(uint i=0; i < OfferIDs.length; i++){
            if(OfferIDs[i] == _offerid){
        return(supplier[OfferIDs[i]],
                price[OfferIDs[i]],
                tc[OfferIDs[i]],
                offerTime[OfferIDs[i]]
        );
            }
        }
    }

    function DeleteOrder(uint id) public payable{
        if (requester[id] == msg.sender){
            for(uint i=0; i<IDs.length; i++){
                if(IDs[i] == id){
                    IDs[i] = IDs[IDs.length-1];
                    IDs.pop();
                }
            }
        }
        for(uint i=0; i<OfferIDs.length; i++){
            if(buyerIDs[OfferIDs[i]] == id){
                offerConfirmation[OfferIDs[i]] = false;
                delete buyerIDs[OfferIDs[i]];
                OfferIDs[i] = OfferIDs[OfferIDs.length-1];
                payable(supplier[OfferIDs[i]]).transfer(4430920 gwei);
                OfferIDs.pop();
            }
        }
    }

    function ChooseOffer(uint _offerid) public payable{
        uint id = buyerIDs[_offerid];
        require(buyer[_offerid] == msg.sender 
        && block.timestamp - offerTime[_offerid] < 10 days);
        offerChecked[_offerid] = true;
        offerConfirmation[_offerid] = true;
        offerConfirmationTime[_offerid] = block.timestamp;
        Deposit(((price[_offerid])*(quantity[buyerIDs[_offerid]])
        + tc[_offerid]) * 1 gwei);
        for(uint i=0; i<OfferIDs.length; i++){
            if(OfferIDs[i] != _offerid && buyerIDs[OfferIDs[i]] == id){
                offerChecked[OfferIDs[i]] = true;
                offerConfirmation[OfferIDs[i]] = false;
                payable(msg.sender).transfer(4430920 gwei);
                delete buyerIDs[OfferIDs[i]];
                OfferIDs[i] = OfferIDs[OfferIDs.length-1];
                OfferIDs.pop();
            }
        }   
        emit AcceptedOffer(buyerIDs[_offerid], _offerid);
    }

    function GetTransactionFee(uint _offerid) public payable{
        require(offerConfirmation[_offerid] == false && supplier[_offerid] == msg.sender
        && offerChecked[_offerid] == false && block.timestamp > offerTime[_offerid] + 10  days);
        payable(msg.sender).transfer(4430920 gwei);
        offerChecked[_offerid] = true;
    }

    function DeliveryAcceleration(uint _offerid, uint newDueDate) public{
        require(buyer[_offerid] == msg.sender);  
            expeditedDeliveryDate[_offerid] = newDueDate;
            needFasterDelivery[_offerid] = true;
            emit AccelerationInDelivery(supplier[_offerid], _offerid, newDueDate);
    }

    function getLength() external view returns(uint){
        return OfferIDs.length;
    }

    function Deposit(uint m) public payable {
        require(msg.value == m);
    }

    function StartProcessing(uint _offerid) public payable{
        require(offerConfirmation[_offerid] == true && supplier[_offerid] == msg.sender);
        Deposit(((price[_offerid])*(quantity[buyerIDs[_offerid]])/4) * 1 gwei);
        state[_offerid] = 1;
        sender[_offerid] = msg.sender;
    }
    
    function PreparingOrder(uint _offerid, string memory _phase) public{
        require(state[_offerid] == 1 && supplier[_offerid] == msg.sender);
        emit ProcessingOrder(_offerid , buyer[_offerid] , _phase);
    }
    function NotStarted(uint _offerid) public payable{
        require(offerConfirmation[_offerid] == true && buyer[_offerid] == msg.sender
        && block.timestamp > offerConfirmationTime[_offerid] + 1  minutes 
        && state[_offerid] == 0);
        uint id = buyerIDs[_offerid];  
        offerConfirmation[_offerid] = false;
        payable(msg.sender).transfer(((price[_offerid])*(quantity[id])
            + tc[_offerid]) * 1 gwei + 4430920 gwei);
        
    }

    

    function DeliverShipment(uint _offerid) public{
        require(sender[_offerid] == msg.sender && state[_offerid] == 1 
        && block.timestamp < penaltyDate[buyerIDs[_offerid]]);
        state[_offerid] = 2;
        uint id = buyerIDs[_offerid];
        shipmentName[_offerid] = product[id];
        deliveryTime[_offerid] = block.timestamp;
        emit Dlivered(_offerid, buyer[_offerid]);

    }
    function VerifyReceive(uint _offerid, bool _verified) public{
        require(buyer[_offerid] == msg.sender && state[_offerid] == 2);
        bool verified = _verified;
        if (verified == true){
                state[_offerid] = 3;
            }
            else{
                state[_offerid] = 10;
                sender[_offerid] = address(0); /* The delivery was canceled and 
                the contract blocked the money and fine to prevent fraud
                We converted this address to address(0) so that 
                this order is not counted in the criteria measurement*/
            } 
        emit OrderVerified(supplier[_offerid], _offerid, verified);
    }
    function NotVerifing(uint _offerid) public payable{
        require(sender[_offerid] == msg.sender);
        uint id = buyerIDs[_offerid];
        if(block.timestamp >  deliveryTime[_offerid] + 1 minutes
        && state[_offerid] == 2){
            payable(msg.sender).transfer((((price[_offerid])
                *(quantity[id])/4)* 5 + tc[_offerid]) * 1 gwei + 4430920 gwei); 
            state[_offerid] = 5;
            sender[_offerid] = address(0);
                    
        }
    }
    function NotReceived(uint _offerid) public payable{
        require(buyer[_offerid] == msg.sender && state[_offerid] == 1
        && block.timestamp > penaltyDate[buyerIDs[_offerid]]);
        uint id = buyerIDs[_offerid];
        payable(msg.sender).transfer((((price[_offerid])
                *(quantity[id])/4)* 5 + tc[_offerid]) * 1 gwei + 4430920 gwei);
        state[_offerid] = 6;
        shipmentAccepted[_offerid] = false;
    }
    
    function CheckShipment(uint _offerid, uint _quantity, bool _quality) public payable {
        require(buyer[_offerid] == msg.sender && state[_offerid] == 3);
        uint id = buyerIDs[_offerid];
        bool quality;   
        quality = _quality;
        if (quantity[id] == _quantity && quality == true){
                if(dueDate[id] < deliveryTime[_offerid]){
                payable(sender[_offerid]).transfer((((price[_offerid])
                *(quantity[id])*(100-penaltyPercent[id])/100)
                +((price[_offerid])*(quantity[id])/4)
                +tc[_offerid]) * 1 gwei + 4430920 gwei);
                payable(msg.sender).transfer(((price[_offerid])*(quantity[id])
                *(penaltyPercent[id])/100) * 1 gwei);
                delayed[_offerid] = true;
                }else {
                delayed[_offerid] = false;
                payable(sender[_offerid]).transfer((((price[_offerid])
                *(quantity[id])/4)* 5 + tc[_offerid]) * 1 gwei + 4430920 gwei);
                }
                shipmentAccepted[_offerid] = true;
                successfulShipments[sender[_offerid]] ++;
        }
        else{
            shipmentAccepted[_offerid] = false;
                payable(msg.sender).transfer(((price[_offerid])*(quantity[id])
                + tc[_offerid]) * 1 gwei);
                payable(sender[_offerid]).transfer(((price[_offerid])
                *(quantity[id])/4)* 1 gwei + 4430920 gwei);
            //}
        }
        if (needFasterDelivery[_offerid] == true && shipmentAccepted[_offerid] == true){
            if(expeditedDeliveryDate[_offerid] > deliveryTime[_offerid]){
                deliveryFlexibility[_offerid] = true;
            }
            else{
                deliveryFlexibility[_offerid] = false;
            }
        }
        state[_offerid] = 4;
    }

    function Refund(uint _offerid, uint amount, address user) OnlyAdmin public payable{
        if(state[_offerid] == 10){
            payable(user).transfer(amount * 1 gwei);
        }
    }
}
