pragma solidity ^0.5.8;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ERC1404.sol";
import '../contracts/ITransferRules.sol';

import "./support/UserProxy.sol";


contract TransferRulesUpgrade is ITransferRules {
 function detectTransferRestriction(ERC1404 token, address from, address to, uint256 value) public view returns(uint8) {
    if(from == to && value > 0) return token.decimals(); // prove we are using all the arguments
    return 17; // grab an arbitrary value from the injected token contract
  }

  function messageForTransferRestriction(uint8 restrictionCode) public pure returns(string memory) {
    return "HELLO UPGRADE";
  }
}

contract TransferRulesUpgradeTest {
    ERC1404 token;
    address owner;

    function beforeEach() public {
        owner = address(this);
        uint8 decimalsWeWillPassToTransferRules = 6;
        token = new ERC1404(owner, owner, "xyz", "Ex Why Zee", decimalsWeWillPassToTransferRules, 22);
        token.setMaxBalance(owner, 100);
        token.setAllowGroupTransfer(0, 0, 1); // don't restrict default group transfers
    }

    function testReplaceTransferRules() public {
        uint8 code = token.detectTransferRestriction(owner,owner,1);
        Assert.equal(uint256(code), 0, "initial TransferRules shoudl return code 0");
        
        // upgrade the TransferRules
        TransferRulesUpgrade nextRules = new TransferRulesUpgrade();
        token.setTransferRules(nextRules);
        
        code = token.detectTransferRestriction(owner,owner,1);
        Assert.equal(uint256(code), 6, "custom code should be returned after setting new TransferRules");

        Assert.equal(token.messageForTransferRestriction(6),
          "HELLO UPGRADE",
          "should return the new transfer restriction messages");
    }
}