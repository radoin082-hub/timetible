import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function onTap;
  final bool isDarkMode;
  final Color color; // Add this line

  const CustomListTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isDarkMode,
    this.color = Colors.white, // Default color is white
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: color, // Use the passed color
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0.4,
            blurRadius: 3,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        onTap: onTap as void Function()?,
      ),
    );
  }
}
