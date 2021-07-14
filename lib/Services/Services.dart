import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:taskdemo/Common/Classlist.dart';
import 'package:taskdemo/Common/constant.dart';

Dio dio = new Dio();

class Services {
  static Future<ResponseDataClass> responseHandler(
      {@required apiName, body}) async {
    String url = API_URL + "$apiName";
    var header = Options(
      headers: {
        "authorization": "" // set content-length
      },
    );
    var response;
    try {
      if (body == null) {
        response = await dio.post(url, options: header);
      } else {
        response = await dio.post(url, data: body);
      }
      print(apiName);
      print(body);
      if (response.statusCode == 200) {
        ResponseDataClass responseData = new ResponseDataClass(
            Message: "No Data", IsSuccess: false, Data: "");
        var data = response.data;

        responseData.Message = data["Message"];
        responseData.IsSuccess = data["IsSuccess"];
        responseData.Data = data["Data"];

        return responseData;
      } else {
        print("error ->" + response.data.toString());
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Catch error -> ${e.toString()}");
      throw Exception(e.toString());
    }
  }
}
