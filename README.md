### Encoded Data Manipulation Library

This library is simply written to perform various operations that may be needed to perform on ABI encoed bytes calldata.
This library can be used for things like on-chain chain watchers.

Note: This is not Audited yet so use it only if you understand what you are doing.

#### To Install
<b>Hardhat or truffle</b> </br>
```
yarn add @epoch-protocol/encoded-data-manipulation-lib
or
npm install @epoch-protocol/encoded-data-manipulation-lib
import "@epoch-protocol/encoded-data-manipulation-lib/src/ByteManipulationLibrary.sol";
```
<b> Foundry </b>
```
forge install epochprotocol/encoded-data-manipulation-lib
```

#### Usage
You can use this library to do the following things:
- Get fixed sized data like address, uint, bytes32 from a given position(like 4th argument of the encoding).
- Get dynamic sized data like string or bytes from a given position.
- Get fixed sized arrays wit dynamic data like strings and bytes.
- Get fixed sized array of fixed sized data like address, uint8, bytes32.
- Get dynamic sized array for dynamic sized data like strings and bytes.
- Overwrite a fixed position/ overwrite some static sized data with some other static sized data, given the correct position.

