pragma solidity ^0.5.8;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ERC1404.sol";
import "./support/UserProxy.sol";

contract MaxReceiverBalanceTest {
    ERC1404 token;
    address tokenContractOwner;
    UserProxy public alice;
    UserProxy public bob;
    address reserveAdmin;

    function beforeEach() public {
        tokenContractOwner = address(this);
        reserveAdmin = address(0x1);
        token = new ERC1404(tokenContractOwner, reserveAdmin, "xyz", "Ex Why Zee", 6, 1234567);

        alice = new UserProxy(token);
        bob = new UserProxy(token);

        token.setAllowGroupTransfer(0, 0, now); // don't restrict default group transfers
    }

    function testAdminCanAddAccountToWhitelistAndBeApprovedForTransfer() public {       
        uint8 restrictionCode = token.detectTransferRestriction(address(alice), address(bob), 17);
        

        token.setMaxBalance(address(bob), 10);
        restrictionCode = token.detectTransferRestriction(address(alice), address(bob), 10);
        Assert.equal(uint(restrictionCode), 0, "should allow max value");

        token.setMaxBalance(address(bob), 0);
        restrictionCode = token.detectTransferRestriction(address(alice), address(bob), 10);
        Assert.equal(uint(restrictionCode), 1, "should not allow a value transfer above the max for the recipient address");
    }

    function testGetMaxBalance() public {
        Assert.equal(token.getMaxBalance(address(alice)), 0, "wrong balance for alice");
        token.setMaxBalance(address(alice), 10);
        Assert.equal(token.getMaxBalance(address(alice)), 10, "wrong balance for alice");
    }
}