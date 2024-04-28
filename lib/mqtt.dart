import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

Future<MqttServerClient> connect() async {
  const String topic = "your topic";
  const String brokerUrl = "your broker url";
  final clientId = await generateClientId();
  final client = MqttServerClient.withPort(brokerUrl, clientId, 1883);
  client.keepAlivePeriod = 30;
  client.autoReconnect = true;

  await client.connect().onError((error, stackTrace) {
    developer.log("error -> $error");
    return null;
  });

  client.onConnected = () {
    developer.log('MQTT connected');
  };

  client.onDisconnected = () {
    developer.log('MQTT disconnected');
  };

  client.onSubscribed = (String topic) {
    developer.log('MQTT subscribed to $topic');
  };

  developer.log("Connected with client ID: $clientId");

  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    client.subscribe(topic, MqttQos.atMostOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final jsonString =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      try {
        final dynamic decodedJson = jsonDecode(jsonString);
        if (decodedJson is Map<String, dynamic>) {
        } else {
          developer.log('Received message is not a valid JSON object');
        }
      } catch (e) {
        developer.log('Error decoding JSON: $e');
      }
    });
  }

  return client;
}

Future<String> generateClientId() async {
  final deviceInfo = DeviceInfoPlugin();

  try {
    if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      return "mqttClientId_${androidInfo.model}";
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      return "mqttClientId_${iosInfo.utsname.machine}";
    }
  } catch (e) {
    developer.log("Error getting device information: $e");
  }
  final random = Random();
  return "mqttClientId_${random.nextInt(1000)}";
}

Future<void> mqttPublish({
  required dynamic message,
  required String topic,
  required MqttServerClient client,
}) async {
  final jsonString = jsonEncode(message);
  final builder = MqttClientPayloadBuilder();
  builder.addString(jsonString);
  if (client.connectionStatus?.state == MqttConnectionState.connected) {
    client.publishMessage(
      topic.toString(),
      MqttQos.exactlyOnce,
      builder.payload!,
      retain: true,
    );
    developer.log(topic);
    developer.log('Published data: $jsonString');
  }
}
