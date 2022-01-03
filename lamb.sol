// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

// author : smshayan

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract lamb is ERC721Enumerable , Ownable {
   using Strings for uint256;

  string public baseURI;
  string public baseExtension = ".json";
  string public notRevealedUri;
  uint256 public cost = 0.04 ether;
  uint256 public maxSupply = 10000;
  uint256 public maxMintAmount = 20;
  uint256 public nftPerAddressLimit = 5;
  bool public paused = false;
  bool public revealed = false;
  bool public onlyWhitelisted = true;
  address[] public whitelistedAddresses;
  mapping(address => uint256) public addressMintedBalance;


  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initNotRevealedUri
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_initNotRevealedUri);
  } 


    function costed() internal view returns(uint256 _cost) {
         if ( onlyWhitelisted == true) {            
             return 0.03 ether;
        }
         else {
            return 0.04 ether;
        }
    }




     
    function mint(uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();
        uint256 ownerMintedCount = addressMintedBalance[msg.sender];
        require (!paused);
        require (_mintAmount > 0);
        require (supply + _mintAmount <= 9850);
        require (_mintAmount + ownerMintedCount <= nftPerAddressLimit);
        require (msg.value >= costed() * _mintAmount);
        
        

        if( onlyWhitelisted == true) {
            require(isWhitelisted(msg.sender), "user is not isWhitelisted");
            require (supply + _mintAmount <= 5000 , "NFTs granted for presale had been already minted ");

            }
        
        for( uint256 i = 1 ; i <= _mintAmount; i++){
            addressMintedBalance[msg.sender]++;
             _safeMint(msg.sender ,supply + i);
        }
}

    function OwnerMint(uint256 _mintAmount) public onlyOwner {
        uint256 supply = totalSupply();
        uint256 ownerMintedCount = addressMintedBalance[msg.sender];
        require (!paused);
        require (_mintAmount > 0);
        require (supply + _mintAmount <= maxMintAmount);
        require (_mintAmount + ownerMintedCount <= 150);



         for( uint256 i = 1 ; i <= _mintAmount; i++){
             _safeMint(msg.sender ,supply + i);
        }

    }

    function tokenOwned(address _owner) public view returns (uint256[] memory){
    
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for( uint i = 0 ; i <= ownerTokenCount; i++) {
    tokenIds[i] = tokenOfOwnerByIndex(_owner , i) ;
    }
    return tokenIds;
    
}

  function isWhitelisted(address _user) public view returns (bool) {
    for (uint i = 0; i < whitelistedAddresses.length; i++) {
      if (whitelistedAddresses[i] == _user) {
          return true;
      }
    }
    return false;
  }

   function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }
  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    
    if(revealed == false) {
        return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  //only owner
  function reveal() public onlyOwner {
      revealed = true;
  }
  
  function setNftPerAddressLimit(uint256 _limit) public onlyOwner {
    nftPerAddressLimit = _limit;
  }
  
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }
  
  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
  
  function setOnlyWhitelisted(bool _state) public onlyOwner {
    onlyWhitelisted = _state;
  }
  
  function whitelistUsers(address[] calldata _users) public onlyOwner {
    delete whitelistedAddresses;
    whitelistedAddresses = _users;
  }
 
  function withdraw() public payable onlyOwner {
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
  }


}
