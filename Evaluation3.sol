// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;
import "./Registration.sol";
import "./Ordering.sol";
import "./Complaint.sol";

contract Evaluation3{

    Registration register = Registration(0xd9145CCE52D386f254917e481eB44e9943F39138);
    Ordering order = Ordering(0x358AA13c52544ECCEF6B0ADD0f801012ADAD5eE3);
    Complaint complaint = Complaint(0xddaAd340b0f1Ef65169Ae5E41A8b10776a75482d);    
    function BiodegradablePackaging(address _supplier) public view returns(uint){
        uint j;
        uint k;
        for(uint i=0; i<register.getLength(); i++){
            if(register.supplier(register.products(i)) == _supplier){
                k += 1;
                if(register.biodegradable_packaging(register.products(i)) == true){
                    j += 1;
                }
            }
        }
        return (j*100/k);
    }

    function ENVCriteria(address _supplier) public view returns(uint energy, 
    uint water, uint carbon){
        return (register.energy_consumption(_supplier), 
        register.water_consumption(_supplier),
        register.carbon_emission(_supplier));
    }

    function SupplierCertification(address _supplier) public view returns(bytes32){
        return register.Certificates(_supplier);
    }

    function SustainableProduct(address _supplier) public view 
    returns(uint RecycledCapacity){
        uint k; uint l;
        for(uint i=0; i<order.getLength(); i++){
            uint id = order.buyerIDs(order.OfferIDs(i));
            if(order.sender(order.OfferIDs(i)) == _supplier 
            && order.shipmentAccepted(order.OfferIDs(i)) == true){
                k += order.quantity(id);
                for(uint j=0; j<register.getLength(); j++){
                    if(keccak256(abi.encodePacked(order.shipmentName(order.OfferIDs(i)))) 
                    == keccak256(abi.encodePacked(register.name(register.products(j))))    
                    && _supplier == register.supplier(register.products(j))){
                        l += order.quantity(id)*register.recycled(register.products(j));
                    }
                }
            }
        }
        return (l*100/k);
    }

    function ResposeQuickness(address _supplier) public view returns(uint){
        uint j; uint k;
        for(uint i=0; i<order.getLength(); i++){
            if(order.sender(order.OfferIDs(i)) == _supplier){// ***
                uint id = order.buyerIDs(order.OfferIDs(i));
                j += order.offerTime(order.OfferIDs(i)) - order.requestTime(id);
                k++;
            }
        }
        return (j/k);
    }

    function LoyalCustomers(address _supplier) public view returns(uint){
        uint [] memory customers = new uint [] (register.total_buyers());
        for(uint i=0; i<order.getLength(); i++){
            if(order.sender(order.OfferIDs(i)) == _supplier){
                for(uint j=0; j<register.total_buyers(); j++){
                    if(order.buyer(order.OfferIDs(i)) == register.buyers(j)){
                        customers[j] += 1;
                        break;
                    }
                }
            }
        }
        uint l; uint m;
        for(uint k=0; k<customers.length; k++){
            if(customers[k]>0){
                m++;
                if(customers[k]>1){
                    l++;
                }
            }
        }

        return (l*100/m);
    }

    function ComplaintsCriteria(address _supplier) public view returns(uint AvgComplaints,
    uint AvgSolvingTime, uint SolvingEfficiency, uint AnsweredComplaint){
        uint j; uint k; uint m; uint n;
        for(uint i=0; i<complaint.getLength(); i++){
            if(complaint.receiver(complaint.id(i)) == _supplier){
                if(complaint.complaintConfirmation(complaint.id(i)) == true){
                    n++; 
                    if(complaint.responseTime(complaint.id(i)) > 0){
                        m++;
                        j = complaint.responseTime(complaint.id(i)) 
                        - complaint.confirmationTime(complaint.id(i));
                        if(complaint.responseUsefulness(complaint.id(i)) == false){
                            k++;
                        }
                    }
                }
            }
        }
        return((m*100/order.successfulShipments(_supplier)), (j/m), ((m-k)*100/m), m*100/n);
    }

}
