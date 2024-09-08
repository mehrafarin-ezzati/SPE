// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;
import "./Registration.sol";
import "./Ordering.sol";

contract Evaluation2{
    //address contractAddress;
    Registration register = Registration(0xd9145CCE52D386f254917e481eB44e9943F39138);
    Ordering order = Ordering(0x358AA13c52544ECCEF6B0ADD0f801012ADAD5eE3);

    function Delivery(address _supplier) public view returns(uint AvgDeliveryTime, 
    uint completedDelivery, int DeliveryVar){
        uint p; uint l; uint m; int n; 
        for(uint i=0; i<order.getLength(); i++){
            uint id = order.buyerIDs(order.OfferIDs(i));
            if(order.sender(order.OfferIDs(i)) == _supplier 
            && order.beingCustomized(id) == false){
                if(order.state(order.OfferIDs(i)) == 4){
                    l += order.deliveryTime(order.OfferIDs(i)) 
                    - order.offerTime(order.OfferIDs(i));
                    m++;   
                }
                if(order.state(order.OfferIDs(i)) == 6){
                    p++;
                }
            }
        }
        
       
        for(uint x=0; x<order.getLength(); x++){
            if(order.sender(order.OfferIDs(x)) == _supplier 
            && order.state(order.OfferIDs(x)) == 4){
                uint id = order.buyerIDs(order.OfferIDs(x));
                if(order.beingCustomized(id) == false){
                n = n+(int(order.deliveryTime(order.OfferIDs(x))
                - order.offerTime(order.OfferIDs(x)))-int(l/m))**2;
                }
            }
        }
        return ((l/m), (m*100/(m+p)),(n/int(m)));
    }

    function DeliveryFlx(address _supplier) public view returns(uint){
        uint j; uint k; 
        for(uint i=0; i<order.getLength(); i++){
            if(order.sender(order.OfferIDs(i)) == _supplier){
                if(order.state(order.OfferIDs(i)) == 4 
                || order.state(order.OfferIDs(i)) == 6){
                    if(order.deliveryFlexibility(order.OfferIDs(i)) == true){
                            j++;
                        }
                    if(order.needFasterDelivery(order.OfferIDs(i)) == true){
                        k++;
                    }
                }
            }
        }
        return((j*100/k));
    }

    function DelayTime(address _supplier)public view returns(uint){
        uint m; uint p;
        for(uint i=0; i<order.getLength(); i++){
            if(order.sender(order.OfferIDs(i)) == _supplier 
            && order.state(order.OfferIDs(i)) == 4){
                uint id = order.buyerIDs(order.OfferIDs(i));
                if(order.beingCustomized(id) == false){
                    m++;
                    if(order.deliveryTime(order.OfferIDs(i)) > order.dueDate(id)) {
                        p += order.deliveryTime(order.OfferIDs(i)) - order.dueDate(id);
                    }
                          
                }
            }
        }
        return(p/m);
    }

    function CustomizedDeliveryTime(address _supplier)public view returns(uint){
        uint a; uint c;
        for(uint i=0; i<order.getLength(); i++){
            if(order.sender(order.OfferIDs(i)) == _supplier 
            && order.state(order.OfferIDs(i)) == 4){
                uint id = order.buyerIDs(order.OfferIDs(i));
                if(order.beingCustomized(id) == true){
                    a += order.deliveryTime(order.OfferIDs(i)) 
                    - order.offerTime(order.OfferIDs(i));
                    c++;
                }
            }
        }
        return(a/c);
    }

}
