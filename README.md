# PrivacyHealth

**PrivacyHealth** is a simplified Ethereum smart contract for managing patient-doctor access to medical records with privacy and access control in mind. 

This contract allows:  
- The **contract owner** to register new patients and doctors.  
- **Patients** to grant or revoke doctors' permission to view or update their medical records.  
- **Doctors** to read or update records only if authorized.  
- **Basic lookup** of patients and doctors by address.

> This is a **prototype** for testing in Remix. Patient data is stored as plaintext strings; for production, consider encrypting or storing off-chain (e.g., IPFS).

---

## Features

1. **Owner-managed entities**: Add new patients and doctors.  
2. **Patient-controlled access**: Patients can grant and revoke doctor permissions.  
3. **Doctor record access**: Authorized doctors can view or update patient records.  
4. **Simple lookup functions**: Verify if an address is a patient or doctor, and check doctor permissions.  
5. **Event logging**: Tracks all actions for testing and audit purposes.  

---

## Contract Functions

### Owner Functions
- `addPatient(address _patient, string calldata _name, string calldata _record)`  
- `addDoctor(address _doctor, string calldata _name, string calldata _specialization)`

### Patient Functions
- `grantAccess(address _doctor)`  
- `revokeAccess(address _doctor)`  

### Doctor Functions
- `getPatientRecord(address _patient)`  
- `updatePatientRecord(address _patient, string calldata _newRecord)`  

### Public/View Functions
- `isPatient(address _addr)`  
- `isDoctor(address _addr)`  
- `canDoctorAccess(address _patient, address _doctor)`  

---

## Getting Started

1. Open [Remix IDE](https://remix.ethereum.org/) in your browser.  
2. Create a new Solidity file `PrivacyHealth.sol` and paste the contract code.  
3. Compile with Solidity `^0.8.19`.  
4. Deploy using **JavaScript VM** for local testing, or connect MetaMask for testnets.  
5. Use the **Deploy & Run Transactions** panel to interact with the contract functions.

---

## Testing with Sample Data

You can simulate patients and doctors using a small dataset (recommended size for initial testing):  
- **5–10 patients**  
- **3–5 doctors**  
- Each patient has 1–3 records  
- Each patient grants access to 1–2 doctors  

Example flow:  
1. Owner adds patients and doctors.  
2. Patients grant access to doctors.  
3. Doctors read or update patient records.  
4. Patients revoke access.  
5. Verify access control using `canDoctorAccess`.

> Tip: For automation, generate random Ethereum addresses for patients/doctors and use a JSON file or script to populate the contract in Remix.

---

## License

MIT License. Free to use, modify, and adapt for learning or prototyping purposes.

---

## Notes

- This is a **prototype**, designed for **educational and testing purposes**.  
- Patient records are stored **on-chain as plaintext**. Use encryption or off-chain storage for real data.  
- Access control is enforced **via Solidity mappings**. No off-chain server is required.  
