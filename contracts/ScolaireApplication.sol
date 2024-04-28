// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";
//import "./strings.sol";
contract ScolaireApplication is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;
    //using strings for *;
    // State variables to store the last request ID, response, and error
    bytes32 public s_lastRequestId;
    bytes32 public s_lastFullfilledRequestId;
    bytes public s_lastResponse;
    bytes public s_lastError;
    
    string public s_lastAppNo;
    mapping(string => bool) public fulfilled;
    mapping(string => string) public checkResults;
    uint32 private s_recordCounter;


    struct StatusChange {
        uint time;
        string status;  
        string checkResult;
    }

    mapping(string => StatusChange[]) public statushistory;



    event StatusUpdate(address indexed _from, uint updateTime, string  appNo, string newStatus, string checkResult);

    // Function to update status
    function updateStatus(string memory appNo, string memory newStatus, string memory checkResult) public {
        // Push new status change to array
        uint updateTime =block.timestamp;
        statushistory[appNo].push(StatusChange(updateTime, newStatus, checkResult));

        // bytes memory tempEmptyStringTest = bytes(checkResult); // Uses memory
        // if (tempEmptyStringTest.length != 0) {
        //     // emptyStringTest is an empty string
        //     checkResults[appNo] = checkResult;
        // }
        emit StatusUpdate(msg.sender, updateTime, appNo,  newStatus, checkResult);
    }

    // Function to get full history for applicant
    function getHistory(string memory appNo) public view returns(StatusChange[] memory) {
        return statushistory[appNo];
    }


    // Custom error type
    error UnexpectedRequestID(bytes32 requestId);

    // Event to log responses
    event Response(
        bytes32 indexed requestId,
        string character,
        bytes response,
        bytes err
    );

    // Router address - Hardcoded 
    // Check to get the router address for your supported network https://docs.chain.link/chainlink-functions/supported-networks
    address router = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0; //sepoia
    //address router = 0x6E2dc0F9DB014aE19888F539E59285D2Ea04244C; //mumbai
    // JavaScript source code
    string source =
    "const email = args[0];"
    "const app_id = args[1];"
    "const url = args[2];"
    "const param = {'email': email,'app_id': app_id};"
    "const checkCertRequest = Functions.makeHttpRequest({"
    "url: url,"
    "method: 'POST',"
    "headers: {'content-Type': 'application/json',},"
    "timeout: 9000 ,"
    "data: param,});"
    "const checkCertResponse = await checkCertRequest;"
    "if (checkCertResponse.error) {"
    "console.log(checkCertResponse.error);"
    "console.log(checkCertResponse);"
    "throw Error(`Request failed:` + email +';' + app_id +';' + checkCertResponse.message);"
    "}"
    "const reqData = checkCertResponse.data;"
    "const result= reqData.result.trim();"
    "return Functions.encodeString(result);";


    //Callback gas limit
    uint32 gasLimit = 300000;

    // donID - Hardcoded for Mumbai
    // Check to get the donID for your supported network https://docs.chain.link/chainlink-functions/supported-networks
    bytes32 donID = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000; //sepolia
    //bytes32 donID = 0x66756e2d706f6c79676f6e2d6d756d6261692d31000000000000000000000000; //Mumbai
    // State variable to store the returned checkresult information
    string public s_checkresult;

    /**
     * @notice Initializes the contract with the Chainlink router address and sets the contract owner
     */
    constructor() FunctionsClient(router) ConfirmedOwner(msg.sender) {
        // address storageAddress = 0xD352Bc334bfbbcE34b5B44803E72Bf47203a625b;
        // s_recordCounter =0;
        // storageContract = AdmissionStorage(storageAddress);
    }

    /**
     * @notice Sends an HTTP request for checkresult information
     * @param subscriptionId The ID for the Chainlink subscription
     * @param args The arguments to pass to the HTTP request
     * @return requestId The ID of the request
     */
    function sendRequest(
        uint64 subscriptionId,
        string[] calldata args
    ) external onlyOwner returns (bytes32 requestId) {
        s_lastRequestId = bytes32(0);
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source); // Initialize the request with JS code
        if (args.length > 0) req.setArgs(args); // Set the arguments for the request
        s_lastAppNo = args[1];
        // Send the request and store the request ID
        s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );
        fulfilled[s_lastAppNo] = false;    //args[1] is the applNo

        s_lastFullfilledRequestId = bytes32(0);
        return s_lastRequestId;
    }

    /**
     * @notice Callback function for fulfilling a request
     * @param requestId The ID of the request to fulfill
     * @param response The HTTP response data
     * @param err Any errors from the Functions request
     */
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId); // Check if request IDs match
        }
        // Update the contract's state variables with the response and any errors
        s_lastResponse = response;
        // string memory temp = string(response);
        s_checkresult = string(response);
        // s_lastError = err;
        // //perform checing of program requirement
        // strings.slice memory s = temp.toSlice();
        // strings.slice memory delim = "#".toSlice();
        // string memory appNo = s.split(delim).toString();
 
        s_lastFullfilledRequestId = requestId;
        checkResults[s_lastAppNo] = s_checkresult;
        fulfilled[s_lastAppNo] = true;
        // s_temp_appno = stringToBytes32(applNo);
        
        //s_recordCounter ++;
        //storageIndex[requestId] = s_recordCounter;
       
        emit Response(requestId, s_checkresult, s_lastResponse, s_lastError);
    }
    function stringToBytes32(string memory str) public pure returns (bytes32) {
        bytes memory strBytes = bytes(str);
        require(strBytes.length <= 32, "String exceeds 32 bytes");

        bytes32 result;
        assembly {
            // Store the string bytes in memory
            let memPtr := add(strBytes, 32)
            // Convert the bytes to bytes32 and store the result
            result := mload(memPtr)
        }

        return result;
    }
   
 

}
