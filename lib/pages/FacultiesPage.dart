import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:timo/Feautres/CustomSpecialtySearchDelegate.dart';
import 'package:timo/Lang/Language.dart';
import 'package:timo/Management/SharedPreferences.dart';
import 'package:timo/pages/DepartmentsPage.dart';

class FacultiesPage extends StatefulWidget {
  @override
  _FacultiesPageState createState() => _FacultiesPageState();
}

class _FacultiesPageState extends State<FacultiesPage> {
  final GlobalKey _lanKey = GlobalKey();
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _facKey = GlobalKey();

  List faculties = [];
  Dio dio = Dio();
  bool isLoading = true;
    bool isArabic = false; // Added state variable to track language


bool _isFirstLaunch = true;

void initState() {
    super.initState();
    Prefs.init().then((_) {
        print("Is first run from FacultiesPage: ${Prefs.isFirstRun}");
        if (Prefs.isFirstRun) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
                ShowCaseWidget.of(context)?.startShowCase([_lanKey, _searchKey, _facKey]);
            });
        }
    });
    fetchFaculties();
}

 
void checkFirstRunAndShowcase() async {
    await Prefs.init();
    print("Showcase check - Is first run: ${Prefs.isFirstRun}");

    if (Prefs.isFirstRun) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
            ShowCaseWidget.of(context)?.startShowCase([_lanKey, _searchKey, _facKey]);
            // Optionally, consider setting it false here after showing, to avoid re-showing if not needed.
        });
    }
}

  void checkFirstLaunch() async {
    _isFirstLaunch = await PreferencesManager.isFirstLoad();
    if (_isFirstLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context)?.startShowCase([_lanKey, _searchKey, _facKey]);
        PreferencesManager.setFirstLoadComplete();
      });
    }
  }

  fetchFaculties() async {
    try {
      final response = await dio.get('http://num.univ-biskra.dz/psp/pspapi/faculty?key=appmob');
     print('this is my data $response.data');
      final data = json.decode(response.data);
      setState(() {
        faculties = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

@override
Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Faculties'),
            actions: [
                Showcase(
                    description: 'Change the app language',
                    title: 'Language',
                    key: _lanKey,
                    child: IconButton(
                        icon: Icon(Icons.language),
                        onPressed: () {
                            setState(() {
                                isArabic = !isArabic;
                            });
                            Provider.of<Language>(context, listen: false).toggleLanguage();
                        },
                    ),
                ),
                Showcase(
                    description: 'Search for a specialty',
                    title: 'Search',
                    key: _searchKey,
                    child: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                            List<String> departmentIds = List.generate(32, (index) => (index + 1).toString());
                            showSearch(context: context, delegate: CustomSpecialtySearchDelegate(departmentIds));
                        },
                    ),
                ),
            ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: faculties.length,
                itemBuilder: (context, index) {
                    Widget listItem = ListTile(
                        leading: Icon(Icons.school, color: Theme.of(context).primaryColor),
                        title: Text(
                            isArabic ? faculties[index]['name_fac_ar'] : faculties[index]['name_fac'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        
                        trailing: Icon(Icons.arrow_forward, color: Theme.of(context).primaryColor),
                        onTap: () async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.setString('lastFacultyId', faculties[index]['id_fac']);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => DepartmentsPage(facultyId: faculties[index]['id_fac']),
                            ));
                        },
                    );

                    // Wrap the listItem with Showcase only at index 3
                    if (index == 2) {
                        return Showcase(
                            key: _facKey,
                            description: 'Tap on your faculty to view its departments.',
                            title: 'Faculty List',
                            child: listItem,
                        );
                    }
                    return listItem;
                },
            ),
    );
}

}
class Prefs {
    static SharedPreferences? _prefs;

    static Future<void> init() async {
        _prefs ??= await SharedPreferences.getInstance();
    }

    static bool get isFirstRun => _prefs?.getBool('first_run') ?? true;
  

static Future<void> setFirstRun(bool value) async {
    print("Setting isFirstRun to $value");
    await _prefs?.setBool('first_run', value);
}

  
    static String? getIdSpecialty() => _prefs?.getString('id_specialty');
    static Future<void> setIdSpecialty(String value) async {
        await _prefs?.setString('id_specialty', value);
    }
}
