import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timo/Lang/Language.dart';
import 'dart:convert';
import 'package:timo/pages/DepartmentsPage.dart';
import 'package:shimmer/shimmer.dart'; // Import Shimmer package

class FacultiesPage extends StatefulWidget {
  @override
  _FacultiesPageState createState() => _FacultiesPageState();
}

class _FacultiesPageState extends State<FacultiesPage> {
  List faculties = [];
  Dio dio = Dio();
  bool isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    fetchFaculties();
  }

  fetchFaculties() async {
    try {
      final response =
          await dio.get('http://num.univ-biskra.dz/psp/pspapi/faculty?key=appmob');
      print('Response from Your_API_Endpoint: ${response.data}');
      final data = json.decode(response.data);

      setState(() {
        faculties = data;
        isLoading = false; // Set loading to false once data is fetched
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false; // Ensure loading is set to false on error as well
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFrench = Provider.of<Language>(context).isFrench;

    return Scaffold(
      appBar: AppBar(
        title: Text('Faculties'),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              Provider.of<Language>(context, listen: false).toggleLanguage();
            },
          ),
        ],
      ),
      body: isLoading
          ? _buildLoadingIndicator()
          : _buildFacultyList(isFrench),
    );
  }

  Widget _buildLoadingIndicator() {
    return ListView.builder(
      itemCount: 10, // Number of shimmer lines
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          height: 20.0,
          width: double.infinity,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFacultyList(bool isFrench) {
    return ListView.builder(
      itemCount: faculties.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 4.0,
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(
                isFrench ? faculties[index]['name_fac'] : faculties[index]['name_fac_ar']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DepartmentsPage(facultyId: faculties[index]['id_fac']),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
