import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../app/app_constants.dart';
import '../app/app_state.dart';
import '../dto/user_dto.dart';
import '../router/router.dart';

class Settings extends StatelessWidget {
  const Settings({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.lightBlue,
        title: const Text(
          'Settings',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  appState.logout();
                },
                child: const Text('Log Out'),
              ),
              ElevatedButton(
                onPressed: () => appState.currentAction = PageAction(
                  state: PageState.addPage,
                  page: ScanQRCodePageConfig,
                ),
                child: const Text('Scan QR Code'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // TODO:
                    // https://www.bezkoder.com/dart-flutter-parse-json-string-array-to-object-list/
                    final response = await Dio()
                        .get('${AppConstants.kuartzo.apiServerBaseUrl}/users/1',
                            options: Options(
                              contentType: 'application/json',
                              headers: {
                                'Authorization':
                                    'Bearer ${appState.oAuthResponse?.idToken}'
                              },
                            ));
                    final user = UserDto.fromJson(response.data);
                    print('${user.first_name} ${user.last_name}');
                    Fluttertoast.showToast(
                      msg: '${user.first_name} ${user.last_name}',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.grey,
                      // textColor: Colors.white,
                      // fontSize: 16.0
                    );
                  } on DioError catch (ex) {
                    if (ex.type == DioErrorType.connectTimeout) {
                      throw Exception('Connection Timeout Exception');
                    }
                    // throw Exception(ex.message);
                    Fluttertoast.showToast(
                      msg: '${ex.message}',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      // fontSize: 16.0
                    );
                  }
                },
                child: const Text('Request Api'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
