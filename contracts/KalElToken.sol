// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

contract KalElToken {
    // defining state variables.
    uint256 private totalSupply;
    string private tokenName;
    string private tokenSymbol;
    uint256 private totalCappedSupply;
    address public owner;
    uint8 private decimals;
    bool public paused;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // defining events.
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Paused(address account);
    event Unpaused(address account);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event Allowance(address owner, address spender, uint256 amount);

    // defining the intialization point - constructor.
    constructor(
        uint256 _initialSupply,
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _totalCappedSupply,
        uint8 _decimals
    ) {
        require((_decimals > 0 && _decimals <= 18), "Macha: invalid decimals");
        require(
            (_initialSupply > 0),
            "Macha : Intial supply must be greater than 0"
        );
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        totalCappedSupply = _totalCappedSupply * (10 ** _decimals);
        decimals = _decimals;
        owner = msg.sender;

        uint256 intialTokens = _initialSupply * (10 ** decimals);

        mint(owner, intialTokens);
    }

    // defining modifiers.

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "KalEl: Access denied. Only the owner can perform this action."
        );
        _;
    }

    modifier hasSufficientBalance(uint256 balance, uint256 value) {
        require(
            balance >= value,
            "KalEl: Insufficient balance to complete the transaction."
        );
        _;
    }

    modifier isValidAddress(address addr) {
        require(
            addr != address(0),
            "KalEl: Invalid address. Address cannot be zero."
        );
        _;
    }

    modifier hasSufficientAllowance(uint256 _allowance, uint256 value) {
        require(
            _allowance >= value,
            "KalEl: Allowance exceeded. Insufficient allowance to transfer tokens."
        );
        _;
    }

    modifier withinCappedSupply(uint256 value) {
        require(
            (totalSupply + value) <= totalCappedSupply,
            "KalEl: Minting failed. Capped supply limit exceeded."
        );
        _;
    }

    modifier whenNotPaused() {
        require((!paused), "KalEl: Token operations are paused.");
        _;
    }

    // defining get functions for the state variables.

    function name() public view returns (string memory) {
        return tokenName;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function symbol() public view returns (string memory) {
        return tokenSymbol;
    }

    function getDecimals() public view returns (uint8) {
        return decimals;
    }

    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    // core operations functions.

    function transfer(
        address to,
        uint256 amount
    )
        public
        whenNotPaused
        isValidAddress(to)
        hasSufficientBalance(_balances[msg.sender], amount)
        returns (bool)
    {
        address from = msg.sender;
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function allowance(
        address _owner,
        address spender
    )
        public
        view
        isValidAddress(_owner)
        isValidAddress(spender)
        returns (uint256)
    {
        return _allowances[_owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public whenNotPaused isValidAddress(spender) returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    )
        public
        whenNotPaused
        isValidAddress(from)
        isValidAddress(to)
        hasSufficientAllowance(_allowances[from][msg.sender], amount)
        hasSufficientBalance(_balances[from], amount)
        returns (bool)
    {
        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function burn(
        address from,
        uint256 amount
    )
        public
        isValidAddress(from)
        hasSufficientBalance(_balances[from], amount)
        onlyOwner
        returns (bool)
    {
        _balances[from] -= amount;
        totalSupply -= amount;
        emit Burn(from, amount);
        return true;
    }

    function mint(
        address to,
        uint256 amount
    )
        public
        isValidAddress(to)
        withinCappedSupply(amount)
        onlyOwner
        returns (bool)
    {
        _balances[to] += amount;
        totalSupply += amount;
        emit Mint(to, amount);
        return true;
    }

    function pause() public onlyOwner {
        require(!paused, "KalEl: Token is already paused.");
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOwner {
        require(paused, "KalEl: Token is currently active, cannot unpause.");
        paused = false;
        emit Unpaused(msg.sender);
    }

    function transferOwnership(
        address newOwner
    ) public onlyOwner isValidAddress(newOwner) {
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
