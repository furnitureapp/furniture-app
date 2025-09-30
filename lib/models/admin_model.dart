class Admin {
  final String employeeId;
  final String name;
  final DateTime dob;
  final String address;
  final String idProof;
  final String? photo; // optional
  final String phone;
  final String altPhone;

  Admin({
    required this.employeeId,
    required this.name,
    required this.dob,
    required this.address,
    required this.idProof,
    this.photo,
    required this.phone,
    required this.altPhone,
  });
}

List<Admin> dummyAdmins = [
  Admin(
    employeeId: "EMP001",
    name: "Hari Kumar",
    dob: DateTime(1990, 5, 12),
    address: "12, MG Road, Chennai",
    idProof: "ID001.pdf",
    photo: null,
    phone: "9000000011",
    altPhone: "9000000021",
  ),
  Admin(
    employeeId: "EMP002",
    name: "Muthu Raja",
    dob: DateTime(1988, 8, 22),
    address: "45, Park Street, Kolkata",
    idProof: "ID002.pdf",
    photo: null,
    phone: "9000000012",
    altPhone: "9000000022",
  ),
  Admin(
    employeeId: "EMP003",
    name: "Anita Devi",
    dob: DateTime(1992, 3, 15),
    address: "78, Brigade Road, Bangalore",
    idProof: "ID003.pdf",
    photo: null,
    phone: "9000000013",
    altPhone: "9000000023",
  ),
  Admin(
    employeeId: "EMP004",
    name: "Ravi Kumar",
    dob: DateTime(1985, 11, 10),
    address: "23, Nehru Street, Mumbai",
    idProof: "ID004.pdf",
    photo: null,
    phone: "9000000014",
    altPhone: "9000000024",
  ),
  Admin(
    employeeId: "EMP005",
    name: "Sita Ram",
    dob: DateTime(1991, 7, 30),
    address: "56, Anna Nagar, Madurai",
    idProof: "ID005.pdf",
    photo: null,
    phone: "9000000015",
    altPhone: "9000000025",
  ),
  Admin(
    employeeId: "EMP006",
    name: "Vijay Kumar",
    dob: DateTime(1989, 2, 18),
    address: "34, Gandhi Street, Pune",
    idProof: "ID006.pdf",
    photo: null,
    phone: "9000000016",
    altPhone: "9000000026",
  ),
  Admin(
    employeeId: "EMP007",
    name: "Meena Devi",
    dob: DateTime(1993, 9, 5),
    address: "12, Marina Beach, Chennai",
    idProof: "ID007.pdf",
    photo: null,
    phone: "9000000017",
    altPhone: "9000000027",
  ),
  Admin(
    employeeId: "EMP008",
    name: "Karthik Raja",
    dob: DateTime(1990, 12, 12),
    address: "78, Sector 5, Delhi",
    idProof: "ID008.pdf",
    photo: null,
    phone: "9000000018",
    altPhone: "9000000028",
  ),
  Admin(
    employeeId: "EMP009",
    name: "Divya Kumar",
    dob: DateTime(1987, 4, 20),
    address: "90, MG Road, Bangalore",
    idProof: "ID009.pdf",
    photo: null,
    phone: "9000000019",
    altPhone: "9000000029",
  ),
  Admin(
    employeeId: "EMP010",
    name: "Arun Kumar",
    dob: DateTime(1992, 6, 25),
    address: "11, Park Lane, Kolkata",
    idProof: "ID010.pdf",
    photo: null,
    phone: "9000000020",
    altPhone: "9000000030",
  ),
];
