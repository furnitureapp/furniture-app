class User {
  final String companyName;
  final String phone;
  final String gstNumber;
  final String address;
  final String email;
  final String username;

  User({
    required this.companyName,
    required this.phone,
    required this.gstNumber,
    required this.address,
    required this.email,
    required this.username,
  });
}

List<User> dummyUsers = [
  User(companyName: "ABC Pvt Ltd", phone: "9000000001", gstNumber: "GST123456A", address: "12, MG Road, Chennai", email: "abc@company.com", username: "abc_user1"),
  User(companyName: "XYZ Enterprises", phone: "9000000002", gstNumber: "GST123456B", address: "45, Park Street, Kolkata", email: "xyz@company.com", username: "xyz_user2"),
  User(companyName: "LMN Solutions", phone: "9000000003", gstNumber: "GST123456C", address: "78, Brigade Road, Bangalore", email: "lmn@company.com", username: "lmn_user3"),
  User(companyName: "PQR Tech", phone: "9000000004", gstNumber: "GST123456D", address: "23, Nehru Street, Mumbai", email: "pqr@company.com", username: "pqr_user4"),
  User(companyName: "Delta Corp", phone: "9000000005", gstNumber: "GST123456E", address: "56, Anna Nagar, Madurai", email: "delta@company.com", username: "delta_user5"),
  User(companyName: "Omega Ltd", phone: "9000000006", gstNumber: "GST123456F", address: "34, Gandhi Street, Pune", email: "omega@company.com", username: "omega_user6"),
  User(companyName: "Sigma Solutions", phone: "9000000007", gstNumber: "GST123456G", address: "12, Marina Beach, Chennai", email: "sigma@company.com", username: "sigma_user7"),
  User(companyName: "Alpha Tech", phone: "9000000008", gstNumber: "GST123456H", address: "78, Sector 5, Delhi", email: "alpha@company.com", username: "alpha_user8"),
  User(companyName: "Beta Corp", phone: "9000000009", gstNumber: "GST123456I", address: "90, MG Road, Bangalore", email: "beta@company.com", username: "beta_user9"),
  User(companyName: "Gamma Enterprises", phone: "9000000010", gstNumber: "GST123456J", address: "11, Park Lane, Kolkata", email: "gamma@company.com", username: "gamma_user10"),
];


List<User> approvedUsers = [
  dummyUsers[0],
  dummyUsers[2],
  dummyUsers[4],
  dummyUsers[6],
  dummyUsers[8],
];
