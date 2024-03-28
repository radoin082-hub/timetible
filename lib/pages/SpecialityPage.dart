import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timo/Lang/Language.dart';
import 'package:timo/Services/cls.dart';
import 'package:timo/pages/LevelPage.dart';

class SpecialityPage extends StatefulWidget {
  final String departmentId;

  SpecialityPage({required this.departmentId});

  @override
  _SpecialityPageState createState() => _SpecialityPageState();
}

class _SpecialityPageState extends State<SpecialityPage> {
  List specialities = [];
  bool isLoading = true; // Add a loading state
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchSpeciality();
  }

  fetchSpeciality() async {
    try {
      final response = await dio.get('https://num.univ-biskra.dz/psp/pspapi/specialty?department=${widget.departmentId}&semester=2&key=appmob');
      final data = json.decode(response.data);
      setState(() {
        specialities = data;
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Specialities'),
      ),
      body: isLoading
          ? ListView.builder(
              itemCount: 10, // Arbitrarily chosen number for shimmer lines
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
            )
          : ListView.builder(
              itemCount: specialities.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(specialities[index]['Nom_spec']),
                  onTap: () {
                    Provider.of<TimetableData>(context, listen: false).setSpecialtyId(specialities[index]['id_specialty']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LevelPage(id_specialty: specialities[index]['id_specialty']),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}