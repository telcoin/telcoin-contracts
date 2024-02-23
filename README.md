# telcoin-contracts

![hardhat](https://img.shields.io/badge/hardhat-2.20.1-blue)
![node](https://img.shields.io/badge/node-v20.11.1-brightgreen.svg)
![solidity](https://img.shields.io/badge/solidity-0.8.24-red)
![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-^5.0.1-brightgreen.svg)
![coverage](https://img.shields.io/badge/coverage->80%25-yellowgreen)
![comments](https://img.shields.io/badge/comments->80%25-yellowgreen)

**Telcoin** is designed to complement telecom, mobile money, and e-wallet partners globally with both traditional fiat and blockchain transaction rails that underpin our fast and affordable digital financial service offerings. Telcoin combines the best parts of the burgeoning DeFi ecosystem with our compliance-first approach to each market, ensuring that the company takes on a fraction of traditional financial counter-party, execution, and custody risks.

## Running Tests

To get started, all you should need to install dependencies and run the unit tests are here.

```shell
npm install
npm test
```

Under the hood `npm test` is running `npx hardhat clean && npx hardhat coverage`

Contracts that are used for testing are labeled with the `Test` prefix. Those that are representative of a live contract but are augmented for easier testing are labeled with the `Mock` prefix.

```txt
                                     ttttttttttttttt,                           
                              *tttttttttttttttttttttttt,                        
                       *tttttttttttttttttttttttttttttttttt,                     
                ,tttttttttttttttttttttttttttttttttttttttttttt,                  
          .ttttttttttttttttttttttttttttttttttttttttttttttttttttt.               
        ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt.            
       ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt.         
      ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt       
     .ttttttttttttttttttttttttttttttttt    ttttttttttttttttttttttttttttttttt.   
     tttttttttttttttttttttttttttttttt     *ttttttttttttttttttttttttttttttttttt. 
     ttttttttttttttttttttttttttttt.       ttttttttttttttttttttttttttttttttttttt,
    *ttttttttttttttttttttttttt,          ************ttttttttttttttttttttttttttt
    tttttttttttttttttttttttt                        tttttttttttttttttttttttttttt
   *ttttttttttttttttttttttt*                        ttttttttttttttttttttttttttt,
   ttttttttttttttttttttttttttttt        *tttttttttttttttttttttttttttttttttttttt 
  ,tttttttttttttttttttttttttttt,       ,tttttttttttttttttttttttttttttttttttttt* 
  ttttttttttttttttttttttttttttt        ttttttttttttttttttttttttttttttttttttttt  
  tttttttttttttttttttttttttttt.       ,ttttttttttttttttttttttttttttttttttttttt  
 ttttttttttttttttttttttttttttt        ttttttttttttttttttttttttttttttttttttttt   
 ttttttttttttttttttttttttttttt        ttttttttttttttttttttttttttttttttttttttt   
 ttttttttttttttttttttttttttttt         *********tttttttttttttttttttttttttttt.   
 ttttttttttttttttttttttttttttt*                 tttttttttttttttttttttttttttt    
  *ttttttttttttttttttttttttttttt               tttttttttttttttttttttttttttt*    
    .tttttttttttttttttttttttttttttttttttttttttt*ttttttttttttttttttttttttttt     
       .ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt     
          .ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt      
             .tttttttttttttttttttttttttttttttttttttttttttttttttttttttttt,       
                .ttttttttttttttttttttttttttttttttttttttttttttttttttttt          
                   ,ttttttttttttttttttttttttttttttttttttttttttt*                
                      ,ttttttttttttttttttttttttttttttttt*                       
                         ,tttttttttttttttttttttttt.                             
                            ,*ttttttttttttt.                                    
```
