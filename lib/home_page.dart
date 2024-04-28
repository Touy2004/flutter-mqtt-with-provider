import 'package:flutter/material.dart';
import 'package:mqtt_provider/mqtt.dart';
import 'package:mqtt_provider/provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Messages'),
      ),
      body: Consumer<MQTTDataProvider>(
        builder: (context, provider, child) {
          if (provider.hasError) {
            return Center(
              child: Text('Error: ${provider.error}'),
            );
          }

          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final mqttPayloads = provider.messages;

          return Column(
            children: [
              Expanded( 
                child: ListView.builder(
                  itemCount: mqttPayloads.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Message From MQTT: ${mqttPayloads[index]}'),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final client = Provider.of<MQTTDataProvider>(context, listen: false).client;
          mqttPublish(
            message: "your message",
            topic: 'your topic',
            client: client,
          );
        },
        child: const Icon(Icons.send),
      ),
    );
  }
}
