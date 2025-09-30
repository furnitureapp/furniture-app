class Marketer {
  final String employeeId;
  final String name;
  final DateTime dob;
  final String address;
  final String idProof;
  final String? photo;
  final String phone;
  final String altPhone;
  final String zone;

  Marketer({
    required this.employeeId,
    required this.name,
    required this.dob,
    required this.address,
    required this.idProof,
    this.photo,
    required this.phone,
    required this.altPhone,
    required this.zone,
  });
}

List<Marketer> dummyMarketers = [
  Marketer(
    employeeId: "MKT001",
    name: "Hari Kumar",
    dob: DateTime(1990, 5, 12),
    address: "12, MG Road, Chennai",
    idProof: "ID001.pdf",
    photo: null,
    phone: "9000100001",
    altPhone: "9000200001",
    zone: "Chennai",
  ),
  Marketer(
    employeeId: "MKT002",
    name: "Muthu Raja",
    dob: DateTime(1988, 8, 22),
    address: "45, Park Street, Kolkata",
    idProof: "ID002.pdf",
    photo: null,
    phone: "9000100002",
    altPhone: "9000200002",
    zone: "Kolkata",
  ),
  Marketer(
    employeeId: "MKT003",
    name: "Anita Devi",
    dob: DateTime(1992, 3, 15),
    address: "78, Brigade Road, Bangalore",
    idProof: "ID003.pdf",
    photo: null,
    phone: "9000100003",
    altPhone: "9000200003",
    zone: "Bangalore",
  ),
  Marketer(
    employeeId: "MKT004",
    name: "Ravi Kumar",
    dob: DateTime(1985, 11, 10),
    address: "23, Nehru Street, Mumbai",
    idProof: "ID004.pdf",
    photo: null,
    phone: "9000100004",
    altPhone: "9000200004",
    zone: "Mumbai",
  ),
  Marketer(
    employeeId: "MKT005",
    name: "Sita Ram",
    dob: DateTime(1991, 7, 30),
    address: "56, Anna Nagar, Madurai",
    idProof: "ID005.pdf",
    photo: null,
    phone: "9000100005",
    altPhone: "9000200005",
    zone: "Madurai",
  ),
  Marketer(
    employeeId: "MKT006",
    name: "Vijay Kumar",
    dob: DateTime(1989, 2, 18),
    address: "34, Gandhi Street, Pune",
    idProof: "ID006.pdf",
    photo: null,
    phone: "9000100006",
    altPhone: "9000200006",
    zone: "Pune",
  ),
  Marketer(
    employeeId: "MKT007",
    name: "Meena Devi",
    dob: DateTime(1993, 9, 5),
    address: "12, Marina Beach, Chennai",
    idProof: "ID007.pdf",
    photo: null,
    phone: "9000100007",
    altPhone: "9000200007",
    zone: "Chennai",
  ),
  Marketer(
    employeeId: "MKT008",
    name: "Karthik Raja",
    dob: DateTime(1990, 12, 12),
    address: "78, Sector 5, Delhi",
    idProof: "ID008.pdf",
    photo: null,
    phone: "9000100008",
    altPhone: "9000200008",
    zone: "Delhi",
  ),
  Marketer(
    employeeId: "MKT009",
    name: "Divya Kumar",
    dob: DateTime(1987, 4, 20),
    address: "90, MG Road, Bangalore",
    idProof: "ID009.pdf",
    photo: null,
    phone: "9000100009",
    altPhone: "9000200009",
    zone: "Bangalore",
  ),
  Marketer(
    employeeId: "MKT010",
    name: "Arun Kumar",
    dob: DateTime(1992, 6, 25),
    address: "11, Park Lane, Kolkata",
    idProof: "ID010.pdf",
    photo: null,
    phone: "9000100010",
    altPhone: "9000200010",
    zone: "Kolkata",
  ),
];
