// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
    PrivacyHealth.sol -- simplified version with patient/doctor access

    - Owner adds patients and doctors
    - Patients grant/revoke access to doctors
    - Doctors can read/update patient records if authorized
*/

contract PrivacyHealth {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // --- Entities ---
    struct Patient {
        string name;
        string record; // simplified as a string; could be IPFS hash
        bool exists;
    }

    struct Doctor {
        string name;
        string specialization;
        bool exists;
    }

    mapping(address => Patient) public patients;
    mapping(address => Doctor) public doctors;

    // patient -> doctor -> has permission
    mapping(address => mapping(address => bool)) public accessList;

    // --- Events ---
    event PatientAdded(address indexed patient);
    event DoctorAdded(address indexed doctor);
    event PermissionGranted(address indexed patient, address indexed doctor);
    event PermissionRevoked(address indexed patient, address indexed doctor);
    event RecordUpdated(address indexed patient, address indexed updater);

    // --- Owner adds patients and doctors ---
    function addPatient(address _patient, string calldata _name, string calldata _record) external onlyOwner {
        require(!patients[_patient].exists, "Patient exists");
        patients[_patient] = Patient({name: _name, record: _record, exists: true});
        emit PatientAdded(_patient);
    }

    function addDoctor(address _doctor, string calldata _name, string calldata _specialization) external onlyOwner {
        require(!doctors[_doctor].exists, "Doctor exists");
        doctors[_doctor] = Doctor({name: _name, specialization: _specialization, exists: true});
        emit DoctorAdded(_doctor);
    }

    // --- Patient grants/revokes doctor access ---
    function grantAccess(address _doctor) external {
        require(patients[msg.sender].exists, "Not a patient");
        require(doctors[_doctor].exists, "Not a doctor");
        accessList[msg.sender][_doctor] = true;
        emit PermissionGranted(msg.sender, _doctor);
    }

    function revokeAccess(address _doctor) external {
        require(patients[msg.sender].exists, "Not a patient");
        require(accessList[msg.sender][_doctor], "No access to revoke");
        accessList[msg.sender][_doctor] = false;
        emit PermissionRevoked(msg.sender, _doctor);
    }

    // --- Read patient data ---
    function getPatientRecord(address _patient) external view returns (string memory) {
        require(patients[_patient].exists, "Patient not found");
        // patient themselves or doctor with access
        require(msg.sender == _patient || accessList[_patient][msg.sender], "Access denied");
        return patients[_patient].record;
    }

    // --- Update patient record ---
    function updatePatientRecord(address _patient, string calldata _newRecord) external {
        require(patients[_patient].exists, "Patient not found");
        // patient themselves or doctor with access
        require(msg.sender == _patient || accessList[_patient][msg.sender], "Access denied");
        patients[_patient].record = _newRecord;
        emit RecordUpdated(_patient, msg.sender);
    }

    // --- Search helpers ---
    function isPatient(address _addr) external view returns (bool) {
        return patients[_addr].exists;
    }

    function isDoctor(address _addr) external view returns (bool) {
        return doctors[_addr].exists;
    }

    function canDoctorAccess(address _patient, address _doctor) external view returns (bool) {
        return accessList[_patient][_doctor];
    }
}
