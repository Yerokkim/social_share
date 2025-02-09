import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

enum ShareMediaType {
  image,
  video,
}

class SocialShare {
  static const MethodChannel _channel = const MethodChannel('social_share');

  static Future<String> shareInstagramStory({
    @required String mediaPath,
    @required String backgroundTopColor,
    @required String backgroundBottomColor,
    @required String attributionURL,
    ShareMediaType mediaType = ShareMediaType.image,
  }) async {
    Map<String, dynamic> args;

    final mediaTypeString = mediaType.toString().split('.').last;

    if (Platform.isIOS) {
      args = <String, dynamic>{
        "mediaPath": mediaPath,
        "mediaType": mediaTypeString,
        "backgroundTopColor": backgroundTopColor,
        "backgroundBottomColor": backgroundBottomColor,
        "attributionURL": attributionURL
      };
    } else {
      final tempDir = await getTemporaryDirectory();

      File file = File(mediaPath);
      Uint8List bytes = file.readAsBytesSync();
      var stickerdata = bytes.buffer.asUint8List();
      String stickerAssetName = 'stickerAsset.png';
      final Uint8List stickerAssetAsList = stickerdata;
      final stickerAssetPath = '${tempDir.path}/$stickerAssetName';
      file = await File(stickerAssetPath).create();
      file.writeAsBytesSync(stickerAssetAsList);
      args = <String, dynamic>{
        "media": stickerAssetName,
        "type": mediaTypeString,
        "backgroundTopColor": backgroundTopColor,
        "backgroundBottomColor": backgroundBottomColor,
        "attributionURL": attributionURL
      };
    }

    final String response = await _channel.invokeMethod('shareInstagramStory', args);

    return response;
  }

  static Future<String> shareInstagramStoryWithSticker({
    @required String mediaPath,
    @required String stickerPath,
    @required String backgroundTopColor,
    @required String backgroundBottomColor,
    @required String attributionURL,
    ShareMediaType mediaType = ShareMediaType.image,
  }) async {
    Map<String, dynamic> args;

    final mediaTypeString = mediaType.toString().split('.').last;

    if (Platform.isIOS) {
      args = <String, dynamic>{
        "stickerPath": stickerPath,
        "mediaPath": mediaPath,
        "mediaType": mediaTypeString,
        "backgroundTopColor": backgroundTopColor,
        "backgroundBottomColor": backgroundBottomColor,
        "attributionURL": attributionURL
      };
    } else {
      final tempDir = await getTemporaryDirectory();

      File file = File(stickerPath);
      Uint8List bytes = file.readAsBytesSync();
      var stickerdata = bytes.buffer.asUint8List();
      String stickerAssetName = 'stickerAsset.png';
      final Uint8List stickerAssetAsList = stickerdata;
      final stickerAssetPath = '${tempDir.path}/$stickerAssetName';
      file = await File(stickerAssetPath).create();
      file.writeAsBytesSync(stickerAssetAsList);

      File mediaFile = File(mediaPath);
      Uint8List mediaFileData = mediaFile.readAsBytesSync();
      String mediaAssetName = 'backgroundAsset.jpg';
      final backgroundAssetPath = '${tempDir.path}/$mediaAssetName';
      File backgroundFile = await File(backgroundAssetPath).create();
      backgroundFile.writeAsBytesSync(mediaFileData);

      args = <String, dynamic>{
        "sticker": stickerAssetName,
        "media": mediaAssetName,
        "type": mediaTypeString,
        "backgroundTopColor": backgroundTopColor,
        "backgroundBottomColor": backgroundBottomColor,
        "attributionURL": attributionURL,
      };
    }

    final String response = await _channel.invokeMethod('shareInstagramStory', args);

    return response;
  }

