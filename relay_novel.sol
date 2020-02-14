pragma solidity >=0.5.0 <0.6.0;

contract relay_novel {
    
    address public owner;
    
    uint256 constant internal WRITE_AMOUNT = 1 * 10 ** 16; // 0.01 ETH
    // uint256 constant internal WRITE_AMOUNT = 5 * 10 ** 18; // 5.000 ETH
    
    
    
    address[] public parentAuthors;
    
    struct contentInfo {
        bytes32 rootHash;
        bytes32 parentHash;
        bytes32 left;
        bytes32 right;
        string content;
        address payable author;
        uint256 level;
        uint256 direction;  // 0 is first, 1 is left and 2 is right
        uint256 count;
    }
    
    mapping(bytes32 => contentInfo) public mContentInfo;
    
    bytes32[] rootHashes;
    
   constructor() public {
        owner = msg.sender;
    }
    
    //getter
    function getParentHash(bytes32 _hash) public view returns (bytes32) {
        return mContentInfo[_hash].parentHash;
    }
    
    function getRootHash(uint256 _id) public view returns (bytes32) {
        return rootHashes[_id];
    }
    
    function getContent(bytes32 hash) public view returns (string memory) {
        return mContentInfo[hash].content;
    }
    
    function getLevel(bytes32 hash) public view returns (uint256) {
        return mContentInfo[hash].level;
    }
    
    function getDirection(bytes32 hash) public view returns (uint256) {
        return mContentInfo[hash].direction;
    }
    
    function getAuthor(bytes32 hash) public view returns (address) {
        return mContentInfo[hash].author;
    }
    
    function getCount(bytes32 hash) public view returns (uint256) {
        return mContentInfo[hash].count;
    }
    
    function getLeft(bytes32 hash) public view returns (bytes32) {
        return mContentInfo[hash].left;
    }
    
    function getRight(bytes32 hash) public view returns (bytes32) {
        return mContentInfo[hash].right;
    }
    
    function firstWrite(string memory _content) public returns (bytes32){
        
         bytes32 hash = sha256(abi.encodePacked(_content));
        
        mContentInfo[hash].rootHash = hash; // duplicate warning
        mContentInfo[hash].content = _content;
        mContentInfo[hash].author = msg.sender;
        mContentInfo[hash].level = 1;
        mContentInfo[hash].count = 0;
        mContentInfo[hash].direction = 0;
        
        rootHashes.push(hash);
        return hash;`
    }
    
    

    
    function _write(bytes32 _rootHash, bytes32 _parentHash, string memory _content, uint256 _direction) private returns (bytes32){
         
        bytes32 hash = sha256(abi.encodePacked(_content));
        
        mContentInfo[hash].rootHash = _rootHash;
        mContentInfo[hash].parentHash = _parentHash;
        mContentInfo[hash].content = _content;
        mContentInfo[hash].author = msg.sender;
        mContentInfo[hash].level = mContentInfo[_parentHash].level+1;
        mContentInfo[hash].direction = _direction;
        mContentInfo[hash].count = 0;
        
        if(_direction == 1) {
            mContentInfo[_parentHash].left = hash;
        } else {
            mContentInfo[_parentHash].right = hash;
        }
     
        return hash;   
    }
    
    function writeAndDistribute(bytes32 _rootHash, bytes32 _parentHash, string memory _content, uint256 _direction) payable public returns(bytes32) {
        // check the proper ether is sent
        require(msg.value == WRITE_AMOUNT, "Not enough ETH");
        
        bytes32 hash = _write(_rootHash, _parentHash, _content, _direction);
        _distribute(hash);
        
        return hash;
    }
    
    address[] addressList;
    
    function _distribute(bytes32 hash) private {
            address[] memory tempAddrlist;
            addressList = tempAddrlist;
            
            bytes32 tmp = mContentInfo[hash].parentHash;
            uint256 value = WRITE_AMOUNT / (mContentInfo[hash].level-1);
            
            for (uint256 i = mContentInfo[hash].level-1; i > 0; i--) {
                mContentInfo[tmp].author.transfer(value);
                tmp = mContentInfo[tmp].parentHash;
            }
    }
    
    
}
