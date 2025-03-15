Set Up Flutter Project
Create a new Flutter project using flutter create pdf_jpeg_table_extractor.
Add dependencies in pubspec.yaml:
file_picker for file selection.
flutter_gemini (or google_generative_ai) for Gemini API integration, if available; otherwise, use http for REST API calls.
Implement File Selection
Use the file_picker package to allow users to pick a PDF or JPEG file.
Validate the file type to ensure it’s either application/pdf or image/jpeg.
Example code snippet:
dart

Collapse

Wrap

Copy
import 'package:file_picker/file_picker.dart';

Future<FilePickerResult?> pickFile() async {
  return await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'jpg', 'jpeg'],
  );
}
Upload File to Gemini API
Read the selected file as bytes using file.readAsBytesSync().
Determine the MIME type based on the file extension.
Upload the file to the Gemini API (via a package or HTTP request).
If using flutter_gemini:
dart

Collapse

Wrap

Copy
final fileBytes = file.readAsBytesSync();
final mimeType = file.path.endsWith('.pdf') ? 'application/pdf' : 'image/jpeg';
Extract Table Data Using Gemini API
Send the file to the Gemini API with a prompt to extract table data.
Handle the API response, expecting structured data (e.g., JSON).
Example (assuming flutter_gemini):
dart

Collapse

Wrap

Copy
final response = await Gemini.instance.prompt(parts: [
  Part.file(fileBytes, mimeType: mimeType),
  Part.text('Extract the table from this document and return the data as a JSON array of objects, where each object represents a row with keys corresponding to the column headers.'),
]);
Parse API Response
Decode the JSON response from the API into a list of maps.
Example:
dart

Collapse

Wrap

Copy
import 'dart:convert';
List<Map<String, dynamic>> tableData = jsonDecode(response.output) as List<Map<String, dynamic>>;
Display Data in a Table
Use Flutter’s DataTable widget to display the extracted data.
Dynamically generate columns from the keys in the first row and populate rows with the data.
Example:
dart

Collapse

Wrap

Copy
DataTable(
  columns: tableData.isNotEmpty
      ? tableData.first.keys.map((key) => DataColumn(label: Text(key))).toList()
      : [],
  rows: tableData.map((row) {
    return DataRow(
      cells: row.values.map((value) => DataCell(Text(value.toString()))).toList(),
    );
  }).toList(),
)
Handle Errors and Edge Cases
Check for invalid file types and display an error message (e.g., “Please upload a PDF or JPEG file”).
Handle API errors (e.g., network issues, invalid responses) with a fallback UI.
Example:
dart

Collapse

Wrap

Copy
if (response == null) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to process file')));
}
Prompts for Gemini API
The prompt sent to the Gemini API is critical for getting the desired output. Here’s the recommended prompt:

Prompt:
"Extract the table from this document and return the data as a JSON array of objects, where each object represents a row with keys corresponding to the column headers."
Why This Prompt?
It specifies that the API should identify and extract table data from the uploaded file (PDF or JPEG).
It requests a structured JSON format, making it easy to parse and display in a Flutter DataTable.
For PDFs, it assumes the API can process the document directly (supported as of Gemini 1.5 models). For JPEGs, it leverages OCR or image analysis to extract text.
Example Expected Response
For a PDF or JPEG containing a table like:

Name	Age	City
Alice	25	New York
Bob	30	London
The API should return:

json

Collapse

Wrap

Copy
[
  {"Name": "Alice", "Age": "25", "City": "New York"},
  {"Name": "Bob", "Age": "30", "City": "London"}
]
Additional Notes
Gemini API Support: As of March 14, 2025, the Gemini API (e.g., Gemini 1.5 Pro) supports direct PDF processing and image-based text extraction for JPEGs. If the API version you use doesn’t support PDFs, convert them to images first (though this is unlikely given recent updates).
Package Choice: If flutter_gemini isn’t suitable, use google_generative_ai or make REST API calls:
Upload file: POST https://generativelanguage.googleapis.com/upload/v1beta/files.
Generate content: Use the file URI in a generateContent request.
UI Design: Keep it simple with a “Pick File” button and a scrollable table area for the results.