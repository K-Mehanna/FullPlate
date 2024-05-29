class RequestItem {
  final String title;
  final String location;
  final String address;
  final int quantity;
  final String size;
  final String category;
  final bool claimed;

  RequestItem({
    required this.title,
    required this.location,
    required this.address,
    required this.quantity,
    required this.size,
    required this.category,
    required this.claimed,
  });
}