import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTDataProvider extends ChangeNotifier {
  final MqttServerClient client;
  List<String> _messages = [];
  bool _isLoading = true;
  String? _error;

  MQTTDataProvider({required this.client}) {
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final mqttMessages = c ?? [];
      _messages = mqttMessages
          .map((message) => MqttPublishPayload.bytesToStringAsString(
              (message.payload as MqttPublishMessage).payload.message))
          .toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  List<String> get messages => _messages;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get hasError => _error != null;
}