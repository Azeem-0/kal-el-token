// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract MachaToken {
    uint256 private totalSupply;
    string private tokenName;
    string private tokenSymbol;
    uint256 private totalCappedSupply;
    address public owner;
    uint8 private decimal;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    mapping(address account => uint256) private _balances;

    mapping(address owner => mapping(address spender => uint256))
        private _allowances;

    constructor(
        uint256 _intialSupply,
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _totalCappedSupply,
        uint8 _decimal
    ) {
        totalSupply = _intialSupply;
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        totalCappedSupply = _totalCappedSupply;
        decimal = _decimal;
        owner = msg.sender;
        _balances[owner] = _intialSupply;
    }

    function name() public view returns (string memory) {
        return tokenName;
    }
    function symbol() public view returns (string memory) {
        return tokenSymbol;
    }
    function decimals() public view returns (uint8) {
        return decimal;
    }

    modifier OnlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action.");
        _;
    }

    modifier HasBalance(uint256 balance, uint256 value) {
        require((balance >= value), "Insufficient balance");
        _;
    }

    modifier IsValidAddress(address add) {
        require((add != address(0)), "Not a valid address");
        _;
    }

    modifier HasAllowances(uint256 _allowance, uint256 value) {
        require((_allowance >= value), "Insufficient allowances.");
        _;
    }

    modifier VerifyCappedSupply(uint256 value) {
        require(
            ((totalSupply + value) <= totalCappedSupply),
            "Cannot mint more tokens, as capped supply is reached."
        );
        _;
    }

    // functions that are essential for a smart contract to be called as a token.

    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address to,
        uint256 amount
    )
        public
        IsValidAddress(to)
        IsValidAddress(msg.sender)
        HasBalance(_balances[msg.sender], amount)
        returns (bool)
    {
        address from = msg.sender;
        uint256 fromBalance = _balances[from];
        _balances[from] = fromBalance - amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    )
        public
        view
        IsValidAddress(_owner)
        IsValidAddress(_spender)
        returns (uint256)
    {
        return _allowances[_owner][_spender];
    }

    function approve(
        address _spender,
        uint256 amount
    )
        public
        IsValidAddress(_spender)
        IsValidAddress(msg.sender)
        returns (bool)
    {
        address _owner = msg.sender;
        _allowances[_owner][_spender] = amount;
        emit Approval(_owner, _spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    )
        public
        IsValidAddress(from)
        IsValidAddress(to)
        HasAllowances(_allowances[from][to], amount)
        HasBalance(_balances[from], amount)
        returns (bool)
    {
        uint256 fromBalance = _balances[from];
        _allowances[from][to] -= amount;
        _balances[from] = fromBalance - amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function burn(
        address from,
        uint256 amount
    )
        public
        IsValidAddress(from)
        HasBalance(_balances[from], amount)
        returns (bool)
    {
        uint256 fromBalance = _balances[from];
        _balances[from] = fromBalance - amount;
        totalSupply -= amount;

        emit Burn(from, amount);
        return true;
    }

    function mint(
        address to,
        uint256 amount
    ) public IsValidAddress(to) VerifyCappedSupply(amount) returns (bool) {
        _balances[to] += amount;
        totalSupply += amount;

        emit Mint(to, amount);
        return true;
    }
}
