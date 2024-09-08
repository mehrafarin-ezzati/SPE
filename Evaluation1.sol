// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;
import "./Registration.sol";
import "./Ordering.sol";
contract Evaluation1{

    Registration register = Registration(0xd9145CCE52D386f254917e481eB44e9943F39138);
    Ordering order = Ordering(0x358AA13c52544ECCEF6B0ADD0f801012ADAD5eE3);
   
    function Price(address _supplier, string memory _name) public view 
    returns(int SupplierAvgPrice, int CompetitorsAvgPrice, int Difference){    
        int j; int k; int l; int m;
        for(uint i=0; i<order.getLength(); i++){
            if(block.timestamp -30 days< order.offerTime(order.OfferIDs(i)) &&
            keccak256(abi.encodePacked(order.shipmentName(order.OfferIDs(i)))) 
            == keccak256(abi.encodePacked(_name))){
                if(order.supplier(order.OfferIDs(i)) == _supplier){
                    j += int(order.price(order.OfferIDs(i)));
                    k++;
                }
                else{
                    l += int(order.price(order.OfferIDs(i)));
                    m++;
                }
            }
        }
        return ((j/k),(l/m),(j/k)-(l/m));
    }

    function quickPart(uint[] memory data, uint low, uint high) internal pure {
        /*This function was taken from:    
    https://medium.com/coinmonks/sorting-in-solidity-without-comparison-4eb47e04ff0d*/
        if (low < high) {
            uint pivotVal = data[(low + high) / 2];
        
            uint low1 = low;
            uint high1 = high;
            for (;;) {
                while (data[low1] < pivotVal) low1++;
                while (data[high1] > pivotVal) high1--;
                if (low1 >= high1) break;
                (data[low1], data[high1]) = (data[high1], data[low1]);
                low1++;
                high1--;
            }
            if (low < high1) quickPart(data, low, high1);
            high1++;
            if (high1 < high) quickPart(data, high1, high);
        }
    }

    function PriceIncrement(address _supplier, string memory _name) public view 
    returns(int){
        uint [] memory SID = new uint [] (order.getLength());
        for(uint i=0; i<order.getLength(); i++){
            if(order.supplier(order.OfferIDs(i)) == _supplier &&
                keccak256(abi.encodePacked(order.shipmentName(order.OfferIDs(i)))) 
                == keccak256(abi.encodePacked(_name))){
                    SID[i] = order.offerTime(order.OfferIDs(i));
  
            }
        }
        quickPart(SID, 0,SID.length-1);
        uint l;
        for(uint j=0; j<SID.length; j++){
            
            if(SID[j] == 0){
                l++;
            }
        }

        uint [] memory ProductPrice = new uint [] (order.getLength());
        for(uint k=l; k<SID.length; k++){
            for(uint m=0; m<order.getLength(); m++){
                if(order.supplier(order.OfferIDs(m)) == _supplier 
                && keccak256(abi.encodePacked(order.shipmentName(order.OfferIDs(m)))) 
                == keccak256(abi.encodePacked(_name))){
                    if(SID[k] == order.offerTime(order.OfferIDs(m))){
                        ProductPrice[k] =  order.price(order.OfferIDs(m));
                    }
                }                
            }
        }
        int p; int r;
        for(uint n=l+1; n< ProductPrice.length; n++){
            p += int(ProductPrice[n] - ProductPrice[n-1]);
            r += int(SID[n] - SID[n-1]);
        }

        return (p/r);
    }

    function SuccessfulShipments(address _supplier) public view returns(uint){
        uint k;
        for(uint i=0; i<order.getLength(); i++){
            if(order.sender(order.OfferIDs(i)) == _supplier 
            && order.state(order.OfferIDs(i)) == 4){
                k++;
            }
        }
        return (order.successfulShipments(_supplier)*100/k);
    }
    

    function Production(address _supplier) public view returns(uint TotalGoodsSold,
    uint BackorderPercent, uint ProductionFlx){
        uint k; uint j; uint l;
        for(uint i=0; i<order.getLength(); i++){
            uint id = order.buyerIDs(order.OfferIDs(i));
            if(order.sender(order.OfferIDs(i)) == _supplier 
            && order.shipmentAccepted(order.OfferIDs(i)) == true){
                k += order.quantity(id);
                if(order.delayed(order.OfferIDs(i)) == true){
                    j += order.quantity(id);
                }
            }
            if(order.beingCustomized(id) == true 
            && order.shipmentAccepted(order.OfferIDs(i)) == true){
                l++;
            }
        }
        return (k,(j*100/k),l);
    }
   
}
