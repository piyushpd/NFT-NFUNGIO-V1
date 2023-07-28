// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract EnumTest{
  
  address payable public admin= payable(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);
 //address payable public admin = payable(address(this));


enum Age_Class{CHILD, TEEN, ADULT, SENIOR_CITIZEN}
    Age_Class ageclass;
    Age_Class public s;
    
    //string status;

  struct E1 {
        string catergory;
     
    }
 E1 public e1;

 constructor() payable{}
 receive () external payable{}

 function addUser(uint256 age1) external payable {


s=checkCategory(age1);


if (uint(s) == 0){
    e1.catergory ="CHILD";
}
if (uint(s) == 1){
    e1.catergory ="TEEN";
}
if (uint(s) == 2){
    e1.catergory ="ADULT";
}
if (uint(s) == 3){
    e1.catergory ="SENIOR_CITIZEN";
}

 admin.transfer(10 ether);


}


 function checkCategory(uint age) internal returns (Age_Class) {

     if (age <=12) {
         ageclass= Age_Class.CHILD;
         return ageclass;
     }
    
     if (age >=13 && age <=19) {
         ageclass= Age_Class.TEEN;
         return ageclass;
     }

     if (age >=20 && age <=60) {
         ageclass= Age_Class.ADULT;
         return ageclass;
     }

     if (age > 60) {
         ageclass= Age_Class.SENIOR_CITIZEN;
         return ageclass;
     }

    
 }


}