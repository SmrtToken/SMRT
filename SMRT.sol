/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit  Unpause();
  }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic, Pausable {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
  uint256 preICOReserveTokens;
  uint256 icoReserveTokens;
  uint256 bonusTokensLimit;
  address preicodistributor;
  address icodistributor;
  address businessReserveAddress;
  uint256 public timeLock = 1523102399; //7 April 2018 locked
  
  modifier checkAdditionalTokenLock() {
     
          if(msg.sender == businessReserveAddress){
             if(now < timeLock){
                 revert();
             }else{
                 _;
             }
          }else{
            _;
          }
     
  }
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public  checkAdditionalTokenLock returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

 

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns preico and ico amount of tokens.
   * 
   */
  function burn() public {
    if(msg.sender == preicodistributor){
        uint256 _tokensToBurn = balanceOf(msg.sender);
        uint256 totalSalePreICO = (preICOReserveTokens - _tokensToBurn) * 2;
        uint256 tokensReserveForBusiness = (totalSalePreICO * 40) / 100;
         balances[msg.sender] = balances[msg.sender].sub(_tokensToBurn);
         balances[businessReserveAddress] = balances[businessReserveAddress].add(tokensReserveForBusiness);
         totalSupply = totalSupply.sub(_tokensToBurn);
          emit Burn(msg.sender, _tokensToBurn);
        emit  Transfer(msg.sender, address(0), _tokensToBurn);
    }else if (msg.sender == icodistributor){
         _tokensToBurn = balanceOf(msg.sender);
        uint256 totalSaleICO = (icoReserveTokens - _tokensToBurn) * 2;
        tokensReserveForBusiness = (totalSaleICO * 40) / 100;
        balances[msg.sender] = balances[msg.sender].sub(_tokensToBurn);
        balances[businessReserveAddress] = balances[businessReserveAddress].add(tokensReserveForBusiness);
        totalSupply = totalSupply.sub(_tokensToBurn);
       emit Burn(msg.sender, _tokensToBurn);
       emit  Transfer(msg.sender, address(0), _tokensToBurn);
    }else{
        revert();
    }
  }
}
contract StandardToken is ERC20, BurnableToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  
  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public checkAdditionalTokenLock returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public checkAdditionalTokenLock returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public checkAdditionalTokenLock returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


contract SMRTCoin is StandardToken {
    string public constant name = "SMRT";
    uint public constant decimals = 18;
    string public constant symbol = "SMRT";
     using SafeMath for uint256;
     uint256 public weiRaised =0;
     address depositWalletAddress;
     event Buy(address _from,uint256 _ethInWei,string email);
     uint256 startPreSale;
     uint256 endPreSale;
     uint256 startSale;
     uint256 endSale;
    function SMRTCoin()  public {
       owner = msg.sender;
       totalSupply = 600000000 * (10**decimals);   
       preICOReserveTokens = 90000000 * (10**decimals);   
       icoReserveTokens =  210000000 * (10**decimals);  
       bonusTokensLimit = 60000000 * (10**decimals);   
       preicodistributor = 0x9c609bfbd0e12ed9f8b1162a7c0f8fdf7fe48e68; ///TODO change by admin
       icodistributor = 0x5b162cee49e4bf42e8b1145a9c3792ca2fb7ec41 ;//TODO change by admin
       depositWalletAddress= owner; //TODO change
       businessReserveAddress = owner; //TODO change
       balances[preicodistributor] = preICOReserveTokens;
       balances[icodistributor] = icoReserveTokens;
       emit Transfer(address(0),preicodistributor, preICOReserveTokens);
       emit Transfer(address(0),icodistributor, icoReserveTokens);
       startPreSale = now;//TODO update 1521900000 //24 march 14 00 00  UTC
       endPreSale = 1524319200; //21 April 14 00 00 utc
       startSale = endPreSale +1;
       endSale = startSale + 30 days;
    }

    function()   public {
        revert();
    }
    /**
     * This will be called by adding data to represnet data.
     */ 
    function buy(string email) public payable whenNotPaused{
         require(msg.value>0);
         require(msg.sender != address(0));
          weiRaised += msg.value;
         forwardFunds();
         emit Buy(msg.sender,msg.value,email);
    }
    /**
     * This function will called by only distributors to send tokens by calculating from offchain listners
     */ 
    function CrowdSale(address recieverAddress, uint256 tokens) public onlyDistributor {
       require(now<=endSale);
        uint bonus = 0;
        if(now <= endPreSale){
            bonus = 50;
        }else if (now < startSale + 1 weeks ){
             bonus = 10;
        }else if (now < startSale + 2 weeks ){
            bonus = 5; 
        }
        uint256 bonusTokens = (tokens * bonus) /100;
        if(bonusTokensLimit>=bonusTokens){
            tokens = tokens + bonusTokens;
         }
        transfer(recieverAddress,tokens);
    }
    /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
    function forwardFunds() internal {
         depositWalletAddress.transfer(msg.value);
     }
  function changeDepositWalletAddress (address newDepositWalletAddr) public onlyOwner {
       require(newDepositWalletAddr!=0);
       depositWalletAddress = newDepositWalletAddr;
  }
  function updateSaleTime (uint256 _startSale,uint256 _endSale) public onlyOwner{
      startSale = _startSale;
      endSale = _endSale;
  }
  
  /**
   * to verify token distributor
   */ 
  modifier onlyDistributor () {
      if(msg.sender == preicodistributor || msg.sender == icodistributor){
          _;
      }else{
          revert();
      }
  }
}