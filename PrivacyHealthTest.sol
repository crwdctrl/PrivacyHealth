// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PrivacyHealth {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    // --- Data Structures ---
    struct Patient {
        string name;
        string record;
        bool exists;
    }

    struct Doctor {
        string name;
        string specialization;
        bool exists;
    }

    mapping(address => Patient) public patients;
    mapping(address => Doctor) public doctors;
    mapping(address => mapping(address => bool)) public accessList; // patient => doctor => access granted

    // --- Events ---
    event PatientAdded(address patient);
    event DoctorAdded(address doctor);
    event PermissionGranted(address patient, address doctor);
    event PermissionRevoked(address patient, address doctor);
    event RecordUpdated(address patient, address updatedBy);

    // --- Add Patients/Doctors ---
    function addPatient(address _patient, string memory _name, string memory _record) public onlyOwner {
        require(!patients[_patient].exists, "Patient exists");
        patients[_patient] = Patient({name: _name, record: _record, exists: true});
        emit PatientAdded(_patient);
    }

    function addDoctor(address _doctor, string memory _name, string memory _specialization) public onlyOwner {
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
        require(msg.sender == _patient || accessList[_patient][msg.sender], "Access denied");
        return patients[_patient].record;
    }

    // --- Update patient record ---
    function updatePatientRecord(address _patient, string calldata _newRecord) external {
        require(patients[_patient].exists, "Patient not found");
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

    // --- Test Dataset Loader ---
    function populateTestData() public onlyOwner {
        // Patients
        addPatient(0x1111111111111111111111111111111111111111, "Alice", "Age:30|Blood:A+|Diagnosis:Flu");
        addPatient(0x2222222222222222222222222222222222222222, "Bob", "Age:45|Blood:B-|Diagnosis:Diabetes");
        addPatient(0x3333333333333333333333333333333333333333, "Charlie", "Age:29|Blood:O+|Diagnosis:Asthma");
        addPatient(0x4444444444444444444444444444444444444444, "Diana", "Age:37|Blood:AB+|Diagnosis:Hypertension");
        addPatient(0x5555555555555555555555555555555555555555, "Eve", "Age:50|Blood:A-|Diagnosis:Arthritis");

        // Doctors
        addDoctor(0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa, "Dr. Smith", "Cardiology");
        addDoctor(0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB, "Dr. Johnson", "Endocrinology");
        addDoctor(0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC, "Dr. Lee", "Pulmonology");

        // Access permissions
        accessList[0x1111111111111111111111111111111111111111][0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa] = true;
        accessList[0x2222222222222222222222222222222222222222][0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB] = true;
        accessList[0x3333333333333333333333333333333333333333][0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC] = true;
    }
}