  static Future<String> shareFacebookStory(String imagePath, String backgroundTopColor,
      String backgroundBottomColor, String attributionURL,
      {String appId}) async {
    Map<String, dynamic> args;
    if (Platform.isIOS) {
      args = <String, dynamic>{
        "stickerImage": imagePath,
        "backgroundTopColor": backgroundTopColor,
        "backgroundBottomColor": backgroundBottomColor,
        "attributionURL": attributionURL,
      };
    } else {
      File file = File(imagePath);
      Uint8List bytes = file.readAsBytesSync();
      var stickerdata = bytes.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      String stickerAssetName = 'stickerAsset.png';
      final Uint8List stickerAssetAsList = stickerdata;
      final stickerAssetPath = '${tempDir.path}/$stickerAssetName';
      file = await File(stickerAssetPath).create();
      file.writeAsBytesSync(stickerAssetAsList);
      args = <String, dynamic>{
        "stickerImage": stickerAssetName,
        "backgroundTopColor": backgroundTopColor,
        "backgroundBottomColor": backgroundBottomColor,
        "attributionURL": attributionURL,
        "appId": appId
      };
    }
    final String response = await _channel.invokeMethod('shareFacebookStory', args);
    return response;
  }

  static Future<String> shareTwitter(String captionText,
      {List<String> hashtags, String url, String trailingText}) async {
    Map<String, dynamic> args;
    String modifiedUrl;
    if (Platform.isAndroid) {
      modifiedUrl = Uri.parse(url).toString().replaceAll('#', "%23");
    } else {
      modifiedUrl = Uri.parse(url).toString();
    }
    if (hashtags != null && hashtags.isNotEmpty) {
      String tags = "";
      hashtags.forEach((f) {
        tags += ("%23" + f.toString() + " ").toString();
      });
      args = <String, dynamic>{
        "captionText": Uri.parse(captionText + "\n" + tags.toString()).toString(),
        "url": modifiedUrl,
        "trailingText": Uri.parse(trailingText).toString()
      };
    } else {
      args = <String, dynamic>{
        "captionText": Uri.parse(captionText + " ").toString(),
        "url": modifiedUrl,
        "trailingText": Uri.parse(trailingText).toString()
      };
    }
    print('hello');
    final String version = await _channel.invokeMethod('shareTwitter', args);
    return version;
  }

  static Future<String> shareSms(String message, {String url, String trailingText}) async {
    Map<String, dynamic> args;
    if (Platform.isIOS) {
      if (url == null) {
        args = <String, dynamic>{
          "message": Uri.parse(message).toString(),
        };
      } else {
        args = <String, dynamic>{
          "message": Uri.parse(message + " ").toString(),
          "urlLink": Uri.parse(url).toString(),
          "trailingText": Uri.parse(trailingText).toString()
        };
      }
    } else if (Platform.isAndroid) {
      args = <String, dynamic>{
        "message": message + url + trailingText,
      };
    }
    final String version = await _channel.invokeMethod('shareSms', args);
    return version;
  }

  static Future<bool> copyToClipboard(content) async {
    final Map<String, String> args = <String, String>{"content": content.toString()};
    final bool response = await _channel.invokeMethod('copyToClipboard', args);
    return response;
  }

  static Future<bool> shareOptions(String contentText, {String imagePath}) async {
    Map<String, dynamic> args;
    if (Platform.isIOS) {
      args = <String, dynamic>{"image": imagePath, "content": contentText};
    } else {
      if (imagePath != null) {
        File file = File(imagePath);
        Uint8List bytes = file.readAsBytesSync();
        var imagedata = bytes.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        String imageName = 'stickerAsset.png';
        final Uint8List imageAsList = imagedata;
        final imageDataPath = '${tempDir.path}/$imageName';
        file = await File(imageDataPath).create();
        file.writeAsBytesSync(imageAsList);
        args = <String, dynamic>{"image": imageName, "content": contentText};
      } else {
        args = <String, dynamic>{"image": imagePath, "content": contentText};
      }
    }
    final bool version = await _channel.invokeMethod('shareOptions', args);
    return version;
  }

  static Future<String> shareWhatsapp(String content) async {
    final Map<String, dynamic> args = <String, dynamic>{"content": content};
    final String version = await _channel.invokeMethod('shareWhatsapp', args);
    return version;
  }

  static Future<Map> checkInstalledAppsForShare() async {
    final Map apps = await _channel.invokeMethod('checkInstalledApps');
    return apps;
  }

  static Future<String> shareTelegram(String content) async {
    final Map<String, dynamic> args = <String, dynamic>{"content": content};
    final String version = await _channel.invokeMethod('shareTelegram', args);
    return version;
  }

  // static Future<String> shareSlack() async {
  //   final String version = await _channel.invokeMethod('shareSlack');
  //   return version;
  // }
}
