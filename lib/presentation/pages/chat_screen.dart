import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/app_constants.dart';
import '../providers/location_data_provider.dart';
import '../widgets/drawer/custom_drawer.dart';

class ChatScreen extends StatefulWidget {
  final LocationDataProvider locationData;

  const ChatScreen({super.key, required this.locationData});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late GenerativeModel model;
  String? reportSummary;
  bool isGeneratingReport = false;
  List<Map<String, dynamic>> chatHistory = [];

  @override
  void initState() {
    super.initState();
    model = GenerativeModel(model: "gemini-2.0-flash", apiKey: AppConstants.geminiApiKey);
  }

  Future<void> generateReport() async {
    setState(() {
      isGeneratingReport = true;
    });

    try {
      final prompt = """
      Analyze the following air quality data containing timestamp (dt_time), PM2.5 concentration (pm2.5cnc), PM10 concentration (pm10cnc), and device ID (deviceid). Provide the following insights: General Trends: Identify the overall trend in PM2.5 and PM10 levels over time. Are there significant increases or decreases? Peak Hours: Find the highest and lowest PM2.5 and PM10 values, and specify the corresponding timestamps. Daily Averages: Calculate and report daily average PM2.5 and PM10 concentrations. Hourly Patterns: Determine if there are specific hours of the day where pollution levels are consistently high or low. Anomalies: Detect any unusual spikes in pollution levels and potential reasons for them. Correlation Analysis: Check if there is any correlation between PM2.5 and PM10 levels. Suggestions: Provide recommendations based on air quality trends for residents in this area (do not give code give report): \n\n${widget.locationData.apiData}
      """;

      final response = await model.generateContent([Content.text(prompt)]);

      setState(() {
        reportSummary = response.text ?? "No report generated.";
        showReportDialog();
      });

    } catch (e) {
      setState(() {
        reportSummary = "Error generating report: $e";
      });
    } finally {
      setState(() {
        isGeneratingReport = false;
      });
    }
  }

  void sendMessage(String message) async {
    setState(() {
      chatHistory.add({"role": "user", "message": message});

    });

    try {
      String contextPrompt = reportSummary != null
          ? "Context (Report Analysis): $reportSummary\n\nUser: $message"
          : message;

      final response = await model.generateContent([Content.text(contextPrompt)]);

      setState(() {
        chatHistory.add({"role": "ai", "message": response.text ?? "No response."});
      });
    } catch (e) {
      setState(() {
        chatHistory.add({"role": "ai", "message": "Error generating response: $e"});
      });
    }
  }

  void showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Report Summary"),
        content: SingleChildScrollView(child: MarkdownBody(data: reportSummary ?? "No report available.")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat & AI Report"),
        actions: [
          if (reportSummary != null)
            IconButton(
              icon: const Icon(Icons.article),
              onPressed: showReportDialog,
            )
        ],
      ),
      drawer: CustomDrawer(apiData: widget.locationData.apiData),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: generateReport,
              child: const Text("Generate Report"),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: chatHistory.length,
                itemBuilder: (context, index) {
                  final message = chatHistory[index];
                  final isUser = message["role"] == "user";
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue[300] : Colors.grey[700],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: MarkdownBody(data: message["message"]),
                    ),
                  );
                },
              ),
            ),
            TextField(
              onSubmitted: sendMessage,
              decoration: const InputDecoration(
                labelText: "Ask a question...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
