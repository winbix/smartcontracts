pragma solidity ^0.5.0;

import "../utils/MultiManageable.sol";
import "../utils/SafeMath.sol";
import "../token/IWinbixToken.sol";
import "../token/WinbixPayable.sol";
import "./externals/IVerificationList.sol";
import "./externals/IVoting.sol";
import "./externals/ITap.sol";
import "./externals/IRefund.sol";

contract PreDAICO is MultiManageable, WinbixPayable, SafeMath {

    enum KycStates { None, OnCheck, Accepted, Rejected }
    enum VotingType { None, Prolongation, TapChange }

    uint constant SOFTCAP = 6250000 ether;
    uint constant HARDCAP = 25000000 ether;
    uint constant TOKENS_FOR_MARKETING = 2500000 ether;
    uint constant TOKENS_FOR_ISSUE = 27500000 ether;

    uint constant MIN_PURCHASE = 0.1 ether;

    uint constant SKIP_TIME = 15 minutes;

    uint constant PRICE1 = 550 szabo;
    uint constant PRICE2 = 600 szabo;
    uint constant PRICE3 = 650 szabo;
    uint constant PRICE4 = 700 szabo;
    uint constant PRICE5 = 750 szabo;

    uint public soldTokens;
    uint public recievedEther;
    uint public etherAfterKyc;
    uint public tokensAfterKyc;
    uint public refundedTokens;

    IVerificationList public buyers;
    IVoting public voting;
    ITap public tap;
    IRefund public refund;

    mapping (address => uint) public etherPaid;

    uint public startDate;
    uint public endDate;
    uint public additionalTime;

    uint public tokensForMarketingTotal;
    uint public tokensForMarketingRemains;

    VotingType private votingType;
    bool private votingApplied = true;


    event HardcapCompiled();
    event SoftcapCompiled();
    event Tap(address _address, uint _value);
    event Refund(address _address, uint _tokenAmount, uint _etherAmount);

    modifier isProceeds {
        require(now >= startDate && now <= endDate);
        _;
    }

    function setExternals(
        address _winbixToken,
        address _buyers,
        address _voting,
        address _tap,
        address _refund
    ) public onlyManager {
        if (address(winbixToken) == address(0)) {
            winbixToken = IWinbixToken(_winbixToken);
            winbixToken.setMePayable(true);
        }
        if (address(buyers) == address(0)) {
            buyers = IVerificationList(_buyers);
            buyers.acceptOwnership();
        }
        if (address(voting) == address(0)) {
            voting = IVoting(_voting);
            voting.acceptOwnership();
        }
        if (address(tap) == address(0)) {
            tap = ITap(_tap);
            tap.acceptOwnership();
        }
        if (address(refund) == address(0)) {
            refund = IRefund(_refund);
            refund.acceptOwnership();
        }
    }

    function startPreDaico() public onlyManager {
        require(
            (startDate == 0) &&
            address(buyers) != address(0) &&
            address(voting) != address(0) &&
            address(tap) != address(0) &&
            address(refund) != address(0)
        );
        winbixToken.issue(address(this), TOKENS_FOR_ISSUE);
        startDate = now;
        endDate = now + 60 days;
    }

    function () external payable isProceeds {
        require(soldTokens < HARDCAP && msg.value >= MIN_PURCHASE);

        uint etherValue = msg.value;
        uint tokenPrice = getTokenPrice();
        uint tokenValue = safeMul(etherValue, 1 ether) / tokenPrice;
        uint newSum = safeAdd(soldTokens, tokenValue);
        bool softcapNotYetCompiled = soldTokens < SOFTCAP;

        buyers.toCheck(msg.sender);
        winbixToken.freeze(msg.sender);

        if (newSum > HARDCAP) {
            uint forRefund = safeMul((newSum - HARDCAP), tokenPrice) / (1 ether);
            address(msg.sender).transfer(forRefund);
            etherValue = safeSub(etherValue, forRefund);
            tokenValue = safeSub(HARDCAP, soldTokens);
        }

        soldTokens += tokenValue;
        recievedEther += etherValue;
        etherPaid[msg.sender] += etherValue;

        winbixToken.transfer(msg.sender, tokenValue);
        winbixToken.issueVotable(msg.sender, tokenValue);
        winbixToken.issueAccruable(msg.sender, tokenValue);

        if (softcapNotYetCompiled && soldTokens >= SOFTCAP) {
            emit SoftcapCompiled();
        }
        if (soldTokens == HARDCAP) {
            endDate = now;
            emit HardcapCompiled();
        }
    }

    function getTokenPrice() public view returns (uint) {
        if (soldTokens <= 5000000 ether) {
            return PRICE1;
        } else if (soldTokens <= 10000000 ether) {
            return PRICE2;
        } else if (soldTokens <= 15000000 ether) {
            return PRICE3;
        } else if (soldTokens <= 20000000 ether) {
            return PRICE4;
        } else {
            return PRICE5;
        }
    }

    function kycSuccess(address _address) public onlyManager {
        require(now > endDate + SKIP_TIME && now < endDate + additionalTime + 15 days);
        require(!buyers.isAccepted(_address));
        etherAfterKyc += etherPaid[_address];
        tokensAfterKyc += winbixToken.balanceOf(_address);
        winbixToken.unfreeze(_address);
        buyers.accept(_address);
    }

    function kycFail(address _address) public onlyManager {
        require(now > endDate + SKIP_TIME && now < endDate + additionalTime + 15 days);
        require(!buyers.isRejected(_address));
        if (buyers.isAccepted(_address)) {
            etherAfterKyc -= etherPaid[_address];
            tokensAfterKyc -= winbixToken.balanceOf(_address);
        }
        if (!winbixToken.isFrozen(_address)) winbixToken.freeze(_address);
        buyers.reject(_address);
    }

    function getKycState(address _address) public view returns (KycStates) {
        return KycStates(buyers.getState(_address));
    }


    function prepareTokensAfterKyc() public {
        require(tokensForMarketingTotal == 0);
        require(now > endDate + additionalTime + 15 days + SKIP_TIME && soldTokens >= SOFTCAP);
        tokensForMarketingTotal = tokensAfterKyc / 10;
        tokensForMarketingRemains = tokensForMarketingTotal;
        winbixToken.burn(TOKENS_FOR_ISSUE - soldTokens - tokensForMarketingTotal);
        winbixToken.allowTransfer(true);
        tap.init(etherAfterKyc, endDate + additionalTime + 17 days + SKIP_TIME);
        refund.init(address(winbixToken), tokensAfterKyc, address(tap), endDate + 45 days);
    }

    function transferTokensForMarketing(address _to, uint _value) public onlyManager {
        require(_value <= tokensForMarketingRemains && buyers.isAcceptedOrNotInList(_to));
        winbixToken.transfer(_to, _value);
        winbixToken.issueAccruable(_to, _value);
        tokensForMarketingRemains -= _value;
    }

    function burnTokensIfSoftcapNotCompiled() public {
        require(now > endDate + 2 days + SKIP_TIME && soldTokens < SOFTCAP);
        winbixToken.burnAll();
    }


    function getTap() public onlyManager {
        uint tapValue = tap.getNext();
        address(msg.sender).transfer(tapValue);
        emit Tap(msg.sender, tapValue);
    }


    function getVotingSubject() public view returns (uint8) {
        return voting.subject();
    }

    function initCrowdsaleProlongationVoting() public onlyManager {
        require(now >= endDate + SKIP_TIME && now <= endDate + 12 hours);
        require(soldTokens >= SOFTCAP * 75 / 100);
        require(soldTokens <= HARDCAP * 90 / 100);
        voting.initProlongationVoting();
        votingApplied = false;
        additionalTime = 2 days;
        votingType = VotingType.Prolongation;
    }

    function initTapChangeVoting(uint8 newPercent) public onlyManager {
        require(soldTokens >= SOFTCAP);
        require(now > endDate + 17 days);
        voting.initTapChangeVoting(newPercent);
        votingApplied = false;
        votingType = VotingType.TapChange;
    }

    function isVotingInProgress() public view returns (bool) {
        return voting.inProgress();
    }

    function getVotingWeight(address _address) public view returns (uint) {
        if (votingType == VotingType.TapChange && !buyers.isAccepted(_address)) {
            return 0;
        }
        return winbixToken.votableBalanceOf(_address);
    }

    function voteYes() public {
        voting.yes(msg.sender, getVotingWeight(msg.sender));
    }

    function voteNo() public {
        voting.no(msg.sender, getVotingWeight(msg.sender));
    }

    function getVote(address _address) public view returns (int) {
        return voting.vote(_address);
    }

    function getVotesTotal() public view returns (uint) {
        return voting.votesTotal();
    }

    function isSubjectApproved() public view returns (bool) {
        return voting.isSubjectApproved();
    }

    function applyVotedProlongation() public {
        require(now < endDate + 2 days);
        require(votingType == VotingType.Prolongation);
        require(!votingApplied);
        require(!voting.inProgress());
        votingApplied = true;
        if (voting.isSubjectApproved()) {
            startDate = endDate + 2 days;
            endDate = startDate + 30 days;
            additionalTime = 0;
        }
    }

    function applyVotedPercent() public {
        require(votingType == VotingType.TapChange);
        require(!votingApplied);
        require(!voting.inProgress());
        require(now < voting.nextVotingDate());
        votingApplied = true;
        if (voting.isSubjectApproved()) {
            tap.changeNextTap(voting.subject());
        }
    }


    function refundableBalanceOf(address _address) public view returns (uint) {
        if (!buyers.isAcceptedOrNotInList(_address)) return 0;
        return winbixToken.votableBalanceOf(_address);
    }

    function calculateEtherForRefund(uint _tokensAmount) public view returns (uint) {
        return refund.calculateEtherForRefund(_tokensAmount);
    }


    function winbixPayable(address payable _from, uint256 _value) internal {
        if (_value == 0) return;
        uint etherValue;
        KycStates state = getKycState(_from);
        if (
            (soldTokens < SOFTCAP && now > endDate + 2 days) ||
            ((state == KycStates.Rejected || state == KycStates.OnCheck) && (now > endDate + additionalTime + 17 days))
        ) {
            etherValue = etherPaid[_from];
            require(etherValue > 0 && winbixToken.balanceOf(_from) == 0);
            _from.transfer(etherValue);
            etherPaid[_from] = 0;
            winbixToken.unfreeze(_from);
        } else {
            etherValue = refund.refundEther(_from, _value);
            _from.transfer(etherValue);
            tap.subRemainsForTap(etherValue);
            emit Refund(_from, _value, etherValue);
        }
        winbixToken.burn(_value);
    }
}