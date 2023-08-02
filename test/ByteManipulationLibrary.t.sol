// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

import "../src/ByteManipulationLibrary.sol";

contract ByteManipulationLibraryTest is Test {
    using ByteManipulationLibrary for bytes;

    address[] addressArray;
    string[] testStrArray;
    bytes[] testBytesArray;

    function testExtractingFixedSizeData() public {
        bytes memory testData = abi.encode(1, 2, 3);
        bytes32 extractedData = this.extractFixedSizedData(testData, 1);
        assertEq(uint256(bytes32(extractedData)), 2);
    }

    function testExtractingDynamicDataString() public {
        bytes memory testData = abi.encode(1, "abcd", 3);
        bytes memory extractedData = this.extractDynamicData(testData, 1);
        assertEq(string(extractedData), "abcd");
    }

    function testExtractingDynamicDataBytes() public {
        bytes memory testData = abi.encode(1, "abcd", 3, new bytes(0x123));
        bytes memory extractedData = this.extractDynamicData(testData, 3);
        assertEq(extractedData, new bytes(0x123));
    }

    function testExtractingFixedSizeDynamicDataStringArray() public {
        string[4] memory fixedSizeTestString = ["abc", "cdf", "ghi", "jkl"];

        bytes memory testData = abi.encode(1, "abc", 3, fixedSizeTestString);
        bytes[] memory extractedData = this.extractFixedSizeDynamicArrayData(
            testData,
            3
        );
        assertEq(extractedData.length, 4);
        for (uint8 i = 0; i < extractedData.length; i++) {
            assertEq(string(extractedData[i]), fixedSizeTestString[i]);
        }
    }

    function testExtractingFixedSizeDynamicDataBytesArray() public {
        bytes[4] memory fixedSizeTestBytes = [
            bytes("A"),
            bytes("B"),
            bytes("C"),
            bytes("D")
        ];
        bytes memory testData = abi.encode(1, "abcd", fixedSizeTestBytes, 4);
        bytes[] memory extractedData = this.extractFixedSizeDynamicArrayData(
            testData,
            2
        );
        assertEq(extractedData.length, 4);

        for (uint8 i = 0; i < extractedData.length; i++) {
            assertEq(extractedData[i], fixedSizeTestBytes[i]);
        }
    }

    function testExtractingDynamicSizeDynamicDataStringArray() public {
        testStrArray = ["abc", "cdf", "ghi", "jkl"];

        bytes memory testData = abi.encode(1, "abc", 3, testStrArray);
        bytes[] memory extractedData = this.extractDynamicSizeDynamicArrayData(
            testData,
            3
        );
        assertEq(extractedData.length, 4);
        for (uint8 i = 0; i < extractedData.length; i++) {
            assertEq(string(extractedData[i]), testStrArray[i]);
        }
    }

    function testExtractingDynamicSizeDynamicDataBytesArray() public {
        testBytesArray = [bytes("A"), bytes("B"), bytes("C"), bytes("D")];
        bytes memory testData = abi.encode(1, "abcd", testBytesArray, 4);
        bytes[] memory extractedData = this.extractDynamicSizeDynamicArrayData(
            testData,
            2
        );
        assertEq(extractedData.length, 4);

        for (uint8 i = 0; i < extractedData.length; i++) {
            assertEq(extractedData[i], testBytesArray[i]);
        }
    }

    function testExtractingStaticDataAddressArray() public {
        addressArray.push(address(this));
        addressArray.push(address(this));

        bytes memory testData = abi.encode(1, "abcd", addressArray, 69);
        bytes[] memory extractedData = this.extractStaticDataArrayData(
            testData,
            2
        );
        address[] memory outputArray = new address[](extractedData.length);
        for (uint8 i = 0; i < extractedData.length; i++) {
            outputArray[i] = bytesToAddress(extractedData[i]);
        }
        assertEq(addressArray, outputArray);
    }

    function testOverwritesStaticDataWithSignature() public {
        addressArray.push(address(this));
        addressArray.push(address(this));
        bytes4 selector = bytes4(
            keccak256(bytes("executeEpoch(uint256, address, uint256, bytes)"))
        );
        bytes memory testData = abi.encodeWithSelector(
            selector,
            1,
            "abcd",
            addressArray,
            69
        );
        bytes32 dataToOverwrite = bytes32(abi.encode(2));
        bytes memory updateData = this.overwriteFixedLengthDataWithSignature(
            testData,
            dataToOverwrite,
            2
        );
        bytes memory updatedBytesWithoutSignature = this
            .dataFromSignauteEncodedBytes(updateData);
        (, , uint8 third, ) = abi.decode(
            updatedBytesWithoutSignature,
            (uint8, string, uint8, uint8)
        );
        assertEq(third, 2);
    }

    function testOverwritesStaticData() public {
        addressArray.push(address(this));
        addressArray.push(address(this));

        bytes memory testData = abi.encode(1, "abcd", addressArray, 69);
        bytes32 dataToOverwrite = bytes32(abi.encode(2));
        bytes memory updateData = this.overwriteFixedLengthDataWithoutSignature(
            testData,
            dataToOverwrite,
            2
        );
        (, , uint8 third, ) = abi.decode(
            updateData,
            (uint8, string, uint8, uint8)
        );
        assertEq(third, 2);
    }

    function extractFixedSizedData(
        bytes calldata data,
        uint32 position
    ) public pure returns (bytes32) {
        return data.getFixedData(position);
    }

    function extractDynamicData(
        bytes calldata data,
        uint32 position
    ) public pure returns (bytes memory) {
        return data.getDynamicData(position);
    }

    function extractFixedSizeDynamicArrayData(
        bytes calldata data,
        uint32 position
    ) public pure returns (bytes[] memory) {
        return data.getFixedSizeDynamicArrayData(position);
    }

    function extractDynamicSizeDynamicArrayData(
        bytes calldata data,
        uint32 position
    ) public pure returns (bytes[] memory) {
        return data.getDynamicSizeDynamicArrayData(position);
    }

    function extractStaticDataArrayData(
        bytes calldata data,
        uint32 position
    ) public pure returns (bytes[] memory) {
        return data.getStaticArrayData(position);
    }

    function overwriteFixedLengthDataWithSignature(
        bytes calldata data,
        bytes32 dataToOverwrite,
        uint32 position
    ) public pure returns (bytes memory) {
        return data.overwriteStaticDataWithSignature(dataToOverwrite, position);
    }

    function overwriteFixedLengthDataWithoutSignature(
        bytes calldata data,
        bytes32 dataToOverwrite,
        uint32 position
    ) public pure returns (bytes memory) {
        return
            data.overwriteStaticDataWithoutSignature(dataToOverwrite, position);
    }

    function dataFromSignauteEncodedBytes(
        bytes calldata data
    ) public pure returns (bytes calldata) {
        return data[4:];
    }

    function bytesToAddress(
        bytes memory bys
    ) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 32))
        }
    }
}
