// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.12;

library ByteManipulationLibrary {
    uint8 constant byteLength = 32;

    //position starts from zero
    /**
    @notice extract static length data like uint256, address
    @param data abi encoded bytes calldata
    @param position position of the data to be extracted
    @return returns bytes of extracted data.
    **/
    function getFixedData(
        bytes calldata data,
        uint256 position
    ) internal pure returns (bytes32) {
        uint256 initialPosition = position * byteLength;
        uint256 endingPosition = initialPosition + byteLength;
        return bytes32(data[initialPosition:endingPosition]);
    }

    /**
    @notice extract dynamic length data like string and bytes
    @param data abi encoded bytes calldata
    @param position position of the data to be extracted
    @return returns bytes of extracted data.
    **/
    function getDynamicData(
        bytes calldata data,
        uint256 position
    ) internal pure returns (bytes memory) {
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

    /**
    @notice extract a dynamic length array of static sized data like uint256, address etc.
    @param data abi encoded bytes calldata
    @param position position of the data to be extracted
    @return returns bytes of extracted data.
    **/
    function getFixedSizeDynamicArrayData(
        bytes calldata data,
        uint256 position
    ) internal pure returns (bytes[] memory) {
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

    /**
    @notice extract a static sized array of static sized data like uint256, address.
    @param data abi encoded bytes calldata
    @param position position of the data to be extracted
    @return returns bytes of extracted data.
    **/
    function getStaticArrayData(
        bytes calldata data,
        uint256 position
    ) internal pure returns (bytes[] memory) {
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

    /**
    @notice extract a dynamic sized array of dynamic sized data.
    @param data abi encoded bytes calldata
    @param position position of the data to be extracted
    @return returns bytes of extracted data.
    **/
    function getDynamicSizeDynamicArrayData(
        bytes calldata data,
        uint256 position
    ) internal pure returns (bytes[] memory) {
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

    /**
    @notice overwrite static data over a specific position in bytes encoded data with signature
    @param data abi encoded bytes calldata
    @param dataToOverwrite data to place at a given position
    @param position position of the data to be extracted
    @return returns bytes of extracted data.
    **/
    function overwriteStaticDataWithSignature(
        bytes calldata data,
        bytes32 dataToOverwrite,
        uint32 position
    ) internal pure returns (bytes memory) {
        uint32 positionStart = 4 + (position * byteLength);
        uint32 positionEnd = positionStart + byteLength;
        bytes calldata firstSplit = data[0:positionStart];
        bytes calldata secondSplit = data[positionEnd:data.length];
        bytes memory firstConcat = bytes.concat(firstSplit, dataToOverwrite);
        return bytes.concat(firstConcat, secondSplit);
    }

    /**
    @notice overwrite static data over a specific position in bytes encoded data without signature
    @param data abi encoded bytes calldata
    @param dataToOverwrite data to place at a given position
    @param position position of the data to be extracted
    @return returns bytes of extracted data.
    **/
    function overwriteStaticDataWithoutSignature(
        bytes calldata data,
        bytes32 dataToOverwrite,
        uint32 position
    ) internal pure returns (bytes memory) {
        uint32 positionStart = (position * byteLength);
        uint32 positionEnd = positionStart + byteLength;
        bytes calldata firstSplit = data[0:positionStart];
        bytes calldata secondSplit = data[positionEnd:data.length];
        bytes memory firstConcat = bytes.concat(firstSplit, dataToOverwrite);
        return bytes.concat(firstConcat, secondSplit);
    }
}
