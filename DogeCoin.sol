
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DogeCoin is ERC20
{
    constructor () ERC20("DogeCoin","Doge"){
        _mint(msg.sender, 10000 * 1e18);
    }
}

contract DogeSale
 {
    DogeCoin public Doge;
    address public owner;
    
    event BuyToken(address buyer, uint256 ehterAmount, uint256 TokenAmount);
    event SellToken(address Seller, uint256 ehterAmount, uint256 TokenAmount);

    uint256 public  constant InitialCoinPrice = 100;// price of 1 token is 1/100...

    constructor(address DogeCoinAddress)
    {
        Doge = DogeCoin(DogeCoinAddress);
    }
    
    //I need to create Buy function publicly for selling our DogeCoin
    function BuyDoge() public payable 
    {
        //  Bgair pay kiye yahan sy msg.value kuch bhe ho but zero na ho
        require(msg.value> 0,"Put Amount To buy");
        // Ether amount ak variable hy jo msg.value ko assign ki ja rhi hy idhr
        uint256 EtherAmount = msg.value;
       /* TokenAmount ak alag sy variable bnaya hy jo hmary coin ki quantity btaye ga ether amount ky lehaz sy
        Initial price hamary pass state variable hen uski multiply is liye kr rhy hen ky token ki total amount nikly
        */
        uint256 tokenAmount= EtherAmount*InitialCoinPrice;
        // Har liquidity pool me buying and selling fee hoti hy, Yahan meny 10% fee rakhi hy token  buy krny py
         uint256 BuyingFee = EtherAmount * 10/100;// This is 10% fee of buying token
        // Ye variale hy jo ky tokenamount show kry ga after deducting 10% fee
         uint256 AfterPayingFeeBuyingTokenAmount = tokenAmount - BuyingFee;
         // User jo bhe hoga uska address catch kia jaye ga.
        address user = msg.sender;
        /* yahan py condition statement lgai hy Doge hamary pass ak aisa variable hy jo dosry contract ky 
        functions ko idhr execute krwaye ga of token transer hongy Contract address sy user ky account me, 
        Or kitny token hongy
        */ 
        (bool sent) = Doge.transfer(user, AfterPayingFeeBuyingTokenAmount);
        require(sent,"Transfer Failed");
        
        /* yahan sy Buying token ka record ban ky transection me add ho jaye ga ky user kon hy 
         kitni amount ka buy kia , or token kitny bany fee pay krny ky bad
         */
        emit BuyToken(user, EtherAmount, AfterPayingFeeBuyingTokenAmount);
    }
    


    //I need to create Sell Function 
    function   SellDoge(uint256 Amount) public 
    { 
    // user ka address catch kren gy 
    address user = msg.sender;    
    // ye ak variable hy jo Doge.balanceof(user) amount assign kr gy ga UserTokenBalance ko                                
    uint256 UserTokenBalance= Doge.balanceOf(user);
    // yahan check kia jaye ga ky jo amount user dal rha hy wo usky account me hen ya nhe
    require(UserTokenBalance >=Amount,"Not Enough Token" );
    // yahan bhe initial amount ky lehas sy token ki amount bany gi or usky account me jaye gi
    uint EthAmount = Amount/InitialCoinPrice;
    // Meny 15% fee set ki hy jo bhe token apny sale kry ga 
    uint256 SellingFee = EthAmount * 15/100;// charging 15% of total tokens as a commission
    // yahan py address ka balance Seller ki input amount ky brabr ya ziyada ho
    require(address(this).balance >= EthAmount,"Not Enough Ether");

    /*Yahan sy token user ky account sy DogeCoinSale address me chaly jayen gy 
     Jitni Amount Seller chahy ga sale krna pahly wo aproved kry ga phr nikal sky ga.  */
     SellingFee = Amount;
    (bool send)= Doge.transferFrom(user, address(this), SellingFee);
    require(send,"Failed Transection");

    
    // yahan py Ether send hogy user ky account me token ki jitni amount wo inter 
    // kry ga usky crosponding 
    (bool sendEther,) = user.call{value: EthAmount}("");
    require(sendEther, "Ether transfer failed");
    //Ye transections ko track kr ky laye ga ky user ny kitny token sell kiye kitni price mili
    emit SellToken(user, EthAmount, SellingFee);

    } 
    modifier Onlyowner(){
        require(msg.sender== owner);
        _;
    }

    function withdraw() public Onlyowner
    {
     payable (msg.sender).transfer(address(this).balance);
    } 
}