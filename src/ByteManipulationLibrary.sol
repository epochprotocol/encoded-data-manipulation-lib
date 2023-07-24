// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.12;

import "forge-std/console2.sol";

library ByteManipulationLibrary {
    uint8 constant byteLength = 32;

    //position starts from zero
    function getFixedData(
        bytes calldata data,
        uint256 position
    ) public pure returns (bytes memory) {
        uint256 initialPosition = position * byteLength;
        uint256 endingPosition = initialPosition + byteLength;
        return data[initialPosition:endingPosition];
    }

    function getDynamicData(
        bytes calldata data,
        uint256 position
    ) public pure returns (bytes memory) {
        uint256 initialPosition = (position * byteLength);
        uint256 endingPosition = initialPosition + byteLength;
        uint256 dataPosition = uint256(
            bytes32(data[initialPosition:endingPosition])
        );

        uint256 dataStart = dataPosition;

        uint256 dataLengthEndPosition = dataStart + byteLength;

        uint256 length = uint256(
            bytes32(data[dataStart:dataLengthEndPosition])
        );
        bytes memory extractedData = new bytes(length);
        uint256 _start = dataLengthEndPosition;
        uint256 _end = _start + length;
        extractedData = data[_start:_end];
        return extractedData;
    }

    function getFixedSizeDynamicArrayData(
        bytes calldata data,
        uint256 position
    ) public pure returns (bytes[] memory) {
        uint256 _start;
        uint256 _end;
        uint256 offset;
        uint256 dataPosition;
        uint256 dataPositionEnd;
        uint256 anchor;

        {
            uint256 initialPosition = (position * byteLength);
            uint256 endingPosition = initialPosition + byteLength;
            dataPosition = uint256(
                bytes32(data[initialPosition:endingPosition])
            );
            anchor = dataPosition;
            dataPositionEnd = dataPosition + byteLength;
            offset = uint256(bytes32(data[dataPosition:dataPositionEnd]));
            _start = anchor + offset;
            _end = _start + byteLength;
        }
        uint256 arrayElements = uint256(offset / byteLength);
        bytes[] memory extractedData = new bytes[](arrayElements);
        {
            for (uint256 i = 0; i < arrayElements; i++) {
                uint256 elementLength = uint256(bytes32(data[_start:_end]));
                bytes memory element = bytes(data[_end:_end + elementLength]);
                extractedData[i] = bytes(element);
                dataPosition = dataPositionEnd;
                dataPositionEnd = dataPosition + byteLength;
                offset = uint256(bytes32(data[dataPosition:dataPositionEnd]));
                _start = anchor + offset;
                _end = _start + byteLength;
            }
        }
        return extractedData;
    }

    function getStaticArrayData(
        bytes calldata data,
        uint256 position
    ) public pure returns (bytes[] memory) {
        uint256 initialPosition = (position * byteLength);
        uint256 endingPosition = initialPosition + byteLength;
        uint256 dataPosition = uint256(
            bytes32(data[initialPosition:endingPosition])
        );

        uint256 dataStart = dataPosition;

        uint256 dataLengthEndPosition = dataStart + byteLength;

        uint256 length = uint256(
            bytes32(data[dataStart:dataLengthEndPosition])
        );
        bytes[] memory extractedData = new bytes[](length);
        uint256 _start = dataLengthEndPosition;
        uint256 _end = _start + byteLength;
        for (uint256 i = 0; i < length; i++) {
            extractedData[i] = data[_start:_end];
            _start = _end;
            _end = _start + byteLength;
        }
        return extractedData;
    }

    function getDynamicSizeDynamicArrayData(
        bytes calldata data,
        uint256 position
    ) public pure returns (bytes[] memory) {
        uint256 _start;
        uint256 _end;
        uint256 offset;
        uint256 dataPosition;
        uint256 dataPositionEnd;
        uint256 anchor;
        uint256 arrayElements;

        {
            uint256 initialPosition = (position * byteLength);
            uint256 endingPosition = initialPosition + byteLength;

            uint256 lengthValueStart = uint256(
                bytes32(data[initialPosition:endingPosition])
            );
            uint256 lengthValueEnd = lengthValueStart + byteLength;
            arrayElements = uint256(
                bytes32(data[lengthValueStart:lengthValueEnd])
            );
            dataPosition = lengthValueEnd;
            dataPositionEnd = dataPosition + byteLength;
            anchor = lengthValueEnd;
            offset = uint256(bytes32(data[dataPosition:dataPositionEnd]));
            _start = anchor + offset;
            _end = _start + byteLength;
        }
        bytes[] memory extractedData = new bytes[](arrayElements);
        {
            for (uint256 i = 0; i < arrayElements; i++) {
                uint256 elementLength = uint256(bytes32(data[_start:_end]));
                bytes memory element = bytes(data[_end:_end + elementLength]);
                extractedData[i] = bytes(element);
                dataPosition = dataPositionEnd;
                dataPositionEnd = dataPosition + byteLength;
                offset = uint256(bytes32(data[dataPosition:dataPositionEnd]));
                _start = anchor + offset;
                _end = _start + byteLength;
            }
        }
        return extractedData;
    }

    function overwriteStaticData(
        bytes calldata data,
        bytes32 dataToOverwrite,
        uint32 position
    ) public pure returns (bytes memory) {
        console2.logBytes(data);
        console2.logBytes32(dataToOverwrite);
        uint32 positionStart = position * byteLength;
        console2.log("positionStart", positionStart);
        uint32 positionEnd = positionStart + byteLength;
        console2.log("positionEnd", positionEnd);

        bytes calldata firstSplit = data[0:positionStart];
        console2.logBytes(firstSplit);
        bytes calldata secondSplit = data[positionEnd:data.length];
        console2.logBytes(secondSplit);

        bytes memory firstConcat = bytes.concat(firstSplit, dataToOverwrite);
        console2.logBytes(firstConcat);

        return bytes.concat(firstConcat, secondSplit);
    }
}
