// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;
contract Registration {

    address public admin;
    address [] suppliers;
    address [] public buyers;
    uint [] public products;

    uint public total_buyers;

    //  Supplier Information
    mapping(address => bytes32) supplierInfo;
    mapping(address => bool) public info_completed;
    mapping(address => bytes32) public Certificates;

    //  Product Information
    mapping (uint => address) public supplier;
    mapping (uint => string) public name;
    mapping (uint => bytes32) info;
    mapping (uint => uint) public recyclable_percentage;
    mapping (uint => uint) public recycled;
    mapping (uint => bool) public biodegradable_packaging;

    //  Environmental Performance
    mapping (address => uint) public energy_consumption;
    mapping (address => uint) public water_consumption;
    mapping (address => uint) public carbon_emission;
    mapping (address => bytes32) documents;

    constructor(){
        admin = msg.sender;      
    }

    modifier OnlyAdmin() {
        require (msg.sender == admin, "Only admin");
        _;
    }   

    function isAdmin(address m) public view returns(bool exist){
        return (m == admin);
    }
    
    function SupplierRegistration(address _supplier) public OnlyAdmin{
        suppliers.push(_supplier); 
    }

    function SupplierExistence(address m) public view returns(bool exist){
     for (uint i=0; i<suppliers.length; i++){
        if (m == suppliers[i]) {
            return true;}}
    }
    function _OnlySupplier() private view{
        require(SupplierExistence(msg.sender),
      "only registered suppliers."
      );
    }
    modifier OnlySupplier(){
      _OnlySupplier();
      _;
    }   

    
    function BuyerRegistration(address _buyer) public OnlyAdmin{
        buyers.push(_buyer);
        total_buyers++;    
    }

    function BuyerExistence(address m) public view returns(bool exist){
     for (uint i=0; i<buyers.length; i++){
        if (m == buyers[i]) {
            return true;}}
    }
    modifier OnlyBuyer{
      require(BuyerExistence(msg.sender),
      "only registered buyers."
      );
      _;
    }   

    function AddSupplierInfo(bytes32 _info, bytes32 _certificate, 
    uint _energy_consumption, uint _water_consumption, uint _carbon_emission, 
    bytes32 _documents) OnlySupplier public{

        supplierInfo[msg.sender] = _info;
        Certificates[msg.sender] = _certificate;
        info_completed[msg.sender] = true;
        energy_consumption[msg.sender] = _energy_consumption;
        water_consumption[msg.sender] = _water_consumption;
        carbon_emission[msg.sender] = _carbon_emission;
        documents[msg.sender] = _documents;
    }

    function RemoveSupplier(address _supplier) OnlyAdmin public {
        for (uint i=0; i<suppliers.length; i++){
            if (_supplier == suppliers[i]) {
                suppliers[i] = suppliers[suppliers.length-1];
            }
        }
        suppliers.pop();
        delete supplierInfo[_supplier];

        for (uint i=0; i<products.length; i++){
            if(supplier[products[i]] == _supplier){            
                products[i] = products[products.length-1];
                products.pop();            
            }
            
        }  
    }

    function RemoveBuyer(address _buyer) OnlyAdmin public {
        for (uint i=0; i<buyers.length; i++){
            if (_buyer == buyers[i]) {
                buyers[i] = buyers[buyers.length-1];
                buyers.pop();    
            }
        }
          
    }

    function AddProductInfo(uint serialNo, string memory _name, bytes32 _info, 
    bool _recycled, bool _biopack) OnlySupplier public{
            for (uint i=0; i<products.length; i++){
                if(serialNo == products[i]){
                    revert("The serialNo has been taken");
                }
            }
  
            if (supplier[serialNo] == address(0) && serialNo != 0){   
                supplier[serialNo] = msg.sender;
                name[serialNo] = _name;
                info[serialNo] = _info;
                biodegradable_packaging[serialNo] = _biopack;
                if(_recycled == true){
                    recycled[serialNo] = 1;
                }else{recycled[serialNo] = 0;}
                products.push(serialNo);} 
    }

    function RemoveProduct(uint serialNo) OnlySupplier public{
        require(supplier[serialNo] == msg.sender);
        for (uint i=0; i<products.length; i++){
            if (serialNo == products[i]) {
                products[i] = products[products.length-1];
                products.pop();
            }
        }
    }

    function filterProducts(string memory _name) public view returns(uint [] memory) {
        uint [] memory filteredProducts = new uint [] (products.length);
        for(uint i=0; i<products.length; i++){
            if(keccak256(abi.encodePacked(name[products[i]])) 
            == keccak256(abi.encodePacked(_name))){
                filteredProducts[i] = products[i];
            }
            
        }
        return filteredProducts;
    }

    function SearchProduct(uint _serialNo) public view returns(address _supplier, 
    string memory _name, bytes32 _info, uint _recycled, bool _biodegradablePackaging){
        return(supplier[_serialNo], name[_serialNo], 
        info[_serialNo], recycled[_serialNo],biodegradable_packaging[_serialNo]);
    }

    function getLength() external view returns(uint){
        return products.length;
    }

}
